function p = mmvn_cdf(X, M, V, W )
% Mixture of multivariate nomral probabilities
% 
% p = mmvn_pdf( X, M, V )
% returns the multivariate normal density function evaluted at each row of
% x for each mixture in M and V assuming equal prior likelihood of
% belonging to each group
% X is an m x n matrix of m observations in n dimensions
% M is an k x n matrix of means for k centroids
% V is a n x n x k matrix of covariances for k centroids
% p is a m x k matrix of probabilities evaluated at each row of X



[m, n ]   = size(X);
[k    ]   = size(M, 1);

hasW = true;
if nargin < 4
    hasW = false;
elseif ~isvector(W)
    error( 'linstats:mmvn_pdf:InvalidArgument', 'W must be a vector');
end
    

p = zeros( m, k );
for i = 1:k
    p(:,i) = mvncdf( X, M(i,:), V(:,:,i) );
    if hasW
        p(:,i) = p(:,i)*W(i);
    end
end

