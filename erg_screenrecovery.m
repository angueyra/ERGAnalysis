classdef erg_screenrecovery<ergGUI
    % loads all available trials (just Step01) and plots them
    % identifies and plots a and b-wave amplitude
    % after approval, amplitudes, stored in erg object and saved
    % L and R selections are locked together
    properties
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=erg_screenrecovery(erg,params,fign)
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
            plotaL=struct('Position',[pleft2 ptop+pheight/2+.02 pwidth2 pheight/2.2],'tag','plotaL');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotaL);
            hGUI.labelx(hGUI.figData.plotaL,'Time (ms)');
            hGUI.labely(hGUI.figData.plotaL,'left a-wave amplitude (\muV)');
            
            plotbL=struct('Position',[pleft2 ptop+.02 pwidth2 pheight/2.2],'tag','plotbL');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotbL);
            hGUI.labelx(hGUI.figData.plotbL,'Time (ms)');
            hGUI.labely(hGUI.figData.plotbL,'left b-wave amplitude (\muV)');
            
            % right Eye
            plotaR=struct('Position',[pleft2 ptop2+pheight/2+.02 pwidth2 pheight/2.2],'tag','plotaR');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotaR);
            hGUI.labelx(hGUI.figData.plotaR,'Time (ms)');
            hGUI.labely(hGUI.figData.plotaR,'right a-wave amplitude (\muV)');
            
            plotbR=struct('Position',[pleft2 ptop2+.02 pwidth2 pheight/2.2],'tag','plotbR');
%             plotL.YLim=[-5 5];
            hGUI.makePlot(plotbR);
            hGUI.labelx(hGUI.figData.plotbR,'Time (ms)');
            hGUI.labely(hGUI.figData.plotbR,'right b-wave amplitude (\muV)');
            
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
            selR = selL;
            nTrials = size(TrialSel,1);
            
            delete(get(hGUI.figData.plotL,'Children'))
            delete(get(hGUI.figData.plotR,'Children'))
            delete(findobj(hGUI.figData.plotaL,'-regexp','tag','aL\d+'))
            delete(findobj(hGUI.figData.plotbL,'-regexp','tag','bL\d+'))
            delete(findobj(hGUI.figData.plotaR,'-regexp','tag','aR\d+'))
            delete(findobj(hGUI.figData.plotbR,'-regexp','tag','bR\d+'))
            
            [Ltrials,Rtrials]=hGUI.erg.ERGfetchtrials(currStep);
            tAx=hGUI.erg.step.(currStep).t;
            rS = hGUI.erg.recovery_abpeaks();
            
            hGUI.xlim(hGUI.figData.plotL,[min(tAx) max(tAx)])
            hGUI.xlim(hGUI.figData.plotR,[min(tAx) max(tAx)])
                        
            %zero line
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroL')
            
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroR')
            %zero line
            lH=line((1:nTrials)*1.5,zeros(1,nTrials),'Parent',hGUI.figData.plotaL);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroaL')
            lH=line((1:nTrials)*1.5,zeros(1,nTrials),'Parent',hGUI.figData.plotbL);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zerobL')
            
            lH=line((1:nTrials)*1.5,zeros(1,nTrials),'Parent',hGUI.figData.plotaR);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroaR')
            lH=line((1:nTrials)*1.5,zeros(1,nTrials),'Parent',hGUI.figData.plotbR);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zerobR')
            
            %temporary mean
            if sum(selL)>1
                lH=line(tAx,mean(Ltrials(selL,:)),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([1 0 0],.25))
                set(lH,'DisplayName',sprintf('tempL'))
                
                lH=findobj('DisplayName','tempL2');
                set(lH,'xdata',tAx,'ydata',mean(Ltrials(selL,:)))
            elseif sum(selL==1)
                lH=line(tAx,(Ltrials(selL,:)),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([1 0 0],.25))
                set(lH,'DisplayName',sprintf('tempL'))
                
                lH=findobj('DisplayName','tempL2');
                set(lH,'xdata',tAx,'ydata',(Ltrials(selL,:)))
            end
            if sum(selR)>1
                lH=line(tAx,mean(Rtrials(selR,:)),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([1 0 0],.25))
                set(lH,'DisplayName',sprintf('tempR'))
                
                lH=findobj('DisplayName','tempR2');
                set(lH,'xdata',tAx,'ydata',mean(Rtrials(selR,:)))
            elseif sum(selR==1)
                lH=line(tAx,(Rtrials(selR,:)),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',whithen([1 0 0],.25))
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
                    
                    lH=lineH(rS.t(i),rS.La_peak(i),hGUI.figData.plotaL);
                    lH.markers;lH.color(colors(i,:));
                    lH.setName(sprintf('aL%02g',i));
                    
                    lH=lineH(rS.t(i),rS.Lb_peak(i),hGUI.figData.plotbL);
                    lH.markers;lH.color(colors(i,:));
                    lH.setName(sprintf('bL%02g',i));
                end
                if selR(i)
                    lH=line(tAx,Rtrials(i,:),'Parent',hGUI.figData.plotR);
                    set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',colors(i,:))
                    set(lH,'DisplayName',sprintf('%s_R%02g',currStep,i))
                    
                    lH=lineH(rS.t(i),rS.Ra_peak(i),hGUI.figData.plotaR);
                    lH.markers;lH.color(colors(i,:));
                    lH.setName(sprintf('aR%02g',i));
                    
                    lH=lineH(rS.t(i),rS.Rb_peak(i),hGUI.figData.plotbR);
                    lH.markers;lH.color(colors(i,:));
                    lH.setName(sprintf('bR%02g',i));
                end
            end
            %update stored mean
            stepsn=size(get(hGUI.figData.DropDown,'string'),1);
            
            lH=findobj('DisplayName',sprintf('%s_L',currStep));
            set(lH,'ydata',hGUI.erg.step.(currStep).L)
            lH=findobj('DisplayName',sprintf('%s_R',currStep));
            set(lH,'ydata',hGUI.erg.step.(currStep).R)
        end
        
        
        function updateMenu(hGUI,~,~)
            hGUI.disableGui;
            hGUI.redoTrials();
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            hGUI.erg.step.(currStep).selL=hGUI.erg.step.(currStep).selR;
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
            table2input.Data=[hGUI.erg.step.(currStep).selL];
            table2input.ColumnName={'Sel'};
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
            
            selR = selL;
            hGUI.erg.step.(currStep).selR=selR;
            if sum(selR)==1
                hGUI.erg.step.(currStep).R=Rtrials(selR,:);
            elseif sum(selR)>1
                hGUI.erg.step.(currStep).R=mean(Rtrials(selR,:));
            end
            
            rS = hGUI.erg.recovery_abpeaks;
            
            hGUI.erg.results.t = rS.t(hGUI.erg.step.(currStep).selL); 
            hGUI.erg.results.La_peak = rS.La_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Lb_peak = rS.Lb_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.La_ttp = rS.La_ttp(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Lb_ttp = rS.Lb_ttp(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Ra_peak = rS.Ra_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Rb_peak = rS.Rb_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Ra_ttp = rS.Ra_ttp(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Rb_ttp = rS.Rb_ttp(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Lab_peak = rS.Lab_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.Rab_peak = rS.Rab_peak(hGUI.erg.step.(currStep).selL);
            hGUI.erg.results.n = sum(hGUI.erg.step.(currStep).selL);
            
            hGUI.updatePlots();
            hGUI.enableGui;
        end
        
        function firstLRplot(hGUI,~,~)
            hGUI.disableGui;
            
            rS = hGUI.erg.recovery_abpeaks;
            
            lH=lineH(rS.t,rS.La_peak,hGUI.figData.plotaL);
            lH.markers;lH.color([.5 .5 .5]);
            lH.setName(sprintf('aL'))
            
            lH=lineH(rS.t,rS.Lb_peak,hGUI.figData.plotbL);
            lH.markers;lH.color([.5 .5 .5]);
            lH.setName(sprintf('bL'))
            
            lH=lineH(rS.t,rS.Ra_peak,hGUI.figData.plotaR);
            lH.markers;lH.color([.5 .5 .5]);
            lH.setName(sprintf('aR'))
            
            lH=lineH(rS.t,rS.Rb_peak,hGUI.figData.plotbR);
            lH.markers;lH.color([.5 .5 .5]);
            lH.setName(sprintf('bR'))
            
            hGUI.enableGui;
        end
        
       
    end
    
    methods (Static=true)
         
    end
end
