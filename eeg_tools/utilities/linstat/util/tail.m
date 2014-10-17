function t = tail( data, rows, cols )
%TAIL show the last rows of a matrix
%
% tail( X, R, C )
% X is a m x n matrix 
% R is a scalar (default 8) of the number of rows to show
% C is a scalar (default 8) of the number of column to show
% return t, the first C columns of the last R rows of X
% 
% Example
%  X = randn(500,50);
%  tail(X)

% $Id: tail.m,v 1.3 2006/12/26 22:54:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if (isvector(data)) 
    data = data(:);
end;

[m,n] = size(data);

if (nargin < 2)
    rows = 8;
end;

if ( nargin < 3 )
    cols = 8;
end;



rows = min(rows,m)-1;
cols = min(cols,n);


t = data(m-rows:m, 1:cols);

