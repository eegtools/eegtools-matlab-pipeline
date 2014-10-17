function xout = stdrcdf(q, v, r, upper)
% STRCDF calls matlab's stdrcdf function
%
% Example:
%   if you don't have matlab statitics toolbox then edit this
%   to change to your own strcdf function
% $Id: stdrcdf.m,v 1.3 2006/12/26 22:53:21 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
xout=dfswitchyard('stdrcdf',q,v,r,upper);
