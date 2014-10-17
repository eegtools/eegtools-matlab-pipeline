function [d2, z] = mah( y, u, v )
%MAH mahalonbis distance from a set of points to population centroids
%
% mahalonbis distance is the n-dimensional equivalent of zscore. It takes
% into account the spread and correlation in the data. 
%
% function [d2, z] = mah( y, u, v )
% Y is a nxq matrix of observations
% U is a kxq matrix of means. u(k,:) is the mean for the kth population
% V is a qxqxk matrix of covariances. v(:,:,k) is the cov of the kth
%   population
% D22 a nxk matrix of mahalanobis distances of points in y
%    to populations with multivariate normal distribution ~N(u,sqrt(v));
% Z is a nxqxk matrix of standardized coordinates relative to the centroid
%
% Example
%   [X idx theta] = mmvn_gen( 200, [0 5; 5 0; 5 5; 0 0] );
%   [d2 z] = mah(X, theta.M, theta.V);
    
% $Id: mah.m,v 1.7 2006/12/26 22:54:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% check sizes
% m x n x k
% m observations in y
% n variables
% k mixtures

m = size(y,1);      
[k n] = size(u);

if size(v,3) ~= k 
    error( 'linstats:mah:InvalidArgument', 'there must be the same number of variance structures (pages in v) as there are rows in u');
end

if size(v,1) ~= size(v,2) || size(v,1) ~= n
    error( 'linstats:mah:InvalidArgument', 'each page of v must be an nxn variance matrix');
end


z  = nan([m n k]);
d2 = nan([m k] );
for i = 1:k
    [r,p] = chol(v(:,:,i));
    if p > 0
        error( 'linstats:mah:InvalidArgument', 'covariance matrix must be positive definite');
    end
    y0 = center(y,u(i,:));
    ztmp = (r'\y0')';
    d2(:,i) = sum(ztmp.^2,2)';
    z(:,:,i) = ztmp;
end;



