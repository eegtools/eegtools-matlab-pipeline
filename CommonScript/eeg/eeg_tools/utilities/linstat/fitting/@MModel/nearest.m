function ind = nearest( mm )
% NEAREST - returns the nearest cluster to each point (mahalonobis dist)
%
% Example
%       ind = nearest(mm)
%             if x has been provided, then returns ind an integer reference
%             to the nearest centroid.
%             centroids are defined by optimized parameter estimates if
%             available or initial estimates 

% $Id: nearest.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


[mind2 ind] = min(mm.d2,[],2);