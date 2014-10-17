function  [b, gi, gn] = isnested( g1, g2 )
%ISNESTED tests whether two factors are nested 
%
% factors are nested if all levels of one factor occur only within one
% level of another factor
%
% [b, gi, gn] = isnested( g1, g2 )
%   g1 and g2 are grouping variables 
% returns b = 1 if g1 is nested in g2
%         b = 2 if g2 is nested in g1, 
%         b = 0, otherwise
% gi and gn are the ouputs of grp2ind( g1, g2);
%
% Example
%      % create data where factor B is nested in A
%       A = { 'a' 'a' 'a' 'a' 'b' 'b' 'b' 'b' }';
%       B = [  1   1   2   2   3   3   4   4 ]';
%       b = isnested( A, B);
%       
% See also grp2ind

% $Id: isnested.m,v 1.5 2006/12/26 22:54:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
x = crosstab( g1, g2 );
gi = [];
gn = [];

if ( all( sum(x ~= 0) == 1 ) )
    gi1 = grp2ind( g1 );
    gi2 = grp2ind( g2 );
    gi = [gi1, gi2];
    b = 2;
elseif ( all( sum(x ~=0,2) == 1 ) )
    %g1 is nested in g2
    b = 1;
    gi1 = grp2ind( g1 );
    gi2 = grp2ind( g2 );
    gi = [gi1, gi2];
else
    b = 0;
end;