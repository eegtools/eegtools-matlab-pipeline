function h = head( data, rows, cols )
%HEAD the first rows and columns of data
%
% head( data, rows, cols )
% display the top few lines (default 8) and columns of a data matrix
% 
% Example
%   X = randn(500,50);
%   head(X)


% $Id: head.m,v 1.3 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
if (nargin < 2)
    rows = 8;
end;

if ( nargin < 3 )
    cols = rows;
end;

[m,n] = size(data);

rows = min(rows,m);
cols = min(cols,n);


h = data(1:rows, 1:cols); 

