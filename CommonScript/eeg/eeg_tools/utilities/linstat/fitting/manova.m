function stats = manova( glm )
%MANOVA multivariate analysis of variance
% m = manova( glm )
%
% glm is the output of encode
% 
% The tests are based on the eigenvalues of inv(sse)*ssr
% this is analagous to the univariate test (f-test) where the tests are
% based on the statistic (1/sse)*ssr. However the distribution in the
% multivariate case is complex and sometimes there is only an approximation
% returns a stats structure for each term. In any case several
% approximations are returned. If they all agree, it is a special case
% (somewhat common)
% where an exact f is available. 
%   v   - eigenvectors
%   e   - eigenvalues
%   dfr - degrees of freedom for the numerator in an approx f-test
%   dfe - degrees of freedom for the denominator in an approx f-test
%   col_names - description of the columns in the results table
%   test_names - description of the tests used
%   value      - value of the test statistic
%   f          - approximate f
%   pval       - p-value from f-test
%
% other return values are similar to univariate tests
% but are generalized to include cross-products. 
% so instead of a k-vector there is a pxpxk matrix
% sse is the error matrix, sometimes called E
% ssr is the regression from the whole model , sometimes called H
% sst is the total variation, sse+ssr 
% ss  is the regression ss explained by each term in the model
%
% NOTE repeated measures can be achieved by multiplying the response
% variables by the contrasts matrix 
%  glm.y = glm.y*getcontrasts(k,3), where k is the
%          number of columns originally in glm.y
%          in this case the statistics refer to the interaction of column
%          effects (often timeseries) and other factors in the model.
%
% Example:
% load carbig;        % load data
% X = [MPG Acceleration Weight Displacement];  % response variables
% glm = encode( X, 3, 1, Origin );         % Origin is explanatory variable
% m   = manova( glm );                       % manova    
% see also encode, anova


% $Id: manova.m,v 1.12 2006/12/26 22:53:17 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



[n,q] = size(glm.y);

if nargin<2
    M = eye(q);
end;

p = size(M,2);

if ( q > n )
    error('linstats:manova:SingularMatrix', ...
          'there must be more observations than variables');
end

% -squares solution
lsq      = mstats(glm);
stats.beta     = lsq.beta;
stats.dft      = size(glm.y,1)-1;   % or sum of weights
stats.dfe      = lsq.dfe;
stats.dfr      = lsq.dfr;


%% Whole Model
% this is just the total ss and products
sst = M'*(cov(glm.y).*glm.dft)*M;
sse = M'*(lsq.resid'*lsq.resid)*M;
ssr = sst - sse;

%% Between Group Sum Squares and Cross Products
% ss type III tests
[tests, reference] = gettests( glm, 3 );

nmodels = size(tests,1);
ntests  = length(reference);


cmat = glm.cmat; % copy for convience
dmat = lsq.Ar;   % reduced form of design matrix
y0   = lsq.yr;   % reduced form of the response

df   = zeros( 1, nmodels+1);
sswo = zeros( size(y0,2), size(y0,2), nmodels+1);

% leave out each term and calculate its marginal
% reduction in the sum of squared errors
for i = 1:nmodels
    j = ~ismember( glm.terms, find(tests(i,:) ));
    
    % testing the intercept is equivalent to comparing
    % two models: 1) with all terms except intercept to the
    % full model which includes all terms and the intercept
    ls =  solve( dmat(:,j), y0, cmat(:,j) );
    df(:,i) = ls.dfr;
    sswo(:,:,i) = M'*(ls.yr'*ls.yr)*M;
end;

% ssr for full model
% this isn't flexible in that it assumes nmodels+1 is full model
sswo(:,:,nmodels+1) = ssr;
ss   = sswo(:,:,reference) - sswo(:,:,1:ntests);

% calculate degrees of freedom for the term
% which is (df with reference model) - (df without term)
df(:,nmodels+1) = lsq.dfr;
df =  df(:,reference) - df(:,1:ntests);


% dfe is calculated above as well,
% but here we know the actual rank
% of each term
dfe = lsq.dft - sum(df,2);
stats.dfe = dfe;

stats.df   = df(1:ntests);

% build a text representation of the tests
if ( isfield( glm, 'var_names') )
    stats.source = tests2eqn( glm, tests, reference );
end;

stats.sst = sst;
stats.ssr = ssr;
stats.sse = sse;
stats.ss  = ss(:,:,1:ntests);
stats.canon = zeros( [size(glm.y) ntests] );

% calculate rank of H+E matrices
% for each term
nterms = size(stats.ss,3);
for i = 1:nterms
    p(i) = rank( stats.ss(:,:,i) + stats.sse );
end;

% setup source information
source           = stats.source;
stats.source     = regexprep( source, '\|.*$', '');
stats.col_names  = {'test', 'value', 'f', 'dfr', 'dfe', 'prob>F'};
stats.test_names = {'Wilk''s Lambda', 'Pillai''s Trace', 'Hotelling-Lawley Trace', 'Roy''s Max Root'};


q  = stats.df; % term specific degrees of freedom for the design
v  = stats.dfe;
s  = min(p,q);
m  = .5*(abs(p-q)-1);
n  = .5*(stats.dfe-p-1);

t = ones(size(q));
tt = (p.^2+q.^2-5);
i = tt>0;
t(i) = sqrt( ((p(i).*q(i)).^2 - 4)./tt(i) );
r = v - (p-q+1)./2;
u = (p.*q - 2)./4;


% error degrees of freedom for approx f test for Wilk's lambda
f_dfe = t.*r - 2.*u;    

% [ p; q; v; s; m; n; r; u; t ];  % optionally disp for debug df calc
dfr   = [ p.*q ; s.*(2.*m+s+1);  s.*(2.*m+s+1);   max(p,q) ];
dfe   = [ f_dfe; s.*(2.*n+s+1);    2.*(s.*n+1);   stats.dfe-max(p,q)+q];
dr    = dfe./dfr;

v = zeros( size(stats.ss) );
y0 = center(glm.y);
e  = zeros( size(sst,1), ntests );
for i = 1:nterms
    % carefully calculate eigenvalues
    % using cholsky factorization
    [v(:,:,i),d]  = eig( stats.ss(:,:,i), stats.sse, 'chol');
    [e(:,i) ei]   = sort(diag(d), 'descend'); % sort eigenvalues
     v(:,:,i)     = v(:,ei,i);                % sort vectors 

     vt = diag((v(:,:,i)' * sse * v(:,:,i)))' ./ stats.dfe;
     vt(vt<=0) = 1;
     v(:,:,i) = scale(v(:,:,i), sqrt(vt));
     stats.canon(:,:,i) = y0*v(:,:,i);   
end;


% transform into an approx f statistic (4 different methods)
% they all converge under certain circumstances
% All methods are functions of the eigenvalues
value     =[ prod(1./(1+e));  sum(e./(1+e)); sum(e);        max(e) ];

lambda    = value(1,:).^(1./t);
F         = [ ((1-lambda)./lambda).*dr(1,:)
               (value(2,:)./(s-value(2,:))).*dr(2,:)
                value(3,:).*2.*(s.*n+1)./(s.^2.*(2.*m+s+1))
                value(4,:).*dr(4,:) ];

stats.evec    = v;
stats.eval    = e;
stats.value = value;
stats.dfr = dfr;
stats.dfe = dfe;
stats.F    = F;
stats.pval = 1-fcdf( F, dfr, dfe);










            
                

