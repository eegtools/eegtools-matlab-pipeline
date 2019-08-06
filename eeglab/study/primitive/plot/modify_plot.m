%% function [fig] = modify_plot(fig, varargin)
%
% modify properties of a figure using custom parameters.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% fig; a figure
% ====================================================================================================
% OPTIONAL INPUT:
%
% new_ylim
% new_ylim
% new_zlim
% new_clim
% new_xtick
% new_ytick
% new_ztick
% new_xticklab {} no labels or {'lab1','lab2',...}
% new_yticklab
% new_zticklab
% new_xlab
% new_ylab
% new_zlab
% new_title
% plot_box_width
% new_linewidth
% new_markersize
% new_fontsize
% ----------------------------------------------------------------------------------------------------
function [fig] = modify_plot(fig, varargin)

if nargin < 1
    help modify_plot;
    return;
end;

new_xlim = NaN;
new_ylim = NaN;
new_zlim = NaN;
new_clim = NaN;
new_xtick = NaN;
new_ytick = NaN;
new_ztick = NaN;
new_xticklab = NaN;
new_yticklab = NaN;
new_zticklab = NaN;
new_xlab = NaN;
new_ylab = NaN;
new_zlab = NaN;
new_title=NaN;
plot_box_width = NaN;
new_linewidth = NaN;
new_markersize = NaN;
new_fontsize = 8;


%% check optional arguments
for par=1:2:length(varargin)
    switch varargin{par}
        case {'new_xlim',...
                'new_ylim',...
                'new_zlim',...
                'new_clim',...
                'new_xtick',...
                'new_ytick',...
                'new_ztick',...
                'new_xticklab',...
                'new_yticklab',...
                'new_zticklab',...
                'new_xlab',...
                'new_ylab',...
                'new_zlab',...
                'new_title',...
                'plot_box_width'...
                'new_linewidth'...
                'new_markersize',...
                'new_fontsize'
                }
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end   
    %     if nargin < 2
    %        new_fontsize=8;
    %     end;
    
    
    %% extract properties form the figure
    
    h=get(fig,'Children');
    axes=findobj(fig, 'Type', 'Axes');
    
    xlabel_axes = get(axes, 'XLabel');
    ylabel_axes = get(axes, 'YLabel');
    zlabel_axes = get(axes, 'ZLabel');
    if iscell(xlabel_axes)
        xl  = [xlabel_axes{:}];
    else
        xl  = xlabel_axes;
    end
    
    if iscell(ylabel_axes)
        yl  = [ylabel_axes{:}];
    else
        yl  = ylabel_axes;
    end
    
    
    if iscell(zlabel_axes)
        zl  = zlabel_axes;
    else
        zl  = zlabel_axes;
    end
    
    title_axes  = get(axes, 'Title');
    
    if iscell(title_axes)
        tit=[title_axes{:}];
    else
        tit=title_axes;
    end
    
    
    
    
    %% change properties if required
    
    if ~sum(isnan(new_xlim));
        set(axes,'XLim',new_xlim);
    end
    
    if ~sum(isnan(new_ylim));
        set(axes,'YLim',new_ylim);
    end
    
    if ~sum(isnan(new_zlim));
        set(axes,'ZLim',new_zlim);
    end
    
    if ~sum(isnan(new_clim));
        set(h,'CLim',new_clim);
    end
    
    if ~sum(isnan(new_xtick));
        set(axes,'XTick',new_xtick);
    end
    
    if ~sum(isnan(new_ytick));
        set(axes,'YTick',new_xtick);
    end
    
    if ~sum(isnan(new_ztick));
        set(axes,'ZTick',new_ztick);
    end
    
    if ~sum(isnan(new_xticklab));
        set(axes,'XTickLabel',new_xticklab)
    end
    
    if ~sum(isnan(new_yticklab));
        set(axes,'YTickLabel',new_xticklab)
    end
    
    if ~sum(isnan(new_zticklab));
        set(axes,'zTickLabel',new_zticklab)
    end
    
    if ~sum(isnan(new_xlab));
        set(xl,'String',new_xlab);
    end
    
    if ~sum(isnan(new_ylab));
        set(yl,'String',new_ylab);
    end
    
    if ~sum(isnan(new_zlab));
        set(zl,'String',new_zlab);
    end
    
    if ~sum(isnan(new_title));
        set(tit,'String',new_title);
    end
    
    if ~sum(isnan(plot_box_width));
        set(h,'LineWidth',plot_box_width)
        
    end
    
    if ~sum(isnan(new_linewidth));
        set(findobj(fig, 'type', 'line'),'LineWidth',new_linewidth)
    end
    
    if ~sum(isnan(new_markersize));
        set(findobj(fig, 'type', 'line'),'MarkerSize',new_markersize)
    end
    
    % font size (default 10)
    set(axes,'FontSize',new_fontsize);
    set(xl,'FontSize',new_fontsize);set(xl,'interpreter','none');
    set(yl,'FontSize',new_fontsize);set(yl,'interpreter','none');
    set(tit,'FontSize',new_fontsize);set(tit,'interpreter','none');
    set(findall(fig,'type','text'),'fontSize',new_fontsize);set(findall(fig,'type','text'),'interpreter','none');
    setfont(fig, 'fontsize', new_fontsize);
    
%     set(fig, 'PaperType', 'A4', 'PaperPositionMode', 'auto');
    
    % set latex off
    set(fig,'defaulttextinterpreter','none')
   
    
    ll = findobj(fig,'Type','axes','Tag','legend');    
    
    set(ll, 'Interpreter', 'none')
    
    pp = get(fig,'Position');
     
    pp(3) = 2 * pp(3);
    pp(4) = 2* pp(4);
   
        
    set(fig, 'Position', pp)
    set(fig, 'PaperPositionMode', 'auto');          


    
end
