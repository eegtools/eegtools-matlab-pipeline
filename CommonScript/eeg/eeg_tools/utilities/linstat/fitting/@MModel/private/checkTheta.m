function theta = checkTheta( s, varargin )
% checkTheta - check initial parameter for consistency 
% returns theta, a valid paremeter estimate structure
% example
%       theta = setTheta( s, theta )
%          theta is a structure providing M (kxd), V (dxdxk) and W(kx1)
%          theta may also provide h0, and v0, constraints (see also
%          mmvn_fit). check for consistency inside theta and with mm.s (if
%          set)
%       theta = setTheta(s, M );   % M is a k x d matrix. V defaults to I
%       theta = setTheta(s, M, V); % provide M and V is a d x d x k
%                                % matrix. W defaults to uniform
%       theta = setTheta(s, M, V, W);  % provide M,V and W a k x 1 vector

% $Id: checkTheta.m,v 1.2 2006/12/27 16:17:42 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

theta = mmvn_getTheta(varargin{:});


% check sizes
if ~isempty(s) 
    d = sum(s);
else
    d = size(theta.M,2);
end

k = size(theta.M,1);
if d ~= size(theta.M,2) || ... b0.M must be k x d
        d ~= size(theta.V,1) || ... b0.V must be d x d x k
        d ~= size(theta.V,2) || ...
        k ~= size(theta.V,3)    || ...
        k ~= size(theta.W,1)    || ... b0.W must be k x 1
        ~isvector(theta.W)
    error('linstats:Facs:setTheta', 'parameter structure is incosistent with model dimensions');
end

if ~isfield(theta, 'h0')
    theta.h0 = [];
elseif ~isempty(theta.h0) && ...
        (k ~= size(theta.h0,1) || ...
        d ~= size(theta.h0,2)  )
    error('linstats:Facs:setTheta', 'parameter structure is incosistent with model dimensions');
end
if ~isfield(theta, 'v0')
    theta.v0 = [];
elseif ~isempty(theta.v0) && ...
        ( k ~= size(theta.v0,1) || ...
        d ~= size(theta.v0,2)  )
    error('linstats:Facs:setTheta', 'parameter structure is incosistent with model dimensions');
end
    





