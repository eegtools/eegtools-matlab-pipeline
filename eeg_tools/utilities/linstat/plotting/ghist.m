function [fx, bins, gi, gn] = ghist( x, grpi, bins )
% GHIST histogram for grouped data
%
% Example
%  [x i] = mmvn_gen( 1000, (1:2:6)');   % mixture of data
%  ghist(x, i);                         % plot data stratified by
%                                       

% $Id: ghist.m,v 1.2 2006/12/26 22:53:25 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


[gi,gn] = grp2ind(grpi);

if nargin < 3
    bins = linspace( min(x(:)),max(x(:)), sqrt(size(x,1)) );
elseif isscalar(bins)
    bins = linspace( min(x(:)),max(x(:)), bins);
end

p = length(gn);
n = size(x,2);
fx = nan( length(bins), p*n );

if nargout == 0
    col = colorfulcube( p );
end;

for i = 1:p;
    j = (i-1)*n;
    fx(:,j+1:j+n) = hist( x(gi ==i,:), bins );
    if nargout == 0
        h = bar( bins, fx(:,j+1:j+n) );
        set( h, 'facecolor', col(i,:), 'edgecolor', col(i,:) );
        hold on;
    end
end

