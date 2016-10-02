classdef erggenericGUI < handle
    %Created Dec_2015 (angueyra@nih.gov)
    properties
        figH
        params
        figData=struct;
    end
    
    properties (SetAccess = private)
        initalparseFlag = 0;
    end
    
    methods       
        function hGUI=erggenericGUI(fign)
            if isempty(fign)
                fign=10;
            end
            figure(fign);clf;
            hGUI.figH=gcf;
            set(hGUI.figH,'WindowStyle','normal');
            set(hGUI.figH,'Position',[250 450 1111 800]);
            delete(get(hGUI.figH, 'Children')); %delete every ui object whithin figure
            set(hGUI.figH,'UserData',hGUI);
            set(hGUI.figH,'KeyPressFcn',@hGUI.detectKey);
            
            % set the base panel for ui interactions
            hGUI.figData.panel = uipanel('Parent', hGUI.figH, ...
                'Units', 'normalized', ...
                'UserData',[], ...
                'Position', [.0001 .0001 .9999 .9999],...
                'tag','panel');
        end
        
        
        function keyPress = detectKey(hGUI, ~, handles)
            % determine the key that was pressed
            keyPress = handles.Key;
            if strcmp(keyPress,'rightarrow')&&~isempty(hGUI.figData.nextButton)
                hGUI.nextButtonCall;
            elseif strcmp(keyPress,'leftarrow')&&~isempty(hGUI.figData.prevButton)
                hGUI.prevButtonCall;
            end
        end
        
        function infoTable(hGUI,tableinput)
            if nargin == 0
                tableinput=struct;
            end
            % if previous infoTable exist, delete it
            delete(findobj('tag','infoTable'))
            % unchangeable parameters (overwrites if different)
            tableinput.Parent=hGUI.figH;
            tableinput.Units='normalized';
            tableinput.tag='infoTable';
            tableinput=checkStructField(tableinput,'Position',[0.01, .005, 0.185, .985]);
            tableinput=checkStructField(tableinput,'FontSize',10);
            tableinput=checkStructField(tableinput,'ColumnWidth',{20,20,20});
            tableinput=checkStructField(tableinput,'ColumnName',{'a','b','c'});
            tableinput=checkStructField(tableinput,'ColumnFormat',{});
            tableinput=checkStructField(tableinput,'RowName',{'1','2','3'});
            tableinput=checkStructField(tableinput,'ColumnEditable',true(1,3));
            tableinput=checkStructField(tableinput,'CellEditCallback',@hGUI.updateTable);
            tableinput=checkStructField(tableinput,'Data',false(3,3));
            tableinput=checkStructField(tableinput,'headerWidth',25);
              
            hGUI.figData.infoTable = uitable('Parent', tableinput.Parent, ...
                'Data', tableinput.Data, ...
                'Tag','infoTable',...
                'Units', tableinput.Units, ...
                'Position', tableinput.Position, ...
                'FontSize',tableinput.FontSize,...
                'ColumnWidth',tableinput.ColumnWidth,...
                'ColumnName',tableinput.ColumnName,...
                'ColumnFormat',tableinput.ColumnFormat,...
                'RowName', tableinput.RowName,...
                'ColumnEditable', tableinput.ColumnEditable,...
                'CellEditCallback',tableinput.CellEditCallback);
            modifyUITableHeaderWidth(hGUI.figData.infoTable,tableinput.headerWidth,'right');
        end
        
        function createTable(hGUI,tableinput)
            if nargin == 0
                tableinput=struct;
            end
            % unchangeable parameters (overwrites if different)
            tableinput.Parent=hGUI.figH;
            tableinput.Units='normalized';
            tableinput=checkStructField(tableinput,'tag','uitable0');
            tableinput=checkStructField(tableinput,'Position',[0.01, .005, 0.185, .985]);
            tableinput=checkStructField(tableinput,'FontSize',10);
            tableinput=checkStructField(tableinput,'ColumnWidth',{20,20,20});
            tableinput=checkStructField(tableinput,'ColumnName',{'a','b','c'});
            tableinput=checkStructField(tableinput,'ColumnFormat',{});
            tableinput=checkStructField(tableinput,'RowName',{'1','2','3'});
            tableinput=checkStructField(tableinput,'ColumnEditable',true(1,3));
            tableinput=checkStructField(tableinput,'CellEditCallback',@hGUI.defaultCall);
            tableinput=checkStructField(tableinput,'Data',false(3,3));
            tableinput=checkStructField(tableinput,'headerWidth',25);
            tableName=sprintf('%s',tableinput.tag);
                        
            % if same exists, delete it
            delete(findobj('tag',tableinput.tag))
            %create uitable
            hGUI.figData.(tableName) = uitable('Parent', tableinput.Parent, ...
                'Data', tableinput.Data, ...
                'Tag',tableinput.tag,...
                'Units', tableinput.Units, ...
                'Position', tableinput.Position, ...
                'FontSize',tableinput.FontSize,...
                'ColumnWidth',tableinput.ColumnWidth,...
                'ColumnName',tableinput.ColumnName,...
                'ColumnFormat',tableinput.ColumnFormat,...
                'RowName', tableinput.RowName,...
                'ColumnEditable', tableinput.ColumnEditable,...
                'CellEditCallback',tableinput.CellEditCallback);
            modifyUITableHeaderWidth(hGUI.figData.(tableName),tableinput.headerWidth,'right');
        end
        
        function createSlider(hGUI,sldstruct,varargin)
            if nargin < 2
                sldstruct=struct;
                sldstruct.tag='Slider';
            else
                sldstruct=checkStructField(sldstruct,'tag','Slider');
           end
           % if same exists, delete it
           delete(findobj('tag',sldstruct.tag))
           % plot properties
           sldstruct.Parent=hGUI.figData.panel;
           sldstruct=checkStructField(sldstruct,'Min',0);
           sldstruct=checkStructField(sldstruct,'Max',1);
           sldstruct=checkStructField(sldstruct,'Value',0);
           sldstruct=checkStructField(sldstruct,'Position',[.27 .001 .48 .10]);
           sldstruct=checkStructField(sldstruct,'Callback',@hGUI.defaultCall);
           sliderName=sprintf('%s',sldstruct.tag);
           hGUI.figData.(sliderName) = uicontrol(sldstruct.Parent,'Style','slider','Units','normalized',sldstruct);
        end
        
        function createButton(hGUI,buttonstruct)
            if nargin < 2
                buttonstruct=struct;
                buttonstruct.tag='Button';
                
            else
                buttonstruct=checkStructField(buttonstruct,'tag','Button');
            end
            % if same exists, delete it
            delete(findobj('tag',buttonstruct.tag))
            % button definition
            buttonstruct.Parent=hGUI.figH;
            buttonstruct=checkStructField(buttonstruct,'Callback',@hGUI.defaultCall);
            buttonstruct=checkStructField(buttonstruct,'Position',[.895 .01 0.10 .10]);
            buttonstruct=checkStructField(buttonstruct,'Style','pushbutton');
            buttonstruct=checkStructField(buttonstruct,'String',sprintf('%s',buttonstruct.tag));
            buttonstruct=checkStructField(buttonstruct,'FontSize',10);
            buttonstruct=checkStructField(buttonstruct,'UserData',[]);
            %create button
            buttonName=sprintf('%s',buttonstruct.tag);
            hGUI.figData.(buttonName) = uicontrol(buttonstruct.Parent,'Units','normalized',buttonstruct);
        end
        
        function createDropdown(hGUI,ddownstruct)
           if nargin < 2
               ddownstruct=struct;
               ddownstruct.tag='DropDown';
           else
               ddownstruct=checkStructField(ddownstruct,'tag','DropDown');
           end
           % if same exists, delete it
           delete(findobj('tag',ddownstruct.tag))
           % button definition
           ddownstruct.Parent=hGUI.figH;
           ddownstruct=checkStructField(ddownstruct,'Callback',@hGUI.defaultMenuCall);
           ddownstruct=checkStructField(ddownstruct,'Position',[.895 .01 0.10 .10]);
           ddownstruct=checkStructField(ddownstruct,'Style','popupmenu');
           ddownstruct=checkStructField(ddownstruct,'String',{'Option0', 'Option1','Option2'});
           ddownstruct=checkStructField(ddownstruct,'FontSize',10);
           ddownstruct=checkStructField(ddownstruct,'UserData',[]);
           %create menu
           ddownName=sprintf('%s',ddownstruct.tag);
           hGUI.figData.(ddownName) = uicontrol(ddownstruct.Parent,'Units','normalized',ddownstruct);
       end
        
        function updateTable(hGUI,~,~)
            hGUI.disableGui;
            hGUI.enableGui;
        end
        
        
        function refocusTable(hGUI,focusindex)
           jTable=findjobj(findobj('tag','infoTable'));
           jScrollPanel = jTable.getComponent(0);
           scrollEnd=jScrollPanel.getViewSize.height;
           jscrollNow=java.awt.Point(0,(focusindex-5)*scrollEnd/size(get(hGUI.figData.infoTable,'RowName'),1));
           jScrollPanel.setViewPosition(jscrollNow);
        end
        
       function nowSel = defaultMenuCall(hGUI,source,~)
            hGUI.disableGui;
            nowSel = hGUI.getMenuValue(source);
            hGUI.enableGui;
        end
        
        function defaultCall(hGUI,~,~)
            hGUI.disableGui;
            fprintf('Works!\n')
            hGUI.enableGui;
        end
        
        function currIndex=getCurrIndex(hGUI,~,~)
            if isfield(hGUI.figData,'infoTable')
                Selected=get(hGUI.figData.infoTable,'Data');
                currIndex=find(cell2mat(Selected(:,end)));
            end
        end
        
        function currRowName=getRowName(hGUI,~,~)
            if isfield(hGUI.figData,'infoTable')
                currIndex=hGUI.getCurrIndex();
                rowNames=get(hGUI.figData.infoTable,'RowName');
                currWaveNamestart=regexp(rowNames{currIndex},')>')+2;
                currWaveNameend=regexp(rowNames{currIndex},'</font')-1;
                currRowName=rowNames{currIndex}(currWaveNamestart:currWaveNameend);
            end
        end
        
        function nowSel = getMenuValue(hGUI,source,~) %#ok<INUSL>
            options = get(source,'String');
            nowValue = get(source,'Value');
            htmlpattern='<[^>]*>';
            nowSel = char(options(nowValue));
            nowSel = regexprep(nowSel,htmlpattern,'');
        end
    end
    
    methods (Static=true)
        function theRowName=getRowNamebyIndex(hGUI,index)
           rowNames=get(hGUI.figData.infoTable,'RowName');
           currWaveNamestart=regexp(rowNames{index},')>')+2;
           currWaveNameend=regexp(rowNames{index},'</font')-1;
           theRowName=rowNames{index}(currWaveNamestart:currWaveNameend);
        end
        function [hX,hY]=calculateHist(wave,nbins,edgemin,edgemax)
            bins=linspace(edgemin*1.25,edgemax*1.25,nbins);
            histcurr=histc(wave,bins)';
            [hX,hY]=stairs(bins,histcurr);
            hY=hY/(length(wave));
        end
        function disableGui
            set(findobj('-property','Enable'),'Enable','off')
%             drawnow
        end
        function enableGui
            set(findobj('-property','Enable'),'Enable','on')
%             drawnow
        end
    end
end
