function [width height] = getColExtent( tbl )
%GETCOLEXTENT gets the width and height of cells in a table
%
%function [width height] = getColExtent( tbl )
% tbl is an m x n cell-array of strings or numbers
% width and height are m x n matrices of the cell width and right in units
% for the current axes
%
% Example
%   load carbig
%   glm = encode( Acceleration, 3,1, Cylinders );
%   tbl = estimates_table( mstats(glm) );
%   [w h] = getColExtent(tbl);
%
% See also plot_table

% $Id: getColExtent.m,v 1.3 2006/12/26 22:53:25 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[m n] = size(tbl);
width  = zeros( m,n);
height = zeros(m,n);

units     = get(gca, 'units');
font_size = get(gca, 'fontsize');

for i = 1:m
    for j = 1:n
        str = tbl{i,j};
        if ( isnumeric( str ) )
            str = num2str(str);
            tbl{i,j} = str;
        end;
        h = text(0,0, str );
        set(h, 'units', units, 'fontsize', font_size );
        extent = get(h,'extent');
        width(i,j)  = extent(3);
        height(i,j) = extent(4);
        delete(h);
    end
end