classdef erg_issummary<ergGUI
    % loads iSeries results and displays them
    properties
    end
    
    methods
        % Constructor (gui objects and initial plotting)
        function hGUI=erg_issummary(erg,params,fign)
            params=checkStructField(params,'PlotNow',2);
            hGUI@ergGUI(erg,params,fign);
            
            Rows=size(erg,2);
            
            hGUI.colors=zeros(Rows,3);
            hGUI.tcolors=zeros(Rows,3);
            RowNames=cell(Rows);
            Genotypes=cell(Rows,2);
            for i=1:Rows
                switch erg{i}.genotype
                    case 'wt'
                        hGUI.colors(i,:)=[0 0 0];
                    case 'eml1+/-'
                        hGUI.colors(i,:)=[0 0 1];
                    case 'eml1-/-'
                        hGUI.colors(i,:)=[1 0 0];
                    case 'eml1weird'
                        hGUI.colors(i,:)=[1 0 .5];
                end
                hGUI.tcolors(i,:)=round(hGUI.colors(i,:)./1.2.*255);
                RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',hGUI.tcolors(i,1),hGUI.tcolors(i,2),hGUI.tcolors(i,3),erg{i}.id);
                Genotypes{i,1}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',hGUI.tcolors(i,1),hGUI.tcolors(i,2),hGUI.tcolors(i,3),erg{i}.genotype);
                Genotypes{i,2}=true;
            end
            
            
            % Steps as table
            tleft = 0.005;
            twidth = 0.140;
            
            ddinput=struct;
            ddinput.Position=[tleft, .65, twidth, .05];
            ddinput.FontSize=14;
            ddinput.String=RowNames;%erg.stepnames;
            ddinput.Callback=@hGUI.updatePlots;
            hGUI.createDropdown(ddinput);
            
            
            tableinput=struct;
            tableinput.tag='animalTable';
            tableinput.Position=[tleft, .01, twidth, .625];
            tableinput.FontSize=10;
            tableinput.ColumnWidth={45};
            tableinput.Data=Genotypes;
            tableinput.ColumnName={'genotype'};
            tableinput.RowName=RowNames;
            tableinput.headerWidth=58;
%             table2input.CellEditCallback=@hGUI.updatePlots;
            hGUI.createTable(tableinput);
%             
%             
            
%             bw=.11;
%             bh=0.07;
%             bl=0.005;
%             % buttons
%             hGUI.nextButton(struct('callback',@hGUI.defaultCall));
%             hGUI.prevButton(struct('callback',@hGUI.defaultCall));
%             hGUI.lockButton(struct('callback',@hGUI.defaultCall));
%             accStruct=struct('callback',@hGUI.defaultCall);
%             hGUI.acceptButton;


            % plots
            pleft=tleft+twidth+.050;
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

            % hGUI.figData.plotL2.XLim=[min(tAx) max(tAx)];
            % hGUI.figData.plotR2.XLim=[min(tAx) max(tAx)];
            hGUI.figData.plotL2.XLim=[0 0.15];
            hGUI.figData.plotR2.XLim=[0 0.15];
            
            hGUI.firstLRplot();

        end
        
        function updatePlots(hGUI,~,~)
            hGUI.disableGui;
            
            delete(findobj('-regexp','DisplayName','Step*'))
            delete(findobj('-regexp','DisplayName','currERG*'))
            
            currERG=hGUI.erg{hGUI.figData.DropDown.Value};
            tAx=currERG.step.(currERG.stepnames{1}).t;
            
            [nF_L,nF_R]=hGUI.getnormFactor(currERG);
            
            %Highlight current curve
            % a-wave
            lH=line(currERG.results.iF,currERG.results.La_peak./nF_L,'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',hGUI.colors(hGUI.figData.DropDown.Value,:))
            set(lH,'DisplayName',sprintf('currERG_aL'))
            lH=line(currERG.results.iF,currERG.results.Ra_peak./nF_R,'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',hGUI.colors(hGUI.figData.DropDown.Value,:))
            set(lH,'DisplayName',sprintf('currERG_aR'))
            % b-wave
            lH=line(currERG.results.iF,currERG.results.Lb_peak./nF_L,'Parent',hGUI.figData.plotL);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',hGUI.colors(hGUI.figData.DropDown.Value,:))
            set(lH,'DisplayName',sprintf('currERG_bL'))
            lH=line(currERG.results.iF,currERG.results.Rb_peak./nF_R,'Parent',hGUI.figData.plotR);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',hGUI.colors(hGUI.figData.DropDown.Value,:))
            set(lH,'DisplayName',sprintf('currERG_bR'))
            
            
            % Flash marker
            lH=line(tAx(tAx>=0&tAx<=0.002),700*ones(size(tAx(tAx>=0&tAx<=0.002))),'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',[0 0 0])
            set(lH,'DisplayName',sprintf('flash'))
            
            lH=line(tAx(tAx>=0&tAx<=0.002),700*ones(size(tAx(tAx>=0&tAx<=0.002))),'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','-','Marker','none','LineWidth',3,'MarkerSize',5,'Color',[0 0 0])
            set(lH,'DisplayName',sprintf('flash'))
            
            % graying anything below .1 cd/m^2 (no signal)
            scolors=repmat([.5 .5 .5],sum(currERG.results.iF<.1),1);
            scolors=[scolors ; pmkmp(sum(currERG.results.iF>=.1),'CubicL')];
            
            for i=1:size(currERG.results.iF,2)
                currStep=currERG.stepnames{i};

                % Average responses
                L=currERG.step.(currStep).L;
                R=currERG.step.(currStep).R;
                lH=line(tAx,L,'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_L',currStep))
                lH=line(tAx,R,'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','-','Marker','none','LineWidth',1,'MarkerSize',5,'Color',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_R',currStep))
                
                % a-wave peaks
                lH=line(currERG.results.La_t(i),currERG.results.La_peak(i),'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_La',currStep))
                lH=line(currERG.results.Ra_t(i),currERG.results.Ra_peak(i),'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Ra',currStep))
                
                % b-wave peaks
                lH=line(currERG.results.Lb_t(i),currERG.results.Lb_peak(i),'Parent',hGUI.figData.plotL2);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Lb',currStep))
                lH=line(currERG.results.Rb_t(i),currERG.results.Rb_peak(i),'Parent',hGUI.figData.plotR2);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Rb',currStep))
                
                % Intensity Response curve point
                % a-wave
                lH=line(currERG.results.iF(i),currERG.results.La_peak(i)./nF_L,'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_La',currStep))
                lH=line(currERG.results.iF(i),currERG.results.Ra_peak(i)./nF_R,'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','none','Marker','o','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Ra',currStep))
                %b-wave
                lH=line(currERG.results.iF(i),currERG.results.Lb_peak(i)./nF_L,'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Lb',currStep))
                lH=line(currERG.results.iF(i),currERG.results.Rb_peak(i)./nF_R,'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','none','Marker','^','Color',scolors(i,:),'MarkerFaceColor',scolors(i,:))
                set(lH,'DisplayName',sprintf('%s_Rb',currStep))
            end
            
            
            lH=line(currERG.results.La_t,currERG.results.La_peak,'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',[0 0 0])
            set(lH,'DisplayName',sprintf('currERG_La'))
            lH=line(currERG.results.Ra_t,currERG.results.Ra_peak,'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',[0 0 0])
            set(lH,'DisplayName',sprintf('currERG_Ra'))
            lH=line(currERG.results.Lb_t,currERG.results.Lb_peak,'Parent',hGUI.figData.plotL2);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',[0 0 0])
            set(lH,'DisplayName',sprintf('currERG_Lb'))
            lH=line(currERG.results.Rb_t,currERG.results.Rb_peak,'Parent',hGUI.figData.plotR2);
            set(lH,'LineStyle','-','LineWidth',2,'Marker','none','Color',[0 0 0])
            set(lH,'DisplayName',sprintf('currERG_Rb'))
            
            
            
            hGUI.enableGui;
        end
        

        function acceptButtonCall(hGUI,~,~)
            hGUI.disableGui;
          
            hGUI.enableGui;
        end
        
        function firstLRplot(hGUI,~,~)
            hGUI.disableGui;
            
            
            % Intensity Response Curves (probably should be fit here)
            for e=1:size(hGUI.erg,2)
               [nF_L,nF_R]=hGUI.getnormFactor(hGUI.erg{e});
                % a-wave
                lH=line(hGUI.erg{e}.results.iF,hGUI.erg{e}.results.La_peak./nF_L,'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','o','Color',hGUI.colors(e,:))
                set(lH,'DisplayName',sprintf('aL_%s',hGUI.erg{e}.id))
                lH=line(hGUI.erg{e}.results.iF,hGUI.erg{e}.results.Ra_peak./nF_R,'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','o','Color',hGUI.colors(e,:))
                set(lH,'DisplayName',sprintf('aR_%s',hGUI.erg{e}.id))
                %b-wave
                lH=line(hGUI.erg{e}.results.iF,hGUI.erg{e}.results.Lb_peak./nF_L,'Parent',hGUI.figData.plotL);
                set(lH,'LineStyle','-','Marker','o','Color',hGUI.colors(e,:))
                set(lH,'DisplayName',sprintf('bL_%s',hGUI.erg{e}.id))
                lH=line(hGUI.erg{e}.results.iF,hGUI.erg{e}.results.Rb_peak./nF_R,'Parent',hGUI.figData.plotR);
                set(lH,'LineStyle','-','Marker','o','Color',hGUI.colors(e,:))
                set(lH,'DisplayName',sprintf('bR_%s',hGUI.erg{e}.id))
            end
            
            hGUI.updatePlots;
            hGUI.enableGui;
        end
        
        
    end
    
    methods (Static=true)
         function [nF_L,nF_R]=getnormFactor(ergobj)
             nF_L = -ergobj.results.La_peak(end); % normalization factor
             nF_R = -ergobj.results.Ra_peak(end); % normalization factor
%              nF_L = 1; % normalization factor left eye
%              nF_R = 1; % normalization factor right eye
        end
    end
end
