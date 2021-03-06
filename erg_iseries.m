classdef erg_iseries<ergGUI
    % loads average, and detects a and b wave
    properties
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=erg_iseries(erg,params,fign)
            params=checkStructField(params,'PlotNow',2);
            hGUI@ergGUI(erg,params,fign);
            
            Rows=size(erg.stepnames,1);
            colors=pmkmp(Rows,'CubicL');
%             colors=pmkmp(Rows,'CubicYF');
            tcolors=round(colors./1.2.*255);
            
            RowNames=cell(size(Rows));
            for i=1:Rows
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),erg.stepnames{i});
            end
                     
            % Steps as table
            ddinput=struct;
            ddinput.Position=[0.01, .65, 0.105, .05];
            ddinput.FontSize=14;
            ddinput.String=RowNames;%erg.stepnames;
            ddinput.Callback=@hGUI.updatePlots;
            hGUI.createDropdown(ddinput);
            
            
            table2input=struct;
            table2input.tag='stepsTable';
            table2input.Position=[0.01, .01, 0.105, .625];
            table2input.FontSize=10;
            table2input.ColumnWidth={35};
            table2input.Data=true(size(hGUI.erg.stepnames,1),2);
            table2input.ColumnName={'L','R'};
            table2input.RowName=RowNames;
            table2input.headerWidth=42;
%             table2input.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(table2input);
            
            % buttons
            hGUI.nextButton;
            hGUI.prevButton;
            hGUI.lockButton;
            hGUI.acceptButton;
            
            % plots
            pleft=.180;
            pwidth=.45;
            pheight=.43;
            ptop=.555;
            ptop2=.06;
            
            % flash intensity vs response
            % left Eye
            plotL=struct('Position',[pleft ptop pwidth pheight],'tag','plotL');
            plotL.XScale='log';
            hGUI.makePlot(plotL);
            hGUI.labelx(hGUI.figData.plotL,'I_f (cd/m^2)');
            hGUI.labely(hGUI.figData.plotL,'left TRP (\muV)');
            % right Eye
            plotR=struct('Position',[pleft ptop2 pwidth pheight],'tag','plotR');
            plotR.XScale='log';
            hGUI.makePlot(plotR);
            hGUI.labelx(hGUI.figData.plotR,'I_f (cd/m^2)');
            hGUI.labely(hGUI.figData.plotR,'right TRP (\muV)');
            
            
            pleft2=pleft+pwidth+.06;
            pwidth2=.98-pleft2;
            pheight=.43;
            
            % already saved average responses
            % left Eye
            plotL2=struct('Position',[pleft2 ptop pwidth2 pheight],'tag','plotL2');
            hGUI.makePlot(plotL2);
            hGUI.labelx(hGUI.figData.plotL2,'Time (ms)');
            hGUI.labely(hGUI.figData.plotL2,'left TRP (\muV)');
            % right Eye
            plotR2=struct('Position',[pleft2 ptop2 pwidth2 pheight],'tag','plotR2');
            hGUI.makePlot(plotR2);
            hGUI.labelx(hGUI.figData.plotR2,'Time (ms)');
            hGUI.labely(hGUI.figData.plotR2,'right TRP (\muV)');
            hGUI.firstLRplot();
            
            
            hGUI.updatePlots();
%             if params.LockNow
%                 hGUI.lockButtonCall();
%             end
        end
        
        function updatePlots(hGUI,~,~)
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            tAx=hGUI.erg.step.(currStep).t;
            
            
            %zero line
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroL2')
            
            lH=line(tAx,zeros(size(tAx)),'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','--','Marker','none','LineWidth',2,'MarkerSize',5,'Color',[.75 .75 .75])
            set(lH,'DisplayName','zeroR2')
            
            
        end
        

        function acceptButtonCall(hGUI,~,~)
            hGUI.disableGui;
            currStep=hGUI.getMenuValue(hGUI.figData.DropDown);
            TrialSel=get(hGUI.figData.trialTable,'Data');
            
            [Ltrials,Rtrials]=hGUI.erg.ERGfetchtrials(currStep);
            
            selL = TrialSel(:,1);
            hGUI.erg.step.(currStep).selL=selL;
            if sum(selL)==1
                hGUI.erg.step.(currStep).L=Ltrials;
            elseif sum(selL)>1
                hGUI.erg.step.(currStep).L=mean(Ltrials(selL,:));
            end
            
            selR = TrialSel(:,2);
            hGUI.erg.step.(currStep).selR=selR;
            if sum(selR)==1
                hGUI.erg.step.(currStep).R=Rtrials;
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
            
%           hGUI.figData.plotL2.XLim=[min(tAx) max(tAx)];
%           hGUI.figData.plotR2.XLim=[min(tAx) max(tAx)];
            hGUI.figData.plotL2.XLim=[0 0.15];
            hGUI.figData.plotR2.XLim=[0 0.15];
            
            
            hGUI.erg.results=hGUI.erg.Iseries_abpeaks();
            stepsn=size(get(hGUI.figData.DropDown,'string'),1);
%             scolors=pmkmp(stepsn,'CubicL');
            
            % colors for paper, ignoring anything below .1 cd/m^2 (no signal)
            scolors=repmat([.5 .5 .5],sum(hGUI.erg.results.iF<.1),1);
            scolors=[scolors ; pmkmp(sum(hGUI.erg.results.iF>=.1),'CubicL')];
%             scolors=[scolors ; pmkmp(sum(hGUI.erg.results.iF>=.1),'CubicYF')];
%             keyboard
            % Flash marker
            lH=line(tAx(tAx>=0&tAx<=0.002),700*ones(size(tAx(tAx>=0&tAx<=0.002))),'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',[0 0 0])
            set(lH,'DisplayName',sprintf('flash'))
            
            lH=line(tAx(tAx>=0&tAx<=0.002),700*ones(size(tAx(tAx>=0&tAx<=0.002))),'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',[0 0 0])
            set(lH,'DisplayName',sprintf('flash'))
            
            % Intensity Response Curves (probably should be fit here)
            % a-wave
            lH=line(hGUI.erg.results.iF,-hGUI.erg.results.La_peak,'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','-','Marker','none','Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('all_La'))
            lH=line(hGUI.erg.results.iF,-hGUI.erg.results.Ra_peak,'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','-','Marker','none','Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('all_Ra'))
            %b-wave
            lH=line(hGUI.erg.results.iF,hGUI.erg.results.Lb_peak,'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','-','Marker','none','Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('all_Lb'))
            lH=line(hGUI.erg.results.iF,hGUI.erg.results.Rb_peak,'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','-','Marker','none','Color',[.5 .5 .5])
            set(lH,'DisplayName',sprintf('all_Rb'))
            
            
            for i=1:stepsn
                currStep=hGUI.erg.stepnames{i};

                % Average traces
                tAx=hGUI.erg.step.(currStep).t;
                L=hGUI.erg.step.(currStep).L;
                R=hGUI.erg.step.(currStep).R;
                lH=line(tAx,L,'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_L',currStep))
                lH=line(tAx,R,'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_R',currStep))
                
                % a-wave peaks
                lH=line(hGUI.erg.results.La_t(i),hGUI.erg.results.La_peak(i),'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_La',currStep))
                lH=line(hGUI.erg.results.Ra_t(i),hGUI.erg.results.Ra_peak(i),'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Ra',currStep))
                
                % b-wave peaks
                lH=line(hGUI.erg.results.Lb_t(i),hGUI.erg.results.Lb_peak(i),'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Lb',currStep))
                lH=line(hGUI.erg.results.Rb_t(i),hGUI.erg.results.Rb_peak(i),'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Rb',currStep))
                
                % Intensity Response curve point
                % a-wave
                lH=line(hGUI.erg.results.iF(i),-hGUI.erg.results.La_peak(i),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_La',currStep))
                lH=line(hGUI.erg.results.iF(i),-hGUI.erg.results.Ra_peak(i),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Ra',currStep))
                %b-wave
                lH=line(hGUI.erg.results.iF(i),hGUI.erg.results.Lb_peak(i),'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Lb',currStep))
                lH=line(hGUI.erg.results.iF(i),hGUI.erg.results.Rb_peak(i),'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Rb',currStep))
            end
            
            

            hGUI.enableGui;
        end
        
       
    end
    
    methods (Static=true)
         
    end
end
