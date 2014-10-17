function lh = mlegend( h, labels, varargin )
% MLEGEND  create legend based on marker 
%
% like legend but specialized to build only for the marker attributes of
% the lines in a plot mlegend can be used with slegend and clegend to build
% multiple legends on a single plot. Each of the three graphical attributes
% (size, marker and color) and be associated with a single facet of the
%
% lh = mlegend( handles, labels )
%    handles is the handle to the lines to include
%    labels are the names for the different levels
%
% Example
%   x = 1:10; y = x + randn( 1, 10 );  % some data
%   h1 = plot( x(1:5), y(1:5), 's', 'markerfacecolor', 'g' );
%   hold on;
%   h2 = plot( x(6:10), y(6:10), '^', 'markerfacecolor', 'r', 'markersize', 10 );
%   lh = mlegend( [h1 h2], {'group 1', 'group 2' } );
%   set(lh, 'location', 'northwest');
%
% see also mscatter, mlegend, clegend, slegend

% $Id: mlegend.m,v 1.4 2006/12/26 22:53:27 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

lh = findobj( gcf, 'tag', 'mlegend' );
for i = 1:length(lh)
    delete(lh(i));
end;

for i = 1:length(h)
legendinfo(h(i),'line',...
    'LineWidth', 1,...
    'Color', 'k',...
    'MarkerFaceColor', 'k', ...
    'Marker', get(h(i), 'marker'), ...
    'LineStyle', '-',...
    'XData',.5,...
    'YData',.5); 
end;

lh = legend(h, labels, varargin{:});

lname = inputname(2);
lname = deblank(lname);
set(lh,'tag', 'mlegend', 'xtick', .5, 'xaxislocation', 'top', 'xticklabel', lname );


