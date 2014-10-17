function [i,j,k] = tri2sqind( m, k )
%TRI2SQIND subscript and linear indices for upper tri portion of matrix 
%
% get indices into a square matrix for a vector representing a the upper
% triangular portion of a matrix such as those returned by pdist. 
%
% [i,j,k] = tri2sqind( m, k )
%  If V is a hypothetical vector representing the upper triangular portion
%  of a matrix (not including the diagonal) and 
%  M is the size of a square matrix and
%  K is an optional vector of indices into V then tri2sqind returns 
%  (i,j) the subscript indice into the equivalent square matrix
%  k integer index into the equivalent square matrix
%
% Example
%  X = randn(5, 20); 
%  Y = pdist(X, 'euclidean');
%  [i,j,k] = tri2sqind( 5 );
%  S = squareform(Y);
%  isequal( Y(:), S(k) );
%  Z = zeros(5);
%  Z(k) = Y;


% $Id: tri2sqind.m,v 1.5 2006/12/26 22:54:14 Mike Exp $
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
    error('linstats:tri2sqind:InvalidArgument', 'ind2subl:Out of range subscript');
end;


i = floor(m+1/2-sqrt(m^2-m+1/4-2.*(k-1)));
j = k - (i-1).*(m-i/2)+i;
k = sub2ind( [m m], i, j );