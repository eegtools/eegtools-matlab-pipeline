function [ci, name] = confidence_intervals( se, dfe, dfr, alpha )
% CONFIDENCE_INTERVALS confidence interval for multiple-test correction
%   NOTE: This function relies on Matlab's getcrit and strinv
%         available in their statistics toolbox
% multiple test correction is necessary to control for false-discoveries
% due to the increased chance of not-rejecting a null hypothesis 
% simply because several tests are performed. This commonly happens when
% testing several contrasts, in which case a p-value based on t-test is not
% always appropriate.
% 
% Example
%   load carbig
%   glm = encode( Acceleration, 3,1, Cylinders );
%   ls  = mstats(glm);
%   ci  = confidence_intervals( ls.se, ls.dfe, ls.dfr, .05  )
%        se is a mx1 vector of standard error, 
%        dfe is a scalara for the degrees of freedom for the error
%        dfr is a m-vector containing the degrees of freedom for the term 
%        alpha is a scalar (0,1) for the size of the confidence interval
%        (default is 0.05, i.e 95% confidence interval)
%        ci is a  m x 6 matrix of 1/2 95% confidence intervals
%    The columns of ci are
%    minimum ci from all tests (except t-test)
%    Scheffe        - for general contrast of factor level means always
%                   - conservative. You are allowed to take min of Scheffe
%                   - and Bonferonni and you will still be conservative
%    Dunn-Sidak     
%    Bonferonni     - always conservative
%    Tukey-Kramer   - can be used for pairwise data-snooping
%    t-test         - aka least signficant difference - not a correction
%                   - for multiple tests
%
% [ci col_names] = confidence_intervals( ... ); % also return the
%                                               % test-names
% tbl = table( ['parameter' col_names'], ls.source, ci); %table of cis
%
% See also lscontrast, mstats

% $Id: confidence_intervals.m,v 1.5 2006/12/26 22:53:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% toconsider
%   refactor this function. Returning a critical value
%   maybe more useful. this would be a simple function but
%   maybe still useful because some folks will know the
%   name Scheffe, but not how to calculate the critical
%   value.



% term
if (nargin<4)
    alpha = 0.05;
end;

%% multiple tests - Scheffe Procedure
S2 = dfr.*finv(1-alpha, dfr, dfe );
S  = sqrt(S2);
ci_scheffe     = S.*se;

%% multiple tests - dunn-sidak
k = nchoosek(dfr+1, 2);
a = 1-(1-alpha).^(1/k);
ci_ds = tinv(1-a/2, dfe).*se;


%% multiple tests - bonferonni procedure
ci_bf = tinv(1-alpha/(k*2), dfe).*se;

%% multiple tests - Tukey-Kramer
S = stdrinv(1-alpha, dfe,dfr+1 )/sqrt(2);
ci_hsd     = S.*se;

%% t
tcrit = tinv( 1 - alpha/2, dfe );
ci_t = tcrit.*se;


ci_all = [ci_scheffe ci_ds ci_bf ci_hsd];
ci = [min(ci_all, [], 2) ci_all ci_t];

name= { 'Min', 'Scheffe', 'Dunn-Sidak', 'Bonferonni', 'Tukey-Kramer', 'LSD'};
