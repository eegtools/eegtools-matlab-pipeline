function [lsmeans, stats] = lscontrast( glm, term, L, alpha, tail )
%LSCONTRAST contrast means and statistics
% a contrast is a linear combination of estimates that sum to zero. 
%
% lsmeans= LSCONTRAST( glm )
% compares all pairwise combinations of means
% returns lsmeans, which contrasts coefficients (NOT contrasting
% least-squares means). See examples for contrasting lsmeans
%
% lsmeans= LSCONTRAST( glm, term )
% compares all pairwise combinations of means for the given term or terms
% term is a scalar or vector referering to the model term (0 = intercept) given in
% glm.terms. 
%
% lsmeans= LSCONTRAST( glm, term, L )
% L is a linear combination of terms, or it can be a scalar, in which case
% it is passed to getcontrasts, which will construct L.
% The meaning of scalar valuse aer
%   1 = all pairwise 
%                    compares each pair of levels j  - i
%                    j not equal i and j > i
%   2 = adjacent pairs  compare each level i+1 - i
%   3 = baseline        compare each level i to level 1
%
% lsmeans= LSCONTRAST( ..., alpha, tail )
% the confidence interval is 1-alpha
% the tail is 1 for a one-sided test of the contrast > 0. the default is a
% 2 sided test.
%
% [lsmeans stats] = LSCONTRAST(...) 
%  also returns stats, containing statistics and is suitable for
%  estimates_table
%
%
% Example:
%       load carbig
%       [lsm L] = lsestimates(glm); % get least-squares estimated
%       nterms  = glm.terms(end);
%       [u, stats] = lscontrast(glm,[0:nterms],L);  % get same answer
%
%       L1 = L*[0 0 -1 0 1 0]';  % build contrast of 6 and 4 cylinders
%       [u1 stats1] = lscontrast(glm, [0:nterms], L1 );
%
% See also getcontrasts, estimates_table

% $Id: lscontrast.m,v 1.14 2006/12/26 22:53:17 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if nargin < 4 || isempty(alpha)
    alpha = 0.05;
end

if nargin < 5
    tail = 0;
end;

if nargin < 2 || isempty(term)
    term = 1;
end;

% estimate parameters and covariance
ls = mstats(glm);


i = ismember( glm.terms, term);
% m = sum(i);

j = term==0;
nlevels = sum( glm.nlevels(term(~j)));
nlevels = nlevels+any(term==0);

if  nargin < 3 || isempty(L)
    L = getcontrasts(nlevels);
else
    if isscalar(L)
        L = getcontrasts(nlevels,L);
    end
end;

lsmeans = L'*ls.beta(i,:);

% the above code works with any number of responses
% the code below doesn't scale to multiple response
% so only exceute it conditionally
if nargout > 1

    %
    stats.beta = lsmeans;

    % build linear combinations of coefficients
    % that will give the desired ls contrasts for each level
    covb = ls.vinv(i,i);

    % To calculate the se, which is sqrt(variance)
    % note that the variance of a constant*variable
    % is given by
    % var(k*x) = k.^2*var(x).
    % or for a variance-covariance matrix
    % var(K*X) = K'*X*K
    stats.se  = sqrt(ls.mse'*diag(L'*covb*L)')';
    stats.t   = lsmeans./stats.se;

    %% confidence intervals
    if tail == 0
        tcrit = tinv( 1 - alpha/2, ls.dfe );
        stats.pval = 2*tcdf( -abs(stats.t), ls.dfe );
    elseif tail > 0  % right sided
       tcrit = tinv( 1 - alpha, ls.dfe );
       stats.pval = tcdf( -stats.t, ls.dfe );
    elseif tail < 0   % left sided
       tcrit = tinv( 1 - alpha, ls.dfe );
       stats.pval = tcdf( stats.t, ls.dfe );
    end

    stats.ci = tcrit.*stats.se;
    stats.tail = tail;

    % assume intercept term
    stats.dfr = glm.df0(term(~j));
    stats.dfr = stats.dfr + any(term==0);
    
    stats.dfe    = ls.dfe;
    
    stats.source = coeff2eqn( L', glm.coeff_names(i), 1 );
end




