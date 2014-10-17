function ls = mstats( glm, y, cmat )
%MSTATS least squares solution and statistics for linear model
%
% function ls = mstats( glm, y, cmat )
% produces least-squares solution to the linear model by calling solve
% and produces some extra diagnostics. NaNs in the input are not encouraged
% usage
%   ls = mstats(glm);
%        glm is the output structure from the function encode
%   ls = mstats( X, y )
%   ls = mstats( X, y, cmat)
%        cmat contains a constraints matrix. Each row describes a 
%        set of coefficients in the model that must some to zero
% output
%   ls is a structure containing the same members as the output of solve
%   plus 
%       yhat    - a vector of predicted responses A*b
%       resid   - a vector of residual errors y - yhat;
%       hatmat  - the hat matrix (the diagnol of which is the leverage
%                 matrix)
%       sst     - total sums of squares for the response
%       sse     - sums of squared residuals
%       ssr     - sums of the squared yhat = sst-sse
%   if there are multiple response, then some fields will be absent
% Example:
%   load carbig
%   glm = encode( MPG, 3, 2, Origin );
%   s = mstats(glm);
%   tbl = estimates_table(s);
%   jplot_table(tbl);

% $Id: mstats.m,v 1.14 2006/12/26 22:53:20 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% deciper the form of mstats being used and call solve
if (nargin == 1 )
    ls = solve(glm);
    y = glm.y;
    A = glm.dmat;
elseif nargin == 2
    ls = solve(glm,y);
    A = glm;
else
    ls = solve(glm,y, cmat);
    A = glm;
end


% some diagnostics
ls.yhat       = A*ls.beta;
ls.resid      = y - ls.yhat;


y0            = center(y);
ls.sst        = sum(y0.^2);
ls.sse        = sum(ls.resid.^2);
ls.ssr        = ls.sst - ls.sse;

ls.mse            = ls.sse./ls.dfe;
ls.fit.rsquare    = ls.ssr./ls.sst;
ls.fit.rsquare_adj= 1 - ls.dft.*ls.mse./ls.sst;


% if there are multiple response then we've 
% done all the bulk processing we can.
% Maybe NOT! why can't you take ls.mse out of the
% equation below and move it later so that the
% other variables can be calculated as well. 
% if ( size(y,2) ~= 1 )
%     return;
% end;

% ls.covb   = ls.mse.*inv(ls.R'*ls.R);

covb = inv(ls.R'*ls.R); % put in mse below

%expand covb to overdetermined form
if ( ~isempty( ls.c0 ) )
    n = size(ls.c0,2);
    if ( length(covb) < n )
        covb(n,:) = 0;
        covb(:,n) = 0;
    end;
    covb   = ls.c0*covb*ls.c0';
end;

ls.vinv   = covb;

% calculate the se, t, ci and p values for the
% parameter estimates
ls.se     = sqrt(ls.mse'*diag(covb)')'; % add mean squared erro
ls.t      = ls.beta./ls.se;
alpha     = 0.05;
tcrit     = tinv( 1 - alpha/2, ls.dfe );
ls.ci     = tcrit.*ls.se;
ls.pval   = 2*tcdf( -abs(ls.t), ls.dfe );
% ls.pvalg0 = tcdf( -ls.t, ls.dfe );        % used for 1-sided test of
% coefficients
% ls.pvall0 = tcdf( ls.t, ls.dfe );

% put in fields for stats_table
if ( isstruct(glm) )
    ls.source = glm.coeff_names;
else
    ls.source = [];
end;

% calculate the F and P-value for the
% model fit
if ls.dfr > 0
    ls.fit.ftest  = (ls.ssr./ls.dfr)./ls.mse;
    ls.fit.mss    = ls.ssr./ls.dfr;
else
    ls.fit.ftest  = nan;
    ls.fit.mss    = nan;
end;
ls.fit.pval   = 1 - fcdf(ls.fit.ftest, ls.dfr, ls.dfe);
ls.fit.ss     = ls.ssr;
ls.fit.df     = ls.dfr;
ls.fit.sse    = ls.sse;
ls.fit.dfe    = ls.dfe;
ls.fit.mse    = ls.mse;
ls.fit.sst    = ls.sst;
ls.fit.dft    = ls.dft;
ls.fit.source = {'model'};


% SAVE this for a different function
% often h == 1 and so I get a divide by zero error
% also ls.Q is for the reduce matrix and must be expanded
% 
% %% studentized resids
%   
% h = diag(ls.hatmat);
% s2_i = (ls.dfe.*ls.mse - ls.resid.*ls.resid./(1-h))./(ls.dfe-1) ;
% ls.st_resid = ls.resid./sqrt(s2_i.*(1-h));

