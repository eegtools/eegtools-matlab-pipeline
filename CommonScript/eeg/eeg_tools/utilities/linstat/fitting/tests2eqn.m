function source = tests2eqn( glm, tests, reference, short_form )
% TESTS2EQN  produces names for anova tests (helper for anova)
%
% function source = tests2eqn( glm, tests, reference )
% 
% In the function 'anova' tests are encoded in matrix form. 
% For readability (and debugging) this function is provided to convert
% the matrices into a human readable form.
% 
% An anova test compares two models. One model, the full model, is reduced
% compared to the other model, reduced model, in that it contains a subset
% of the terms in the reference model. The terms that are left out are the
% terms that are being tests.
% See gettests 
%
% input
% each row of test is a matrix of terms that will dropped from the model. A
% value of 1 indicates that the corresponding term will be dropped, and
% this will become the reduced model. It will be compared to a reference
% model (full model), which is specified in another row in the tests
% matrix. Each reduced model is compared to a full model, which is another
% row in the tests matrix. The row is given in the vector 'reference'. Thus
% the reference vector specifies the number of tests to be done. If there
% are n tests  then the first n rows of the tests matrix specify the
% reduced models and the ith reduced model is compared to the row in
% reference(i). Thus, the two models in the ith anova test are tests(i,:)
% and tests(reference(i),:)
% 
% How to read output
%   for example say there are three terms in the model, x1,x2,x3
%   x1|x2,x3     - test the effect (reduction in sse) by adding the term
%                  x1 to a model already containing x2 and x3
%   x1,x2|x3     - test the effect of adding x1 and x2 to a model already
%                  containing x3
%   x1|Intercept - test the effect of adding x1 to the null model 
%   x1(x2)|x3    - test the effect of adding x1 to a model containing x3
%                  leaving out the effect of x2
% 
% Example
%   load carbig
% glm = encode( X, 3, 2, Origin, Cylinders );  % Cylinders is explanatory variable
% [tests, reference] = gettests( glm, 1 );
% tests2eqn(glm, tests, reference )
% [tests, reference] = gettests( glm, 3 );
% tests2eqn(glm, tests, reference )
% tests2eqn(glm, tests, reference, 1 )
% See also gettests, anova, model2eqn

% $Id: tests2eqn.m,v 1.6 2006/12/26 22:53:22 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% todo
%   a simple gui for specifying a model
%   assumption is made that intercept is present in the model, or that it
%   is never explicitly tested
%   does not work as expected with arbitraty model, e.g. [0 0; 1 0; 1 1];

% number of tests
ntests = length(reference);

% get term names from full model
hasIntercept = glm.hasIntercept;
tn = model2eqn(glm.model, glm.var_names, '*');
if hasIntercept
    tn(1) = [];
end;

% reference models
rmodel = tests(reference,:);

% test (reduced) models
tmodel = tests(1:ntests,:);

% terms dropped relative to the reference model
dropped_terms = ~rmodel - ~tmodel;
 
% names of terms left out of test but that are in reference model
dropped_names =  model2eqn( dropped_terms, tn, ',', '' );


% get names of terms in both the test and reference models. 
% these are prior terms in that we are testing the effect of the
% dropped terms given that these prior terms are in the model
% 
prior_terms   = double(~tmodel&~rmodel);
prior_names = model2eqn( prior_terms, tn, ',' );
prior_names = strcat('|',prior_names);

% get nested terms 
% these terms are in dropped in both the reference and test models
nested_terms = tmodel&rmodel;
nested_names = model2eqn( nested_terms, tn, ',', '' );
i = any(nested_terms,2);
nested_names(i) = strcat( '(', nested_names(i), ')');

source = strcat( dropped_names, nested_names, prior_names );


if nargin > 3  && short_form == 1
    source = regexprep( source, '\|.*$', '' );
end;
    