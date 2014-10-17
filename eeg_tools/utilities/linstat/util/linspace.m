function y = linspace(d1, d2, n)
%linspace Logarithmically spaced vector.
% 
% drop in replacement for matlabs linspace with support for vector input
%
%y =  linspace(d1,d2,n)
%  d1 is a 1 x m matrix of starting points
%  d2 is a 1 x m matrix of ending points
%  n is the number of points to generate (default 50)
%  y is a m x n matrix of logarithmically (base10) spaced values where the 
%  the ith column starts and ends at d1(i) and d2(i), respectively
%
%Example
% linspace( [ 1 3], [ 2 3], 5)
%
% See also logspace


if nargin < 2
    n = 100;
end

x  = x2fx((0:n-2)');
b  = [ d1;
       diff( [d1; d2])/(floor(n)-1) ];
y =  [ x*b; d2]';

