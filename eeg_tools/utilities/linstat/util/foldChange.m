function m = foldChange( x, base )
%FOLDCHANGE - converts log(ratio) into fold change 
%   m = foldChange( x )
%   m is set to the magnitude of 2^(x) with a negative value if x < 0;
%   base is optional and sets the logarithm base
%
% example
%     foldChange( log2(1/2) )   % = -2
%     foldChange( log2(2/1) )   % =  2

% $Id: foldChange.m,v 1.1 2006/12/26 22:54:14 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% find ratios less than 1
down    =  x < 0;
x(down) = -x(down);

%convert to ratios
if ( nargin >= 2 )
    m = base.^x;
else
    m = 2.^x;
end;

%convert ratios less than 1, to their negative reciprocal
m(down) = -m(down);


