function rad = deg2rad(deg)
%DEG2RAD convers degrees to radians
%
%Example
%   rad = acos(0);
%   deg = rad2deg(rad);
%
% See also rad2deg

% $Id: deg2rad.m,v 1.4 2006/12/26 22:54:06 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
rad = pi.*deg./180 ;