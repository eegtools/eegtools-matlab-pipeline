function [t reduced full] = lof( glm )
%LOF lack of fit statistics
%
%Example
% t = lof( glm )
% calculates lack of fit statistic, which is the amount of fit that is
% unexplained by the model in glm, that is potentially explainable with a
% different model with the same variables. Lack of fit is only calculable
% if there are some observations with replicate measures.
%


% $Id: lof.m,v 1.5 2006/12/26 22:53:17 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% reduced is the least-squares solution to glm,
% full is the least-squares solution to glm converted to a fixed effects
% model with all variables treated as categorical. 

reduced = mstats(glm);

new_x = round(reduced.yhat/sqrt(eps))*sqrt(eps);

glm_full = encode( glm.y, 3, 1, new_x );
full = mstats( glm_full );

t.dft   = reduced.dfe;
t.dfe   = full.dfe;
t.df    = t.dft - t.dfe;

t.sst   = reduced.sse;
t.sse   = full.sse;
t.ss    = reduced.sse - full.sse;

t.mss = t.ss./t.df;
t.mse = t.sse./t.dfe;


% can't calculate lof
if ( t.df==0 )
    t.pval = 1;
    t.ftest = nan;
else
    t.ftest = t.mss./t.mse;
    t.pval = 1 - fcdf(t.ftest, t.df, t.dfe );
end;

t.source = {'lack of fit' };