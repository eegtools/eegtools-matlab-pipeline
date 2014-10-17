function [ls, fit] = solve( A, y, cmat )
%SOLVE solve an optionally constrained linear model 
%
%function ls = solve( glm )
%   finds the least-squares solution to linear model in glm
%   See alsoe encodef
%function ls = solve( A, y, cmat)
% Finds the least squares solution for b
% in the linear equation
%   A*b = y
% where
%   cmat*b = 0;
% cmat, a constrains matrix, is optional.
% It is commonly used to constrain b to
% some particular solution so that sets of
% parameter estimates sum to 0.
%
% returns b, the parameter estimates
% and optionally the results from the
% qr decomposition along with the
% reduced forms of y and A
% the return parameters are likely to
% change to be more compatible with
% matlab stats toolbox functions
%
% See also regress, regstats, mstats, encode
%
% Example:
%   load carbig
%   glm = encode( MPG, 3, 2, Origin );
%   s = solve(glm);
%   tbl = table( {'source', 'estimate'}, s.source, s.beta );
%   jplot_table(tbl);

% $Id: solve.m,v 1.13 2006/12/26 22:53:20 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if ( nargin < 3 )
    cmat = [];
end;

if isstruct(A)
    cmat = A.cmat;
    y    = A.y;
    glm  = A;
    A    = A.dmat;
    ls.source = glm.coeff_names;
else
    glm.dmat = A;
    glm.cmat = cmat;
    glm.y    = y;
end;

if ( ~isempty(cmat) && ~sum(cmat(:))==0)
    c0 = constrain(cmat);
    A0 = A*c0;
else
    cmat = [];
    c0 = [];    % this should be n x m diag matrix
    A0 = A;
end

[nrows] = size(A,1);

if ( size(y,1) ~= nrows )
    error('linstats:solve:InvalidArgument', 'the response variable and design matrix must be the same length');
end


[q,r,e] = qr(A0,0);

%estimate rank, n, after qr
d = abs(diag(r));
if (nrows == 1 )
    d = r(1);
end;
tol = 100 * eps(class(d)) * max(size(r));
n = sum(d > tol*max(d));

if ( n < size(A0,2) )
    warning('linstats:solve:SingularMatrix', 'singular matrix to working precision');
    % do I need to rotate these back 
    % it is involved but straight forward
    % I need the null space of cmat from null(cmat, 'r')
    % then I need to project A using this null space
    % then get the q,r frm the projected A
    % then get the lindc of r
    % then rotate b back
    b = lindc( r );
    ls.singularity = b;
end;


q = q(:,1:n);
r = r(1:n,1:n);
e = e(1:n)';

% solve for b.
yr = q'*y;
b = zeros( size(A0,2), size(yr,2) );
b(e,:) = r \ yr;       % fit rotated y to projected design matrix

% full form if necessary
if (~isempty(cmat) )
    b = c0*b;
end;

% return reduced form of A
Ar = q'*A;


ls.beta = b;

ls.dft  = size(y,1)-1;
ls.dfr  = n-1;              % residual degrees of freedom
ls.dfe  = ls.dft - ls.dfr;  % error degrees of freedom

ls.Q(:,e) = q;
ls.R(:,e) = r;
ls.c0     = c0;
ls.Ar   = Ar;       % reduced form of input A
ls.yr   = yr;       % reduced form of input y

if (nargout > 1 )
    % some more details and diagn
    fit.yhat         = A*b;


    fit.resid       = y - fit.yhat;
    y0             = center(y);
    fit.sst        = sum(y0.^2);
    fit.sse        = sum(fit.resid.^2);
    fit.ssr        = fit.sst - fit.sse;

    fit.mse        = fit.sse/ls.dfe;
    fit.rsquare    = fit.ssr/fit.sst;
    fit.rsquare_adj = 1 - ls.dft*fit.mse/fit.sst;

    fit.covb   = fit.mse.*inv(ls.R'*ls.R);

    %expand covb to full (overdetermined form)
    if ( ~isempty( c0 ) )
        n = size(c0,2);
        if ( length(fit.covb) < n )
            fit.covb(n,:) = 0;
            fit.covb(:,n) = 0;
        end;
        fit.covb   = c0*fit.covb*c0';
    end;
    
    % standard error of the coefficient estimates
    fit.se     = sqrt(diag(fit.covb));
    % t staticis for the estimates
    fit.t      = ls.beta./fit.se;
    
    alpha     = 0.05;
    tcrit     = tinv( 1 - alpha/2, ls.dfe );
    fit.ci     = tcrit.*fit.se;
    
    % f statistic for the model fit
    fit.f      = (fit.ssr/ls.dfr)/fit.mse;
    fit.pval   = 1 - fcdf(fit.f, ls.dfr, ls.dfe);
    
end
