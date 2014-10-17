function [b,gi,gn] = isdiscrete( x )
%ISDISCRETE heuristic test of whether x is discrete 
%
% b = isdiscrete( x )
% x is a numeric, char or cellstr
% returns 3 if the variable x appears discrete (categorical)
% othewise returns a 0
%
% Example
%   load carbig
%   isdiscrete(MPG)
%   isdiscrete(Origin)
%   isdiscrete(Cylinders)

% $Id: isdiscrete.m,v 1.3 2006/12/26 22:54:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

gi = (1:length(x))';
gn = x;

if ( ischar(x) || iscell(x) || ~isnumeric(x))
    b = 3;
    if ( nargout > 1)
        [gi, gn] = grp2ind(x);
    end;
elseif ( any(floor(x) ~= x))    
    b = 0;      % x contains elements that are not integer
else
    % see if x is "clumpy" - could use entropy here
    [B,I] = unique(x);
    if ( length(x)/length(I) > 1.5 )
        b = 3;  % treat it as discrete, since it clumps
       [gi, gn] = grp2ind(x);
    else
        gi = x;
        b = 0;
    end
end
