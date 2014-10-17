function theta = init(X,k,M,W)
% INIT sets mmvn parameters structure based on the data, x;
%
% if only k is provided a kmeans search is done
% if M is provided (must be k x d) then one round of EM is done
% if W is also provided then a weighed it is used in the round of EM

% $Id: init.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if nargin == 2 
        [n,d] = size(X);
        if k > 1
        [Ci,C] = kmeans(X,k,'Start','cluster', ...
            'Maxiter',100, ...
            'EmptyAction','drop', ...
            'Display','off'); % Ci(nx1) - cluster indeices; C(k,d) - cluster centroid (i.e. mean)
        else
            C = mean(X);
            Ci = ones( n, 1);
        end;
        M = C';
        V = zeros(d,d,k);
        for i=1:k,
            j = Ci==i;
            W(i) = sum(j)/n;
            V(:,:,i) = cov(X(j,:));
        end
        theta.M = M';
        theta.W = W;
        theta.V = V;
        return;
end

if nargin < 4
    W = [];
end

theta   = mmvn_getTheta( M, cov(X), W );
[ll E]  = mmvn_expectation( X, theta );
theta   = mmvn_maximization( X, E );
