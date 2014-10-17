function [p, x, M, K, N] = fexact( a, b, c, d )
%FEXACT fishers exact test
%
% p = fexact( a, b, c, d )
% returns the p value from a fisher exact test where 
% the 2x2 contingency table looks like this
%   a   b
%   c   d
% a,b,c,d must be scalars
% returns the sum( hygepdf( 0:a, a+b+c+d, a+b, a+c ) );
% which is the same as hygecdf( a, a+b+c+d, a+b, a+c ) );
% usage p = fexact ( A )
% where a is a 2x2 matrix
% also returns the paramterization used by hypepdf, hypecdf
% requires matlab's statistics toolbox
%
% Example
%     fexact( 4, 9, 9, 3 )

% $Id: fexact.m,v 1.4 2006/12/26 22:54:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin == 1  % a must be a 2x2 matrix
    [m,n] = size(a);
    if m ~= 2 || n ~= 2
        error( 'linstats:fexact:InvalidArgument', 'a must be a 2x2 matrix' );
    end;
    A = a;
else
    A = [ a b; c d];
end

M = sum(A(:));
N = sum(A(:,1));
x = A(1);
K = sum(A(1,:));      

p = hygecdf( x, M, K, N );





