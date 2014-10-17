function theta = mmvn_getTheta( varargin )
% MMVN_GETTHETA creates structure theta from various inputs
%
% Example:
% theta = mmvn_getTheta(theta)
% theta = mmvn_getTheta(M)
% theta = mmvn_getTheta(M,V)
% theta = mmvn_getTheta(M,V,W);
% 
% M is a k x d matrix of means
% V is a d x d x k matrix of covariance structures 
% W is a k x 1 matrix of class frequencies
% 
% See also mmvn_gen

n = nargin;

if n < 1
    error('linstats:mmvn_getTheta:Usage', 'must have at least one input');
end

if ~isstruct(varargin{1})
    M = varargin{1};
elseif n > 1
    error('linstats:mmvn_getTheta:Usage', 'must have exactly 1 input if first input is a struture');
else
    theta = varargin{1};
    return 
end

[k d] = size(M);

if nargin < 3 || isempty(varargin{3})
    W = ones( k, 1 )./k;
else
    W = varargin{3};
    W = scale(W(:));
end

if nargin < 2 || isempty(varargin{2})
    V = repmat( eye(d), [ 1 1 k ] );
else
    V = varargin{2};
end

theta = struct( 'M', M, 'V', V, 'W', W);
