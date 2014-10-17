function model = lmodel(nterms,order)
%LMODEL returns common linear design matrices
%
%Example 
% model = lmodel(nterms,order)
% returns a standard matrix representation of a model
% with the given number of predictor variables (terms)
% and of the given order of interactions
%
% the model is either a scalar or a matrix of terms. If it is a scalar it
% refers to the order of the model. 1 indicates a 1st order model which
% contains only main effects. A 2nd order model contains main effects and
% all pairwise interactions. For more complex models a matrix of terms can
% be used. Each row of the matrix represents one term a factor effects
% model. Each column represents a predictor variable. A column containing a
% non-zero value will be included in the given term of the model
% mean of "order"
%   0 = linear with no intercept (eye(nterms)) - not implemented
%   1 = linear without interaction
%   2 or more = up to "order-1"th level interactions are models
%               or fewer if there aren't enough variables
% See also encode, x2fx

% $Id: lmodel.m,v 1.3 2006/12/26 22:53:16 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



if nargin < 2 || isempty(order)
    order = 1;
end;

if ( order > nterms )
    order = nterms;
end;

% intercept term
if (order == 0)
    model = eye(nterms);
else
    model = [zeros( 1, nterms ); eye(nterms)];
end;


% build model
for i = 2:order
        cind = nchoosek(1:nterms,i);
        rows = size(cind,1);        
        rind = repmat(1:rows,1,i);
        ind  = sub2ind([rows nterms], rind(:), cind(:));
        t    = zeros( rows, nterms);
        t(ind) = 1;
        model = [model;t];
end