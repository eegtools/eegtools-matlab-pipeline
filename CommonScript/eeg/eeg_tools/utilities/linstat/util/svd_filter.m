function [d, p]  = svd_filter( d, c )
% SVD_FILTER demonstrate svd to removie noise and compress data
%
% [d, p]  = svd_filter( D, C )
% D is a m x n matrix without missing values
% C is either a integer value or in [0 1) indicating how many components to
% include. If c is an integer then c components are used. Otherwise
% components explaining at least c of the variance are retained.
% Returns d
% a m x q matrix representing 
%
% Example
%   % generate data with the last two dimensions of noise
%   load carbig
%   X = [MPG Acceleration Weight Displacement];
%   i = ~any(isnan(X),2);  %find present values
%   X = zscore(X(i,:));
%   x = svd_filter(X,3);
%   plot(X(:,1), X(:,2), 'g.', x(:,1), x(:,2), 'b.') ;

% $Id: svd_filter.m,v 1.4 2006/12/26 22:54:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
[u,s,v] = svd( d, 0 );
s = diag(s);
p = cumsum(s)./sum(s);

if ( nargin < 2 || c < 1 )
    c = .95;
    dims = find( p >= c );
else
    dims = c;
end


d = 0;
for i = 1:dims
    d = d + s(i)*u(:,i)*v(:,i)';
end;

p = p(dims);
