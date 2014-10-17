function b = isOptimized(mm)
%ISOPTIMIZED returns true if parameters have been optimized on this data

% $Id: isOptimized.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

b = ~isempty(mm.bhat);


