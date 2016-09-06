classdef lineH < handle
    %lH=lineH(x,y,figH) 
    %   creates line handle object
    %   use lH.markers to use default filled circles
    %   use lH.line to use remove markers and use line
    
    properties
        h
        Parent
    end
    
    methods
        function lh = lineH (XData,YData,figH)
            lh.Parent=figH;
            lh.h = line(XData,YData,'Parent',lh.Parent);
            lh.markers();
        end
        
        function lh = markers(lh)
            set(lh.h,...
                'LineStyle','none',...
                'Marker','o',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = line(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth','2',...
                'Marker','none',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = linemarkers(lh)
            set(lh.h,...
                'LineStyle','-',...
                'LineWidth','2',...
                'Marker','o',...
                'Color',[0 0.4470 0.7410],...
                'MarkerFaceColor',[0 0.4470 0.7410]...
                );  
        end
        
        function lh = color(lh,colors)
            set(lh.h,'Color',colors,'MarkerFaceColor',colors);  
        end
        
        function lh = marker(lh,mstyle)
            set(lh.h,'Marker',mstyle);  
        end
        
        function lh = markercolormap(lh,varargin)
            % from http://undocumentedmatlab.com/blog/plot-markers-transparency-and-color-gradient
            if nargin==1
                cmap=pmkmp(length(lh.h.XData),'CubicL');
            else
                cmap=varargin{1};
            end
            cmap=[cmap ones(size(cmap,1),1)]';
            mhandles = lh.h.MarkerHandle;
            %%
            set(mhandles,'FaceColorBinding','interpolated',...
                'FaceColorData',uint8(cmap*255),...
                'EdgeColorBinding','interpolated',...
                'EdgeColorData',uint8(cmap*255));  
        end
    end
    
end

