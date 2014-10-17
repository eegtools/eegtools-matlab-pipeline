function xx = histinv( x, fx, n )
% HISTINV
%
%function histinv( x, fx )
% creates a dataset, xx, that has a distribution fx;
% at the given values of x
% fx can be either counts or a frequency
% if fx is from a density function, then n can be used so 
% each x is represented a fraction of n (rounded to the
% nearest integer. Assumes equal spacing of the xs
%
% Example
%  y = randn( 1000, 1 );            % generate example data
%  [fx, bins] = hist( y, 100 );     % histogram of actual data
%  y2 = histinv( bins, fx );        % new data based on histogram
%  fx2 = hist( y2, 100 );           % histogram of new data
%  bar( bins, fx );                 % draw original histogram ...
%  hold on;                         % wait ...
%  plot( bins, fx2 );               % ... draw new histogram. 

% $Id: histinv.m,v 1.2 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



if nargin >= 3
    fx = round(fx*n);   % convert freq to count and round
else
    fx = round(fx);
    n = sum(fx);
end;

xx = nan( n, 1 ); %preallocate x

j = 1;
for i = 1:length(x)
    q = fx(i);          % q of replicates of x(i)
    if ( j+q-1 > n )    % make sure we don't run past the end ...
        q = n-j+1;      % ... which can happen due to rounding
    end;
    xx( j:j+q-1 ) = repmat( x(i), q, 1 );
    j = j+q;
end;

% if we ran short ...
if j < n
    % ... fill in with random samples
    xx(j:n) = randsample( x, n-j+1, 'true', fx );   
end;


