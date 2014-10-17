function L = mmvn_likelihood(X,varargin)
% MMVN_LIKELIHOOD Calculates the log(likelihood ) of a mixture of mutlivariate gaussians
%  X is an n x d matrix. Theta is a structure describing the 
%   mixture (see mmvn_gen for a desicription)
%
% L = mmvn_likelihood(X,theta)
%     returns L, the total loglikelihood
%
% See also mmvn_fit, mmvn_maximization, mmvn_expectation.
%

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

theta = mmvn_getTheta(varargin{:});

%% MJB 12/1/2005
L = 0;
nlogW = size(X,1)*log(theta.W);

for j=1:size(theta.M,1);
    L = L + nlogW(j) + mvn_logl(X, theta.M(j,:), theta.V(:,:,j) ); 
end;

function logL = mvn_logl( X, U, V )
%% MJB 12/1/2005
% find the log liklihood of an entire multivariate gaussian distribution
% with the given Mean, U, covariance structure, V
% This is equivalent to the sum(log(mvnpdf(X,U,V))), but faster and more
% accurate when there are many observations with small mvnpdfs 

n = size(X,1);
X = center(X,U);

%TODO - V maybe singular. This can happen when
% the number of observations with a non-zero weight 
% is less than the dimension of V. sum(E~=0) < length(V);
% One idea how to fix this is to calucate the covariance
% of only the linearly independent columns of V and set
% set W = 0, or maybe a pinv. better is to use a wischart prior (snoussi et
% al)


xbar = mean(X,1);       % sample means
x0   = center(X,xbar);  % data centered about sample mean
S    = x0'*x0;          % sum squares

iV   = inv(V);

% fancy way to calculate the sum of the log liklihood
% over each observations (Thanks Mardia et al. "Multivariate Analysis")
logL = -n/2*log(det(2*pi*V)) - .5.*trace( iV*S) - n/2.*xbar*iV*xbar';
