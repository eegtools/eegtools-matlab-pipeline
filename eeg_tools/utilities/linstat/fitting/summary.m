function [s, tbl] = summary( y )
%SUMMARY statistical summary table of values in y
%
%Example
%function [s, tbl] = summary( y )
% calculates summary statistics for the data in y
%     me
% rows equal to the mean, [0 25 50 75 100] and  variance for each column in
% y
% example
%       [s, tbl] = summary( randn(50,2) );
%
%  returns s, a matrix with the following rows, and tbl (a cell table
%  suitable for plot_table, or export
%   mean, 
%   min
%   1st quarteer
%   median
%   3rd quarter
%   max
%   variance

% $Id: summary.m,v 1.6 2006/12/26 22:53:21 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


n     = size(y,2);
s     = nan( 7, n );
[s(1,:),s(7,:)] = mgrpstats( y );
s(2:6,:) = prctile( y, 0:25:100 );

if nargout > 1
    tbl = table( {'measure'}, {'mean', 'min', '1st', 'med', '3rd', 'max', 'variance'}', s );
end
