function [s order] = checkModelDims( mm, s)
% checkModelDims internal function to error check model dimensions
% returns a logical vector for the values in s
% s must be a logical vector or integer index into columns of mm.x
% and must reference size(M,2) columns
%

% $Id: checkModelDims.m,v 1.3 2006/12/27 16:17:42 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[s order] = ind2logical( s, size(mm.x,2) );

% check for error conditions
if  sum(s) ~= size(mm.b0.M,2)
    error('linstats:Facs:addCluster', ...
        'illegal or out of range s');
end


