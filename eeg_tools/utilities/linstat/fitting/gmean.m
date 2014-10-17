function b = gmean( y, groups)
% GMEAN - efficiently calculate group means
%
% Example
% function xbar = gmean( y, groups)
%   y is a matrix (m x n) of m observations and n variables
%   groups is a m-vector of integer index variables specify k groups (1..k)
%   xbar is a k x n matrix of group means
%
% a single nan in any observation beloning to a group will force that 
% group to have nan for the mean
%
% See also mgrpstats, mgrpcov
%       
% $Id: gmean.m,v 1.3 2006/12/26 22:53:15 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



% encode groups as dummy variable
A = mdummy(groups,3);

if (~issparse(A))
    A = sparse(A);      % this helps deal with nan in the response y better
                        % because the way sparse multiple is implemented
end

R = qr(A,0);            % Q-less qr decomposition

b = R\(R'\(A'*y));      % solve for group means

% regress against the residuals
r = y-A*b;              % get the residuals
e = R\(R'\(A'*r));      % lsquares solve
b = b + e;              % sum the estimates


