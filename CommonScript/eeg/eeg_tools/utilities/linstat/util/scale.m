function d = scale(X, V, dim)
%SCALE divides a vector from each row in a matrix
%
% data utility to simplify dividing each row in a matrix by a vector
%
% d = scale(X, V)
% X is a m x n matrix
% V is a 1 x n vector. defaults to column sum of X
% d is a new matrix with each row of X divided by V
%
%Example
%   load carbig
%   X = [MPG Acceleration Weight Displacement];
%   z = scale( center( X, mean(X )), std(X)); %zscore
%   z = scale(X, sum(X,1), 2);
%
%See also center

% $Id: scale.m,v 1.6 2006/12/26 22:54:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 3
    dim = 1;
end;

if nargin < 2
    V = sum(X, dim);
end

[m, n] = size(X);
s = n;
if dim == 2
    s = m;
end;

if ~isscalar(V) && (~isvector(V) || length(V) ~= s)
     error('linstats:scale:InvalidArgument', 'Input argument must be a vector');
end

if dim==2
    d = X./repmat(V, 1,n);
else
    d = X./repmat(V, m, 1);
end;