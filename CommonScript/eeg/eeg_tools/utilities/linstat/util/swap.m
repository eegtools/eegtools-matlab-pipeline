function [a,b] = swap(a,b)
%SWAP swaps the values of two variables
% 
% [a,b] = swap(a,b)
% a and b are any variable any variable
% returns a set to the input value b
%         b set to the input value a
% 
% Example
%   a = 5; b = 10;
%   [a b] = swap(a,b);
%   a
%   b

% $Id: swap.m,v 1.4 2006/12/26 22:54:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
t = b;
b = a;
a = t;
