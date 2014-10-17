function [c0] = constrain( c )
%CONSTRAIN orthogonal basis for the null space c
%
%When solving an overdetermined system of equations there are no unique
%solutions. One way to proceed is to set some parameter estimates to 0 and
%solve for the remaining paramters. Another way to proceed is to constrain
%parameter estimates to sum to 0. This helper function for solve does the
%latter
%
%Example 
%   c0 = constrain( c )
%        c is a m x n matrix of zeros and ones. each row represents a
%        constraint applied when solving and each column is a model
%        parameter. The paremeters marked with a one in the same row will
%        sum to 0
%
%See also solve, model_building_tutorial

% $Id: constrain.m,v 1.5 2006/12/26 22:53:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% Find the null space of the constraints matrix
% even though e is never used it is needed !
[q,r,e] = qr(c'); %#ok

%estimate rank
if (min(size(r))==1)
   d = abs(r(1,1));
else
   d = abs(diag(r));
end
tol = 100 * eps(class(d)) * max(size(r));
n = sum(d > tol*max(d));

%return null matrix
c0      = q(:,n+1:end);


