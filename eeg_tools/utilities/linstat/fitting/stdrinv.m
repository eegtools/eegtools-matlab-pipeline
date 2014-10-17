function x = stdrinv(p, v, r)
%STDRINV
% calls matlab's stdrinv function
%
% Example:
%   if you don't have matlab statitics toolbox then edit this
%   to change to your own strcdf function
% $Id: stdrinv.m,v 1.3 2006/12/26 22:53:21 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
x=dfswitchyard('stdrinv',p,v,r);
