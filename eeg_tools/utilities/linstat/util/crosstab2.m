function [tbl, n] = crosstab2( varargin )
%CROSSTAB2 cross tabulation with labels
%
%function [tbl, n] = crosstab2( varargin )
%formats crosstab results (supports 2 variables only )
% into readable table (with labels);
%
% Example
%  load carbig
%  tbl = crosstab2( Cylinders, Origin )
%  jplot_table(tbl);
%
% see also crosstab, plot_table, export, table

% $Id: crosstab2.m,v 1.6 2006/12/26 22:54:06 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[n, chi2, p, labels] = crosstab( varargin{:} );

[nrows, ncols] = size(n);
var_name       = inputname(1);
regexprep( var_name, '\_', '\\_' );
if isempty(var_name)
    var_name = ' ';
end;
if length(varargin) == 1
    tbl = table( {var_name 'count'}, labels(1:nrows,1), n) ;
else
    tbl = table( [var_name labels(1:ncols,2)'], labels(1:nrows,1), n) ;
end;