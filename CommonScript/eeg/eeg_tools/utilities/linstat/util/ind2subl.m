function [i,j,k] = ind2subl( m, k )
% IND2SUBL converts linear indices from upper triangle to square form 
%
% function [i,j,k] = ind2subl( m, k)
% M is the size of a square matrix
% K is a vector of linear addresses into a upper triangular matrix
% (optional)
% subscript values (i,j) and k are indices into an equivalent square matrix.
% For example here is a 5x5 matrix with all possible
% indices k shown. 
% - 1 2 3 4
% - - 5 6 7
% - - - 7 8
% - - - - 9
% - - - - -
%
% Example
%  X = randn(5, 20); 
%  Y = pdist(X, 'euclidean');
%  [i,j,k] = ind2subl( 5 );
%  S = squareform(Y);
%  isequal( Y(:), S(k) );
%  Z = zeros(5);
%  Z(k) = Y;

% $Id: ind2subl.m,v 1.4 2006/12/26 22:54:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

max_k = m*(m-1)/2;

if ( nargin < 2 )
    k = (1:max_k)';
end;

if ( k > max_k )
    error('linstats:ind2subl:InvalidArgument', 'Out of range subscript');
end;


i = floor(m+1/2-sqrt(m^2-m+1/4-2.*(k-1)));
j = k - (i-1).*(m-i/2)+i;
k = sub2ind( [m m], i, j );