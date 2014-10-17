function [logl x y] = mmvn_logl_surface(X, theta, k, dims, x, y )
% MMVN_LOGL_SURFACE a 2d contour of the log likelihood surface
%
% [logl x y] = mmvn_logl_surface(X, theta, k, dims, x, y )
%  X is a m x d data matrix. 
%  theta describes the mixture (see mmvn_gen)
%  k is an integer specifying which class to calculate the contour for
%  dims is the 2 x 1 vector < d, specifying the dimensions to use. 
%  x and y are points at which to calculate the countour
%
% Example
%   [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
%   Opt = mmvn_fit( X, 4, theta,Init );
%   gscatter( X(:,1), X(:,2), idx); 
%   lims = [get(gca,'xlim')' get(gca, 'ylim')'];
%   xs = linspace( lims(1,:), lims(2,:), 15 )';
%   [logl x y] = mmvn_logl_surface( X, Opt, 1, [1 2], xs );
%   contour( x, y, logl);

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com



if nargin == 5          % x can be an m x 2 matrix instead of (x, y)
    y = x(:,2);
    x = x(:,1);
end;

[x y ] = meshgrid( x, y );
M      = theta.M;
V      = theta.V;
W      = theta.W;

logl = nan( size(x));
for i = 1:numel(x)
    M(k,dims) = [x(i), y(i)];
    logl(i) = mmvn_expectation( X, M, V, W );
end





