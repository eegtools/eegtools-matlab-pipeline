function [y,x] = scaledhist( a, bins )
% SCALEDHIST histogram with the total area equal 1 
% 
% [y,x] = scaledhist( a, bins )
%   a is an mxn array.
%   bins if present is the scalar number of bins to use or a vector of bin
%   centers passed to hist. If absent 100 bins are used.
%   returns y, the density of points in corresponding bin x.
%
% Example
%   y = randn( 1000, 1 );
%   plot( scaledhist( y) );

% $Id: scaledhist.m,v 1.6 2006/12/26 22:53:29 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if (nargin>=2)
    x = bins;
else
    low = min(min(a));
    high = max(max(a));
    x = linspace(low, high, 100);
end;

[y,x] = hist( a, x );
y = y/(diag(sum(y),0)*abs(x(2)-x(1)));