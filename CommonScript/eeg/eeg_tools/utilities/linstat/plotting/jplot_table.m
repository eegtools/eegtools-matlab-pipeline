function [T th] = jplot_table(col_names, varargin )
%JPLOT_TABLE plot a table to a figure window
%
% jplot_table( tbl )
%   tbl is a cell array of numeric or strings (e.g. from table)
%   
% [T th] = jplot_table( col_names, vararin )
%      creates a table by passing input arguments to table and plots the
%      results. returns T, the results from table and th a handle to the
%      uitable
%
%Example
%     load carbig
%     glm = encode( MPG, 3, 2, Origin );
%     s = mstats(glm);
%     tbl = estimates_table(s);
%     jplot_table(tbl); 
%
% See also table, uitable, plot_table

% $Id: jplot_table.m,v 1.2 2006/12/26 22:53:26 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

h = newplot;


if ( nargin > 1 )
    tbl = table( col_names, varargin{:} );
else
    tbl = col_names;    % use first argument as table
end;


th = uitable( gcf, 'data', tbl(2:end,:), 'ColumnNames', tbl(1,:) );
% size 
sz   =  get(h,'position');
units = get(h,'units');

set(th, 'units', units, 'pos', sz );
delete(h);


if nargout >= 1
    T = tbl;
end;
    