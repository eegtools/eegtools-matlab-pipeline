function stats = anova( glm, tests, reference )
% ANOVA n-way analysis of variance and analysis of covariance
%
% note glm contains fields that are are not used in anova. The fields that
% are needed are
% glm.model - as in x2fx
% glm.dmat  - design matrix containing the encoded predictor variables. one
%             column for each parameter (including intercept) in the full
%             parameterized model
% glm.y     - response variable. There may be any number of independent
%             response variables and they will all be solved using the
%             identical predictor variables. This is useful where the same
%             model is applied to many sets of observed responses. In the
%             case of multiple responses, there may not be missing values.
% glm.cmat  - (if constraints are not needed this may be empty)
% glm.terms - groups the columns of the model matrix
%
%See also 
%   encode, gettests, manova
%
%Examples
%     load popcorn
%     glm       = encode( y, 3, 2, cols, rows );    % build linear model
%     a         = anova(glm);                       % sstype 3 anova tests
%     tbl       = anova_table(a)        % standard anova report
%     display(tbl);                     % print table to command window
%     jplot_table(tbl);                 % display results in java table
%     export('popcorn.anova.tab', tbl);         % export results to a file
%
%     a         = anova(glm, 1);        % sstype 1 (sequential) anova tests
%
%     % get a matrix representation for type 1 tests.
%     [tests, refs] = gettests( glm, 1 );
%     % modify tests and refs to build custom tests
%     a         = anova(glm, tests, refs);   % tests and refs allow for

%                   

% $Id: anova.m,v 1.16 2006/12/26 22:53:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% todo: change support for centered variables - after missing values are removed
% add support random and mixed effects models

if ( isempty( glm.y ) )
    error('linstats:anova:InvalidArgument', 'the model needs a response variable (set glm.y)' );
end

y = glm.y;

if (isvector(y))
    y = y(:);
end

stats.terms = glm.terms;
nterms = max(glm.terms);

%% Whole Model
% center the response variables
[y0, mu] = center(y);
glm.y    = y0;

% ss for the whole model.
sst              = sum(y0.*y0); 
sswo(:,nterms+2) = sst ;        % total sum of squared errors
stats.sst        = sst;

ls = solve(glm);
b  = ls.beta;

stats.Q = ls.Q;
stats.R = ls.R;

%if the model includes an intercept, then
%it is interpretted as the global mean, which
%was calculated above, mu
if (glm.hasIntercept)
    b(1,:) = b(1,:) + mu;
end;
stats.beta = b;

stats.ssr            = sum(ls.yr.^2);
stats.sse            = sst - stats.ssr;

stats.dft      = size(glm.y,1)-1;   % or sum of weights
stats.dfe      = ls.dfe;
stats.dfr      = ls.dfr;
% stats.ls       = ls;

cmat = glm.cmat;

% simplified but equivalent equations in that
% the residuals will be the same
dmat = ls.Ar;
y0   = ls.yr;

%% Build Test Models
% each test compares two models
% one model (the reference model) has
% more terms and therefore explains more of the
% variance (larger ssr)
% the second model (the reduced model) has
% fewer terms and therefore has a smaller ssr.

% the tests matrix indicate which terms to remove from the model
% another vectors, reference, shows which of the tests
% is the reference model to compare the test too
% type III always uses the full model as the reference
% Type I is heirarchical. It compares the full model
% to droping term 1. Then uses that as the reference
% and copmares to a model missing both terms 1 and 2 etc.
% Type i is a special case of a nested model

%default is type III
if (nargin < 2  || isempty(tests))
    tests = 3;
end;


if ( isscalar(tests) )
    [tests, reference] = gettests( glm, tests );
end;

nmodels = size(tests,1)-1;
ntests  = length(reference);

%% Solve Test Models
% leave out each term and calculate its marginal
% reduction in the sum of squared errors
df = zeros( size(sst,1), nmodels+1);

for i = 1:nmodels+1
    j = ~ismember( glm.terms, find(tests(i,:) ));
    ls =  solve( dmat(:,j), y0, cmat(:,j) );
    
    % this is the real degrees of freedom
    % computed from the rank of the design matrix
    df(:,i) = ls.dfr;   
    
    %% ssr for a model without this term
    sswo(:,i) = sum(ls.yr.^2,1);

end;

% the difference between the ssr
% reference and the ssr of the dropped term computes
% the contribution of the terms left out of the model
ss   = sswo(:,reference) - sswo(:,1:ntests);


% calculate degrees of freedom for the term
% which is (df with reference model) - (df without term)
% df(:,nmodels+1) = stats.dfr;
df =  df(:,reference) - df(:,1:ntests);


% compare the number of parameters we have to compute
% with the actual degrees of freedom. If they are 
% different we've got some empty cells. some parts may be estimable
% this is only a warning because some parts of the solution are still
% useful
if ( sum(glm.df0) ~= sum(df) )
    warning( 'linstats:anova:NotFullRank', 'some terms are not full rank' );
end;


% build a text representation of the tests
if ( isfield( glm, 'var_names') )
    stats.source = tests2eqn( glm, tests, reference );
end;

stats.df    = df(1:ntests);
stats.ss    = ss(:,1:ntests)';
stats.mss   = scale( stats.ss', stats.df)';
stats.mse   = scale(stats.sse, stats.dfe);
stats.ftest = scale(stats.mss, stats.mse);

% should I use the actual dfe from the least-square solution, 
% or this one, which is computed from df for each var in the model. 
% And if I do use dfe as written, should I change the stats.dfe to this
% value?
dfd = repmat( stats.dfe, ntests, size(stats.ftest,2) );
stats.pval =1 - fcdf( stats.ftest, repmat(stats.df',1,size(stats.ftest,2)), dfd );


