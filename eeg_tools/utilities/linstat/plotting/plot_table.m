function T = plot_table(col_names, varargin )
%PLOT_TABLE plot a table to a figure window
%
% plot_table( tbl )
%   tbl is a cell array of numeric or strings (e.g. from table)
%   
% T = plot_table( col_names, vararin )
%      creates a table by passing input arguments to table and plots the
%      results. returns T, the results from table
%Example
%     load carbig
%     glm = encode( MPG, 3, 2, Origin );
%     s = mstats(glm);
%     tbl = estimates_table(s);
%     plot_table(tbl); 
%
% See also table

% $Id: plot_table.m,v 1.6 2006/12/26 22:53:28 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

newplot


if ( nargin > 1 )
    tbl = table( col_names, varargin{:} );
else
    tbl = col_names;    % use first argument as table
end;


set( gca, 'fontunits', 'pixels' );
fontSize = get(gca,'fontsize');
set( gca, 'units', 'pixels');

sep = fontSize;


[m,n] = size(tbl);

if ( m > 500 || n > 1000 )
    % the main issue is that this takes a while to draw and 
    % is certainly illegable. If you really want this
    % draw a solid black square
    error( 'linstats:mscatter:InvalidArgument', 'ridiculously large table' )
end

% calculate required width in pixels

[width, height] = getColExtent( tbl );

width = max(width,[],1);
height = max(height,[],2);


%% shrink large tables 
% possibly to illegible sizes
xmargin = 4*sep;
ymargin = 4*sep;
total_width  = sum(width)  + n*sep + xmargin*2;
total_height = sum(height) + m*sep + ymargin*2;

%% plot data as 
apos = get( gca, 'position');
set( gca, 'position', apos );
set( gca, 'xlim', [0 total_width] );
set( gca, 'ylim', [0 total_height] );

for i = 1:m
    for j = 1:n
        str = tbl{i,j};
        if ( isnumeric( str ) )
            str = num2str(str);
            tbl{i,j} = str;
        end;
        xpos = xmargin + sum(width(1:j-1)) + (j-1)*sep;
        ypos = total_height - ymargin - sum(height(1:i)) - (i-1)*sep;
        text(xpos,ypos, str );
    end
end

%% format table borders

% single thick line frame around table
x(1) = xmargin-sep/2;                    % left
x(2) = total_width  + sep/2 - xmargin;   % right
y(1) = total_height - ymargin - sep/2;   % top
y(2) = ymargin - sep/2;                  % bottom
x = x( [ 1 2 2 1 1] );
y = y( [ 1 1 2 2 1] );
line( x, y, 'linewidth', min( sep/2, 3 ), 'color', 'k' );

% double line under header
yh = y(1)-height(1) - sep/2;
line( [ x(1) x(2) ], [yh yh], 'linewidth', 1, 'color', 'k' );
delta = min(2, sep/4);
line( [ x(1) x(2) ], [yh-delta yh-delta], 'linewidth', 1, 'color', 'k' );

% single thin lines between columns
for i = 1:n-1
    xpos = xmargin + sum(width(1:i)) + (i-1)*sep + sep/2;
    line( [ xpos xpos ], [y(1) y(4)], 'linewidth', 1, 'color', 'k' );
end

% single thin lines between rows
% relative to header line
for i = 2:m-1
    ypos = yh - sum(height(2:i)) - (i-1)*sep;
    line( [ x(1) x(2) ], [ypos ypos], 'linewidth', 1, 'color', 'k' );
end


%% Shrink axes to fit current figure
% maintain aspect

pos = get(gcf, 'position');

% wr = pos(3)/total_width;    %width ratio
% hr = pos(4)/total_height;   %height ratio
% r  = min(wr,hr);
% if ( r < 1 )
%     apos(3:4) = apos(3:4).*r; %shrink axes
%     set(gca,'pos', apos );
% end
% 
% pos(1:2) = 0;
% set( gca, 'pos', pos );

%% format current axes
set( gca, 'box', 'on', ...
     'xtick', [], ...
     'ytick', [], ...
     'units', 'normalized' );

% by convention ploting routines should not output results
 if nargout > 0
     T = tbl
 end