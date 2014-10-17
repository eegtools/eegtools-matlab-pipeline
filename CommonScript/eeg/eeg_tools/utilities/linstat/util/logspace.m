function y = logspace(d1, d2, n)
%LOGSPACE Logarithmically spaced vector.
%
%y =  logspace(d1,d2,n)
%  d1 is a 1 x m matrix of starting points
%  d2 is a 1 x m matrix of ending points
%  n is the number of points to generate (default 50)
%  y is a m x n matrix of logarithmically (base10) spaced values where the 
%  the ith column starts and ends at d1(i) and d2(i), respectively
%
%Example
% logspace( [ 1 3], [ 2 3], 5)
%
% See also linspace


if nargin == 2
    n = 50;
end
n = double(n);

e = linspace( d1(:)', d2(:)', n );
y = 10.^e;


