function [theta gi gn] = mgrpcov( x, g )
%MGRPCOV grouped means and covariances 
%
%[theta, idx, gn] = mgrpcov( x, g )
% results are returned in theta 
% M is a kxd matrix where M(k,:) is the location of the kth ellipse
% V is a dxdxk matrix of covariances where V(:,:,k) is the covariance
% W is a kx1 vector of frequencies of each class in g
% matrix for the kth ellipse.
% gi    - dummy variable encoding for g
% gn    - labels, such that gn(gi) = g
%
% missing values. If x contains any nans then only nans are returned
%
% example
%    [X idx theta] = mmvn_gen( 200, [0 5; 5 0; 5 5; 0 0] );
%    theta = mgrpcov( X, idx );
%    h = gscatter(X(:,1), X(:,2), idx); hold on;
%    colormap(cell2mat(get(h,'color')))
%    h = ellipse(theta.M, theta.V, [1 2]); 
%    set(h(:,1), 'linewidth', 3);
%
% see also gmean


% $Id: mgrpcov.m,v 1.4 2006/12/26 22:54:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if ( nargin < 2 )
    idx = ones( size(x,1), 1);
    gn = 'none';
else
    if isvector(g)
        g = g(:);
    end
    [idx,gn] = grp2ind(g);
end
[m,d] = size(x);        % d is number of variables (dimension)


if ( m ~= length(idx) ) 
     error('linstats:mgrpstats:InvalidArgument', 'g must have the same number of elements as there are rows in x'); 
end;    

k     = size(gn,1); % number of groups
V     = nan( [d d k] );

for i = 1:k
    j = idx == i;       %index to the ith group

    V(:,:,i) = cov( x(j,:) );
end;

theta.M = gmean(x,idx);
theta.V = V;
t = tabulate( idx );
theta.W = t(:,3)/100;

gi = idx;



    
    
    