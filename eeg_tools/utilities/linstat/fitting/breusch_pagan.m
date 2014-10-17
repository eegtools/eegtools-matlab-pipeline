function p = breusch_pagan( glm )
%BREUSCH_PAGAN constant variance tests for categorical models
%
% Example
%    p = breusch_pagan( glm )
%        returns the probability from the breush_pagan test that the
%        difference in variance between groups could have occurred by
%        chance given that they were truly equal.
%        glm is a linear model created using encode
%
% See also brown_forsythe, encode
%
% reference "Applied Linear Statistical Models" Kutner et al, 2005

% $Id: breusch_pagan.m,v 1.5 2006/12/26 22:53:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


n = length(glm.y);

% solve the given equations. 
ls = mstats(glm);
sse = ls.sse;

% regress resid^2 against x. 
glm.y = ls.resid.^2;
ls2  = mstats( glm );
ssr = ls2.ssr;

X2 = (ssr/2)/((sse/n).^2);

p = 1 - chi2cdf( X2, 1 );





