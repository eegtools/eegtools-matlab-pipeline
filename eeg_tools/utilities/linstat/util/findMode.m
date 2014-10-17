function [highs, lows, x, y, freq] = findMode( X, varargin )
%FINDMODE estimated mode from a sample
%
% uses ksdensity to estiamted distribution for x and returns the 
% peaks of the distribution. 
% [highs, lows, x, y, freq] = findMode( X, varargin )
% highs is a vector of all peaks
% lows is a vector of local minimums
% x and y are the smoothed histogram from ksdensity
% freq is the estimated proportion of X in each peak
%
% requires matlab's stats toolbox
%
% Example
% [X idx theta] = mmvn_gen( 1000, [0; 5] );
% highs = findMode(X)

% $Id: findMode.m,v 1.5 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
[y, x] = ksdensity(X, varargin{:});


dy = (diff(y) > 0);     % find positive slopes
ddy = diff(dy);         % 2nd empirical derivative
i   = find(ddy==-1)+1;   % find change from positive to negative slope
highs = x(i);
freq  = y(i);
freq  = freq./sum(freq);


% find troughs
lows = find( ddy == 1 ) + 1;
lows = x(lows);
