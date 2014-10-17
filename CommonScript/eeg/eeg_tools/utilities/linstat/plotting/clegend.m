function lh = clegend( h, labels, varargin )
% CLEGEND  create legend based on face color
%
% like legend but specialized to build only for the face color attributes
% of the markers a plot clegend be used with mlegend and slegend to build
% multiple legends on a single plot. Each of the three graphical attributes
% (size, marker and color) and be associated with a single facet of the
%
% function lh = clegend( handles, labels )
%    handles is the handle to the lines to include
%    labels are the names for the different levels
%
% Example
%   x = 1:10; y = x + randn( 1, 10 );  % some data
%   h1 = plot( x(1:5), y(1:5), 'o', 'markerfacecolor', 'g' );
%   hold on;
%   h2 = plot( x(6:10), y(6:10), 'o', 'markerfacecolor', 'r', 'markersize', 10 );
%   lh = clegend( [h1 h2], {'group 1', 'group 2' } );
%   set(lh, 'location', 'northwest');
%
% see also mscatter, mlegend, clegend, slegend

% $Id: clegend.m,v 1.4 2006/12/26 22:53:24 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


lh = findobj( gcf, 'tag', 'clegend' );
for i = 1:length(lh)
    delete(lh(i));
end;

for i = 1:length(h)
    c = get(h(i), 'markerfacecolor');
    if ischar(c) && isequal( c, 'none' )
        c = get(h(i),'color');
        legendinfo(h(i),'line',...
            'LineWidth', 1,...
            'linestyle', get(h(i),'linestyle'), ...
            'MarkerFaceColor', c, ...
            'Color', c, ...
            'LineStyle', '-',...
            'XData',[0 0 1 1 0],...
            'YData',[0 1 1 0 0]);
    else
        legendinfo(h(i),'patch',...
            'LineWidth', 1,...
            'EdgeColor', 'k',...
            'FaceColor', c, ...
            'LineStyle', '-',...
            'XData',[0 0 1 1 0],...
            'YData',[0 1 1 0 0]);
    end
end;

lh = legend(h, labels, varargin{:});
lname = inputname(2);
lname = deblank(lname);
set(lh,'tag', 'clegend', ...
    'xtick', .5, ...
    'xaxislocation', 'top', ...
    'xticklabel', lname );

