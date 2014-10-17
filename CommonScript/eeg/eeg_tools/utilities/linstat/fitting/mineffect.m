function e = mineffect( stats )
%MINEFFECT finds the smallest estimated change in an estimate
%
% STATS statistics structure produced by lsestimates, lscontrast, mstats,
% etc
%
% E the smallest estimated change for each coefficient estimate in stats.
% if the coefficient estimate is positive then the smallest change is the
% estimate - ci, or 0, if the result is negative if the coefficient is
% negative then the smallest change is the estimate + ci, or 0, if the
% result is positive
%
% Example:
%   When conducting a superiority trial we want to know when some treatment
%   has a signficant effect on some measurement. When there are 10s of
%   thousands of meaqurements, as in DNA microarray experiments, it may not
%   be known what a meaningful significant effect size is. The researcher
%   doesn't like p-values because the effect size can be statisically 
%   signficiant, but not biologically significant. On the other hand a
%   biologically significant effect size is not defined for every
%   response. If it were we could directly test for effects bigger than the
%   threshold. So here is this function that calculates the minimimum
%   effect size. All positive effects are statistically significant and the
%   results can be sorted so that the ones that pass the highest contrast
%   threshold appear first in the list.
%
%   % first produce a stats structure using any method, e.g.
%   stats = lsestimates( glm );
%   % or
%   stats = mstats(glm);
%   % or
%   [u stats] = lscontrast(glm);
%   % then call min effect
%   e = mineffect( stats );

% $Id
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if ~isstruct(stats)
    error( 'linstats:mineffect:InvalidArgument', ...
           'requires stats struct as input');
end;

s = sign(stats.beta);
e = stats.beta - s.*stats.ci;

z = zeros( size(e) );       % this works when b is a row vector
% e(s==0) = 0;
e(s>0)  = max(e(s>0), 0 );
e(s<0)  = min(e(s<0), 0 );

