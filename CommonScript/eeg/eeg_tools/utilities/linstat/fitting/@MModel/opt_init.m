function mm = opt_init(mm)
% opt_init - uses the optimal parameter estimates as the initial conditions
%
%            the model isOptimized(mm) still returns true after this call.
% 
% Example
% [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
% mm = MModel(X, [1 2], 4 );  %  model 1st two dimensions
% mm = em(mm);
% mm = opt_init(mm);      % use the optimized fit for the next data set
% mm = setData( mm, mmvn_gen(1000, theta ));   % new data
% mm = em(mm);        % fit new independent dataset
% ll = mm.L           % independent estimate for loglikelihood

% $Id: opt_init.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

mm.b0 = getTheta(mm);




