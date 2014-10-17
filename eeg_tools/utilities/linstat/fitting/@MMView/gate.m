function [i x] = gate( v )
% GATE - applies the current gate and returns the resutls
% 
% this function is a simple wrapper for MMGate/gate 
%  
% Example
%       see MMGate/gate for examples

% $Id: gate.m,v 1.1 2006/12/26 22:53:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[i, x] = gate( v.view, v.mm );


