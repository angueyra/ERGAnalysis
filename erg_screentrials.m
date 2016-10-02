classdef erg_screentrials<ergGUI
    % loads all available trials (for individual steps) and plots them
    % after approval, average is constructed, stored in erg object and saved
    properties
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=erg_screentrials(erg,params,fign)
            params=checkStructField(params,'PlotNow',1);
            hGUI@ergGUI(erg,params,fign);
            
            Rows=size(erg.stepnames,1);
            colors=pmkmp(Rows,'CubicL');
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(Rows));
            for i=1:Rows
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),erg.stepnames{i});
            end
                     
            % Steps as drop-down
            ddinput=struct;
            ddinput.Position=[0.01, .65, 0.105, .05];
            ddinput.FontSize=14;
            ddinput.String=RowNames;%erg.stepnames;
            ddinput.Callback=@hGUI.updateMenu;
            hGUI.createDropdown(ddinput);
            
            pleft=.180;
            pwidth=.45;
            pheight=.43;
            ptop=.555;
            ptop2=.08;
            
            bw=.11;
            bh=0.07;
            bl=0.005;
            % buttons
            hGUI.nextButton;
            hGUI.prevButton;
            hGUI.lockButton;
            
            accStruct=struct('callback',@hGUI.acceptButtonCall);
            hGUI.acceptButton;
            
            % trials in current step
            % left Eye
            plotL=struct('Position',[pleft ptop pwidth pheight],'tag','plotL');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotL);
            hGUI.labelx(hGUI.figData.plotL,'Time (ms)');
            hGUI.labely(hGUI.figData.plotL,'left TRP (\muV)');
            
            % right Eye
            plotR=struct('Position',[pleft ptop2 pwidth pheight],'tag','plotR');
%             plotR.YLim=[-5 5];
            hGUI.makePlot(plotR);
            hGUI.labelx(hGUI.figData.plotR,'Time (ms)');
            hGUI.labely(hGUI.figData.plotR,'right TRP (\muV)');
            
            
            pleft2=pleft+pwidth+.06;
            pwidth2=.98-pleft2;
            pheight=.43;
            
            % already saved averages
            % left Eye
            plotL2=struct('Position',[pleft2 ptop pwidth2 pheight],'tag','plotL2');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotL2);
            hGUI.labelx(hGUI.figData.plotL2,'Time (ms)');
            hGUI.labely(hGUI.figData.plotL2,'left TRP (\muV)');
            
            % right Eye
            plotR2=struct('Position',[pleft2 ptop2 pwidth2 pheight],'tag','plotR2');
%             plotR.YLim=[-5 5];
            hGUI.makePlot(plotR2);
            hGUI.labelx(hGUI.figData.plotR2,'Time (ms)');
            hGUI.labely(hGUI.figData.plotR2,'right TRP (\muV)');
            hGUI.firstLRplot();
            
            
            hGUI.updateMenu();
%             if params.LockNow
%                 hGUI.lockButtonCall();
%             end
        end
        
        function updatePlots(hGUI,~,~)
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            
            hGUI.params.PlotNow=currStep;
            
            TrialSel=get(hGUI.figData.trialTable,'Data');
            selL = TrialSel(:,1);
            selR = TrialSel(:,2);
            
            delete(get(hGUI.figData.plotL,'Children'))
            delete(get(hGUI.figData.plotR,'Children'))
            
            [Ltrials,Rtrials]=hGUI.erg.ERGfetchtrials(currStep);
            tAx=hGUI.erg.step.(currStep).t;
            
            hGUI.xlim(hGUI.figData.plotL,[min(tAx) max(tAx)])
            hGUI.xlim(hGUI.figData.plotR,[min(tAx) max(tAx)])
            
            hGUI.xlim(hGUI.figData.plotL2,[min(tAx) max(tAx)])
            hGUI.xlim(hGUI.figData.plotR2,[min(tAx) max(tAx)])
            
            %zero line
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroL')
            
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroR')
            %zero line
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroL2')
            
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroR2')
            
            %temporary mean
            if sum(selL)>1
                lH=line(tAx,mean(Ltrials(selL,:)),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([0 0 0],.65))
                set(lH,'DisplayName',sprintf('tempL'))
                
                lH=findobj('DisplayName','tempL2');
                set(lH,'xdata',tAx,'ydata',mean(Ltrials(selL,:)))
            elseif sum(selL==1)
                lH=line(tAx,(Ltrials(selL,:)),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([0 0 0],.65))
                set(lH,'DisplayName',sprintf('tempL'))
                
                lH=findobj('DisplayName','tempL2');
                set(lH,'xdata',tAx,'ydata',(Ltrials(selL,:)))
            end
            if sum(selR)>1
                lH=line(tAx,mean(Rtrials(selR,:)),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([0 0 0],.65))
                set(lH,'DisplayName',sprintf('tempR'))
                
                lH=findobj('DisplayName','tempR2');
                set(lH,'xdata',tAx,'ydata',mean(Rtrials(selR,:)))
            elseif sum(selR==1)
                lH=line(tAx,(Rtrials(selR,:)),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([0 0 0],.65))
                set(lH,'DisplayName',sprintf('tempR'))
                
                lH=findobj('DisplayName','tempR2');
                set(lH,'xdata',tAx,'ydata',(Rtrials(selR,:)))
            end
            % all trials
            colors=pmkmp((size(Ltrials,1)),'CubicL');
            for i=1:(size(Ltrials,1))
                if selL(i)
                    lH=line(tAx,Ltrials(i,:),'Parent',hGUI.figData.plotL);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('%s_L%02g',currStep,i))
                end
                if selR(i)
                    lH=line(tAx,Rtrials(i,:),'Parent',hGUI.figData.plotR);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('%s_R%02g',currStep,i))
                end
            end
            %update stored mean
            stepsn=size(get(hGUI.figData.DropDown,'string'),1);
            stepsv=get(hGUI.figData.DropDown,'value');
            scolors=pmkmp(stepsn,'CubicL');
            
            lH=findobj('DisplayName',sprintf('%s_L',currStep));
            set(lH,'ydata',hGUI.erg.step.(currStep).L)
            lH=findobj('DisplayName',sprintf('%s_R',currStep));
            set(lH,'ydata',hGUI.erg.step.(currStep).R)
%             
%             lH=line(tAx,hGUI.erg.step.(currStep).L,'Parent',hGUI.figData.plotL2);
%             set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(stepsv,:))
%             set(lH,'DisplayName',sprintf('%s_L',currStep))
%             lH=line(tAx,hGUI.erg.step.(currStep).R,'Parent',hGUI.figData.plotR2);
%             set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(stepsv,:))
%             set(lH,'DisplayName',sprintf('%s_R',currStep))
        end
        
        
        function updateMenu(hGUI,~,~)
            hGUI.disableGui;
            hGUI.redoTrials();
            hGUI.updatePlots();
            hGUI.enableGui;
        end
        
        function redoTrials(hGUI,~,~)
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            Trials=size(hGUI.erg.step.(currStep).selL,1);
            colors2=pmkmp(Trials,'CubicL');
            tcolors2=round(colors2./1.2.*255);
            TrialNames=cell(size(Trials));
            for i=1:Trials
                TrialNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>Trial%02g</font></html>',tcolors2(i,1),tcolors2(i,2),tcolors2(i,3),i);
            end
            
            table2input=struct;
            table2input.tag='trialTable';
            table2input.Position=[0.01, .01, 0.105, .65];
            table2input.FontSize=10;
            table2input.ColumnWidth={35};
            table2input.Data=[hGUI.erg.step.(currStep).selL hGUI.erg.step.(currStep).selR];
            table2input.ColumnName={'L','R'};
            table2input.RowName=TrialNames;
            table2input.headerWidth=42;
            table2input.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(table2input);
        end

        function acceptButtonCall(hGUI,~,~)
            hGUI.disableGui;
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            TrialSel=get(hGUI.figData.trialTable,'Data');
            
            [Ltrials,Rtrials]=hGUI.erg.ERGfetchtrials(currStep);
            
            selL = TrialSel(:,1);
            hGUI.erg.step.(currStep).selL=selL;
            if sum(selL)==1
                hGUI.erg.step.(currStep).L=Ltrials(selL,:);
            elseif sum(selL)>1
                hGUI.erg.step.(currStep).L=mean(Ltrials(selL,:));
            end
            
            selR = TrialSel(:,2);
            hGUI.erg.step.(currStep).selR=selR;
            if sum(selR)==1
                hGUI.erg.step.(currStep).R=Rtrials(selR,:);
            elseif sum(selR)>1
                hGUI.erg.step.(currStep).R=mean(Rtrials(selR,:));
            end
            
            
            hGUI.updatePlots();
            hGUI.enableGui;
        end
        
        function firstLRplot(hGUI,~,~)
            hGUI.disableGui;
            
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            tAx=hGUI.erg.step.(currStep).t;
            %temp means to replace at every update
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'Color',[.75 .75 .75])
            set(lH,'DisplayName','tempL2')
            
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'Color',[.75 .75 .75])
            set(lH,'DisplayName','tempR2')
            
            stepsn=size(get(hGUI.figData.DropDown,'string'),1);
            scolors=pmkmp(stepsn,'CubicL');
            for i=1:stepsn
                currStep=hGUI.erg.stepnames{i};
                
                tAx=hGUI.erg.step.(currStep).t;
                L=hGUI.erg.step.(currStep).L;
                R=hGUI.erg.step.(currStep).R;
                
                lH=line(tAx,L,'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_L',currStep))
                
                lH=line(tAx,R,'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_R',currStep))
            end
            hGUI.enableGui;
        end
        
       
    end
    
    methods (Static=true)
         
    end
end
