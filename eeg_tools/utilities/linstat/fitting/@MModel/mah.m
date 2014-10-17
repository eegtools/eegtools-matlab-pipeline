function d2 = mah( mm, theta )
% MAH mahalanobis distance of each point to each centroid
%
% Example
% d2 = mah(mm)
% returns d2, the set of unweighted mahalonbis distances from
% each point to each class in theta. 
% theta. Theta is taken from bhat. If bhat is empty then 
% b0 is used
% if x is empty then d2 = [];
%
%   

% $Id: mah.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if isempty(mm.x)
    d2 = [];
    return
end

if nargin < 2
    theta = getTheta(mm);
end

d2  = mah(mm.x(:,mm.s), theta.M, theta.V);
