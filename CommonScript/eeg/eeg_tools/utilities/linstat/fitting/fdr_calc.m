function [fdr, u, sig, z, x, fx, fx0, n] = fdr_calc( p )
% FDR_CALC helper function to calculate the false discovery rate from a set
% of p-values from a repeated testing of independent data sets
% Example
%   [fdr, u, sig, z, x, fx, fx0, n] = fdr_calc( p )
%   % fdr emprical null distribution 
%   
% Reference, for simultaneous inference problem efron 2005
%
% I highly recommend plotting the results of this 
% function using fdr_plot. The empirical null might not be what you
% expect, or even make much sense ...
%
% see also fdr_plot

% $Id: fdr_calc.m,v 1.9 2006/12/26 22:53:15 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% should check that we have vector
if ( ~isvector(p) )
    error('linstats:fdr_calc:InvalidArgument', 'input must be a vector');
end;

% convert to column vector
p = p(:);

% it is convient to work with z-values instead
% of p values
p(p==0) = NaN;
p(isnan(p)) = min(p)/2;
z = norminv(p);
z(isinf(z)) = nan;

[highs lows x fx] = findMode( z );


%count peaks
n = length(highs);
n = max(2,n);
n = min(n,6);

%esimate mixed gaussians
i = isfinite(z);
Opt = mmvn_fit( z(i), n );
u   = Opt.M;
sig = sqrt(squeeze(Opt.V));

% calculate the mixed guassians
xx    = repmat(x',   1, length(u) );
uu    = repmat(u',   size(xx,1), 1  );
ss    = repmat(sig', size(xx,1), 1 );
y     = normpdf( xx, uu, ss );

y   = scale( y, 1./Opt.W' );


% null distribution
[null_mean null_mode] = min(abs(u));

% if the closest mode is more the 1.65 std deviations
% from zero, we don't really have a mode near 0 
if ( null_mean > 1.6449 )
    warning('linstats:fdr_calc:NoNullDistribution', 'no emprically null distribution found');
end;

fx0  = y(:,null_mode);
fdr = interp1( x', fx0./fx', z );

u   = u(null_mode);
sig   = sig(null_mode);



