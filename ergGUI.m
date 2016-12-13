classdef ergGUI < erggenericGUI
   properties
       erg
   end
   
   methods
       function hGUI=ergGUI(erg,params,fign)
          if nargin == 0
            fign=10;
          end
          hGUI@erggenericGUI(fign);
          hGUI.erg=erg;
          hGUI.params=params;
       end
       
       function updatePlots(~,~)
          fprintf('erg_GUI should override the updatePlots function\n') 
       end
       
       function updateTable(hGUI,~,eventdata)
           hGUI.disableGui;
           Selected=get(hGUI.figData.infoTable,'Data');
           Plotted=find(cell2mat(Selected(:,end)));
           Previous=Plotted(Plotted~=eventdata.Indices(1));
           Plotted=Plotted(Plotted==eventdata.Indices(1));
           Selected{Previous,end}=false;
           Selected{Plotted,end}=true;
           set(hGUI.figData.infoTable,'Data',Selected)
           updatePlots(hGUI);
           hGUI.enableGui;
%            hGUI.refocusTable(Plotted)
       end
       
       
       function makePlot(hGUI,plotstruct,varargin)
           if nargin < 2
               plotstruct=struct;
               plotstruct.tag='mainPlot';
           else
               plotstruct=checkStructField(plotstruct,'tag','mainPlot');
           end
           % if same exists, delete it
           delete(findobj('tag',plotstruct.tag))
           % plot properties
           plotstruct.Parent=hGUI.figData.panel;
           plotstruct=checkStructField(plotstruct,'Position',[.27 .55 .60 .43]);
           plotstruct=checkStructField(plotstruct,'FontSize',12);
           plotstruct=checkStructField(plotstruct,'XScale','linear');
           plotstruct=checkStructField(plotstruct,'YScale','linear');
           hGUI.figData.(plotstruct.tag)=axes(plotstruct);
       end
            
       function nextButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='next';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','next');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.nextButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .705 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'string','--->');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function prevButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='prev';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','prev');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.prevButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .775 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'string','<---');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function lockButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='lock';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','lock');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.lockButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .93 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Lock&Save');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       function acceptButton(hGUI,buttonstruct)
           if nargin < 2
               buttonstruct=struct;
               buttonstruct.tag='accept';
           else
               buttonstruct=checkStructField(buttonstruct,'tag','accept');
           end
           % if same exists, delete it
           delete(findobj('tag',buttonstruct.tag))
           % button definition
           buttonstruct.Parent=hGUI.figH;
           buttonstruct.callback=@hGUI.acceptButtonCall;
           buttonstruct=checkStructField(buttonstruct,'Position',[.005 .85 .11 .07]);
           buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
           buttonstruct=checkStructField(buttonstruct,'String','Accept');
           buttonstruct=checkStructField(buttonstruct,'FontSize',10);
           buttonstruct=checkStructField(buttonstruct,'UserData',[]);
           %create button
           buttonName=sprintf('%sButton',buttonstruct.tag);
           hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
       end
       
       % Callback functions
       function nextButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.figData.DropDown,'String');
            nowValue = get(hGUI.figData.DropDown,'Value');
            if nowValue+1>size(ddOptions,1)
                nextValue=1;
            else
                nextValue=nowValue+1;
            end
            set(hGUI.figData.DropDown,'Value',nextValue);
            hGUI.updateMenu();
            hGUI.enableGui;
       end
        
        function prevButtonCall(hGUI,~,~)
            hGUI.disableGui;
            ddOptions = get(hGUI.figData.DropDown,'String');
            nowValue = get(hGUI.figData.DropDown,'Value');
            if nowValue-1<1
                prevValue=size(ddOptions,1);
            else
                prevValue=nowValue-1;
            end
            set(hGUI.figData.DropDown,'Value',prevValue);
            hGUI.updateMenu();
            hGUI.enableGui;
        end
        
        
       function lockButtonCall(hGUI,~,~)
           hGUI.disableGui;
           hGUI.erg.ERGsave();
           hGUI.enableGui;
       end
       
       function defaultCall(hGUI,~,~)
           hGUI.disableGui;
           hGUI.enableGui;
       end
       function RowNames=waveTableNames(hGUI)
           Rows=size(hGUI.erg.waveNames,1);
           colors=pmkmp(Rows,'CubicL');
           tcolors=round(colors./1.2.*255);
           RowNames=cell(size(Rows));
           for i=1:Rows
               RowNames{i}=sprintf('<html><font color=rgb(%d,%d,%d)>%s</font></html>',tcolors(i,1),tcolors(i,2),tcolors(i,3),hGUI.erg.waveNames{i});
           end
       end
   end
   
   methods (Static=true)
       function labelx(plothandle,xlabel)
          set(get(plothandle,'XLabel'),'string',xlabel,'fontsize',12) 
       end
       
       function labely(plothandle,ylabel)
          set(get(plothandle,'YLabel'),'string',ylabel,'fontsize',12) 
       end
       
       function xlim(plothandle,xlim)
          set(plothandle,'xlim',xlim) 
       end
       
       function ylim(plothandle,xlim)
          set(plothandle,'ylim',xlim) 
       end
   end
end
