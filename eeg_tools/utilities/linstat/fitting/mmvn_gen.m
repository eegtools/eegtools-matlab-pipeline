function [X idx theta] = mmvn_gen(m,varargin )
% MMVN_GEN generates a mixture of multivariate guassians
%
% function X = mmvn_gen(m,theta)           % theta is a mmvn struct
% function X = mmvn_gen(m, M );            % M is a k x n matrix of means.
% function X = mmvn_gen(m, M, V);          % provide M and V
% function X = mmvn_gen(m, M, V, W );
% function [X idx] = mmvn_gen(...)         
%       returns idx, the source cluster for each observation
% function [X idx theat] = mmvn_gen(...)
%       returns theta, a standard parameter structre for mmvn_xxx functions
% example:
%   [X idx theta] = mmvn_gen( 200, [0 5; 5 0; 5 5; 0 0] );
%   this example creates 200 points randomly selected from 4, 2 dimensional
%   clusters with centers on a 5x5 cube
%   gscatter( X(:,1), X(:,2), idx );

%% $Id: mmvn_gen.m,v 1.6 2006/12/26 22:53:19 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

theta = mmvn_getTheta( varargin{:} );

    
[k d] = size(theta.M);  % k sources
X     = nan(m,d);     % preallocate memory for result
idx   = randsample( k, m, 'true', theta.W );  % random discrete process to 
                                            % generate source

% for each source
for i = 1:k
    [r p] = chol( theta.V(:,:,i) );
    if p ~= 0
        error('linstats:mmvn_gen:InvalidCovarianceMatrix', 'covariance matrix must be positive definite');
    end
    X(idx==i,:) = randn(sum(idx==i),d)*r;
end

X = X + theta.M(idx,:);

