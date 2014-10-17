function [tests, reference] = gettests( glm, sstype )
%GETTESTS help function to return test matrices used by anova 
%
% An anova test compares two linear models, reduced and reference. The
% reduced model is related to the refernce model with some terms omitted.
% This function creates matrices describing a set of these tests. It is
% called directly by anova when using popular sstypes or you can used this
% function to build a set of tests and then edit them.
%
%Example 
%  [tests, reference] = gettests( glm, sstype )
%   glm is a model created using encode
%   sstype is a scalar in (1..3)
%  tests is a matrix with each row representing a model. A one in a column
%  indicates that the term should be ommited from the model. A row with all
%  zeros is the full model. The vector reference contains one element for
%  each anova test and the value indicates which row of tests is the
%  reference model. Thus, the two models in the ith anova test are
%  tests(i,:) and tests(reference(i),:)
%
%
% See also model_inference_tutorial

% $Id: gettests.m,v 1.4 2006/12/26 22:53:15 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% to do
%   need to figure out how to automatically detect the proper nesting
%   terms


if (nargin< 2)
    sstype = 3;
end

ntests    = max(glm.terms);

if (sstype==1)
    reference = 2:ntests+1;
    tests     = fliplr( tril(ones(ntests)) );
    tests(end,:) = 1;
    tests = flipud(tests);
    tests(end+1,:) = 0;
elseif (sstype==3)
    %% sstype 3 is common to both ss2 and ss3
    reference = repmat(ntests+1,1,ntests);
    tests     = eye(ntests);
    tests(end+1,:) = 0;
elseif (sstype == 2)
    % sstype 2 tests the ith term against
    % a model that omits all higher level terms
    % containing the ith term
    
    % interaction degree
    m = ntests+ntests;
    reference = repmat(m,1,ntests);
    tests     = zeros( m, ntests) ;

    % ommit higher level terms
    for i = 1:ntests
        [t,r] = gettest( glm, i );
        rlevel = ntests+i;
        tests(i, : ) = t;
        if ( all(r==0) )
            continue;  % assume that once the reference is the full model, we are done
        end;
        reference(i) = rlevel;        
        tests(rlevel,  :) = r;
    end;
    
    m  = size(tests,1);
    ntests = length(reference);
 
    % build index of non-unique tests 
    i  = true(m,1);  % assume all are non-unique
    i(1:ntests) = 0; % we know the first ntests are unique
    i(reference) = 0;% we also assume the reference tests are unique 

    tests(i,:) = [];           % delete the non-unique
    a = (1:m)' - cumsum(i);    % calculate cumulative number of non-unique tests
    reference = a(reference);  % adjust indices for the number of non-unique tests
    
    
end



function [t,r] = gettest( glm, i )
% creates a tests of the ith term ommiting other higher
% level terms containing it
b = repmat( glm.model(i+1,:), size(glm.model,1),1);
t = all( (glm.model&b) == b, 2 )';
t(1) = [];
r = t;
r(i) = 0;

