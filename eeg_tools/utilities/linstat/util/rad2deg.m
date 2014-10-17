function deg = rad2deg(r)
%RAD2DEG radians to degrees
%
%Example
% rad = acos(0);
% deg = rad2deg(rad);

% $Id: rad2deg.m,v 1.3 2006/12/26 22:54:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
deg = r.*180./pi;