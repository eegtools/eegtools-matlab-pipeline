function [wy, y, x, idx] = whist(Y,x,w)
%WHIST weighted histogram
%
% wy = whist( y,x,w) 
%       y is an m x 1 vector of observations, NaNs ignored
%       x is an optional  q x 1 vector of edges as used by histc 
%       w is a m x k matrix of weights. Each column is the weight for the 
%       one of k classes. 
%       returns N, the sum of weights of y at x
%  
% [wy y x idx] = whist( ..)
%       also returns
%       wy, the weighted count of y at x
%       y, the unweighed count of y at x
%       x, the bin location (same as input x if provided)
%      idx, is the bin of each y, it is the second output of histc and is 
%          defined as 0 for out of range values of y
%
% Example
%   % fit a mixture model to the first 2dimensions and get an estimated
%   histogram for the 3rd dimensions 
%   M = [ 0     5     1
%         5     0     2
%         5     5     3
%         0     0     4 ];
%
%   [X idx theta] = mmvn_gen( 10000, M );  %random data
%   mm = em(MModel(X,1:2,4));              %fit model with 4 clusters to
%                                          %dimensions 1 and 2
%   w  = mmvn_pdf(mm.x, getTheta(mm) );    %use probabilities as weights
%   [wy, y, x, idx] = whist( X(:,3), 100, w );    % weighted histogram for
%                                               % 3rd dimension
%   figure, 
%   plot( x, wy ); 

% $Id: whist.m,v 1.8 2006/12/26 22:53:30 Mike Exp $
% Written by
%   Mike Boedigheimer
%   Amgen
%   Department of Computational Biology
%   mboedigh@amgen.com

m = size(Y,1);

if ~isvector(Y)
    error( 'linstats:whist:InvalidArgument', 'observations must be a vector');
end

if ( m ~= length(w) )
    error( 'linstats:whist:InvalidArgument', 'weight matrix must be the same lengths as data matrix');
end

if isscalar(x)
    x = linspace(min(Y), max(Y), x );
end;

[y,idx] = histc( Y, x );

q = idx~=0;
[m,v,gn,sx] = mgrpstats( w(q,:), idx(q) );

wy = zeros(size(y,1), size(w,2) );

wy(unique(idx(q)),:) = sx;

