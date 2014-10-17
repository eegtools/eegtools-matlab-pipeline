function lh = slegend( h, labels, varargin )
% SLEGEND  create legend based on marker size
%
% like legend but specialized to build only for the size attributes of the 
% lines in a plot
% slegend be used with mlegend and clegend to build multiple legends on a
% single plot. Each of the three graphical attributes (size, marker and
% color) and be associated with a single facet of the
%
% function lh = slegend( handles, labels )
%    handles is the handle to the lines to include
%    labels are the names for the different levels
%
% Example
%   x = 1:10; y = x + randn( 1, 10 );  % some data
%   h1 = plot( x(1:5), y(1:5), 'o', 'markerfacecolor', 'g' );
%   hold on;
%   h2 = plot( x(6:10), y(6:10), 'o', 'markerfacecolor', 'r', 'markersize', 10 );
%   lh = slegend( [h1 h2], {'group 1', 'group 2' } );
%   set(lh, 'location', 'northwest');

% See also mscatter, mlegend, clegend, slegend

% $Id: slegend.m,v 1.4 2006/12/26 22:53:29 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

lh = findobj( gcf, 'tag', 'slegend' );
for i = 1:length(lh)
    delete(lh(i));
end;

for i = 1:length(h)
legendinfo(h(i),'line',...
    'LineWidth', 1,...
    'Color', 'k',...
    'MarkerSize', get(h(i), 'markersize'), ...
    'Marker', 'o', ...
    'LineStyle', '-',...
    'XData',.5,...
    'YData',.5); 
end;

lh = legend(h, labels, varargin{:});
lname = inputname(2);
lname = deblank(lname);
set(lh,'tag', 'slegend', ...
       'xtick', .5, ...
       'xaxislocation', 'top', ...
       'xticklabel', lname );

