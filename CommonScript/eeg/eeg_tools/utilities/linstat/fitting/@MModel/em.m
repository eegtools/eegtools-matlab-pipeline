function mm = em( mm, options  )
% EM produces optimal model estimates using expectation maximization
% 
% mm = em( mm, options )
%      mm is a MModel object
%      options is an optional structure described in mmvn_fit
%      returns a new optimized mixture model, mm, with bhat,
%       mahalanobis distances set. 
%
% example
%   [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
%   mm = MModel(X, [1 2], 4 );  %  model 1st two dimensions
%   mm = em(mm)

% $Id: em.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if isempty( mm.x)
    return
end;

if nargin < 2
    options.TolFun = 1e-8;
    options.TolX   = 1e-5;
end;

k = size(mm.b0.M,1);

[mm.bhat L] = mmvn_fit( mm.x(:,mm.s), k, mm.b0, options );

mm.bhat.L       = L;
mm.bhat.options = options;

mm.u     = weightedMeans( mm );
mm.d2    = mah(mm );
mm.L     = L.L(end);

