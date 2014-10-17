function [y, minx, maxx, minxi, maxxi] = range(x,dim)
%RANGE drop in replacement for matlab's range. 
%
% Range improves matlab's version range function by returning
% 
% [y, minx, maxx, minxi, maxxi] = range(x,dim)
%   returns a vector for each column of x (optionally along the specified
%   dimension) for the minimumn value the maximum value and a vector of 
%   row indices of where these values occur.
%
% Example
%   x = randn( 1000,4);
%  [y, minx, maxx, minxi, maxxi] = range(x,dim)
%
% See also summary


% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if nargin < 2
    [maxx, maxxi] = max(x);
    [minx, minxi] = min(x);
else
    [maxx, maxxi] = max(x,[],dim);
    [minx, minxi] = min(x,[],dim);
end

y = maxx - minx;
