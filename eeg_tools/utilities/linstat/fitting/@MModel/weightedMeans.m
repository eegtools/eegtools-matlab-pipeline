function u = weightedMeans( mm )
% weightedMeans means weighted by class membership probabilities
%
% returns u, the set of weighted k x n set of weighted means 
% each row is the centroid for the corresonding cluster
% weighting is based on the mvn pdf of each point to the centroid
% theta. Theta is is taken from bhat. If bhat is empty then 
% b0 is used
%
% Example:
%   [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
%   mm = MModel(X, [1 2], 4 );      %  model 1st two dimensions
%   mm = em(mm);                    % optimize model
%    u = weightedMeans(mm);
%   mm = setModelDims( mm, 1:3 );   % make 3d model
%   mm = setMeans(mm, 1:4, u );     % initialize with weighted means
%   mm = em(mm);                    % optimize using em


% $Id: weightedMeans.m,v 1.2 2006/12/26 22:53:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

theta = mm.bhat;
if isempty(theta)
    theta = mm.b0;
end

if isempty(mm.x)
    u = nan( size( theta.M ) );
    return
end

w = mmvn_pdf( mm.x(:,mm.s), theta );
w(isnan(w)) = 0;

X = mm.x;
i = ~isnan(X);      % there can be nans in non-active dimensions

n = i'*w;           % count not including nans
X(~i) = 0;          % nans don't contribute to weighted sums

n(n==0) = 1;        % spoof to avoid divide by 0 (occurs if  all w(:,j) == 0)
u  = (X'*w)./n;
u = u';