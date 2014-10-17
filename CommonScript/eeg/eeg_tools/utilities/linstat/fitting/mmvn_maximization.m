function Opt = mmvn_maximization(X, E, h0, b0)
% MMVN_MAXIMIZATION the second step of the EM algorithm
%
% calculates weights, means and variances given the current expectation
% matrix
%
% Example
% function Opt = mmvn_maximization(X, E, h0, b0)
%                h0 and b0 and mean and variance constrainst
%                X is a m x d matrix of observations
%                E is a m x k matrix of expectations (probabilities for
%                each observation sum to one)
%                Opt is a standard mmvn struture containing the most
%                likely values given E
%
% Reference for maximization method
% reference Xu, Lei and Jordan Michael, MIT (januaray 1995 in CBCL Paper
% number 111) and AI Memo No 1520.
%
%

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


%% MBJ 12/1/2005
%
n = size(X,1);

if nargin < 4
    b0 = [];
end
if nargin < 3
    h0 = [];
end;

W     = sum(E)';   
Opt.M = constrainM( X, E, W, h0 );  % calculate constrained M
Opt.V = constrainV( X, E, Opt.M, W, b0 );
Opt.W = W./n;



function M = constrainM( X, E, W, ca )
d = size(X,2);
W = repmat(W,1,d);
M = E'*X;    % sum of weighted values

if nargin > 3 && ~isempty(ca)
    for i = 1:d
        M(:,i) = M(:,i)'*ca(:,:,i);
        W(:,i) = W(:,i)'*ca(:,:,i);
    end;
end


   
W(W==0) = 1;    % if W ==0, then M == 0. use trick to prevent NaN
M = M./W;       % weighted mean


function V = constrainV( X, E, M, W, b0 )

[n d] = size(X);
k = length(W);
V = zeros( [d d k] );
for i=1:k,
    x0 = X - repmat( M(i,:), n, 1 );   % center about ith centroid
    
    %TODO. this is a hack to avoid a singularity
    %in the cov(x)
    if W(i)<d*5
        v = cov(X);
    else
        v    = (repmat(E(:,i),1,d).*x0)'*x0;   % weighted sum of squares and cross products
        v    = (v+v')/2;      % adjust roundoff errors it symmetric
    end
    V(:,:,i) = v;
end

W = reshape( repmat( W', [d*d, 1] ), [d d k ] ) ;

% collect 
if nargin > 4 && ~isempty(b0)
    for i = 1:d
        for j = 1:d
         V(i,j,:) = reshape(V(i,j,:), 1,k)*b0(:,:,i,j);
         W(i,j,:) = reshape(W(i,j,:), 1,k)*b0(:,:,i,j);
        end
    end
end
W(W==0) = 1;
V = V./W;



