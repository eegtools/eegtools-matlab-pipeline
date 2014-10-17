function x = decode( glm, terms )
% DECODE decodes a model into index dummy variables 
%
%Example
% x = decode( glm, terms )
%     glm is a categorical model in 0/1 overdetermined form
%     terms is an optional vector of terms to be decoded. The default
%     is to decode all terms
%     x is unique factor levels for each term
%     It is the inverse of encode when used with overdetermined encoding
%
%Example
% use decode to construct level names for interaction terms
% load popcorn
% glm       = encode( y, 3, 2, cols, rows );
% cnames    = glm.coeff_names(glm.terms==3); 
% dmat      = decode(glm,3);
% levels    = ind2grp(dmat, cnames );
%
% See also encode, ind2grp
%

% $Id: decode.m,v 1.8 2006/12/26 22:53:14 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

% to do
%   support other encodings (using unique? or rotating)
%   throw error with continuous variables




model = glm.model;
if (nargin < 2)
    nterms= size(model,1) - glm.hasIntercept;          % decode all terms in the model
    terms = 1:nterms;
else
    nterms = length(terms);             % number of terms to decode
end

nvars = size( glm.ivar,2);              % number of variables that have
% been directly encoded
nobs  = size(glm.dmat,1);
x     = zeros( nobs, nterms);


for i = 1:nterms
    j = find( model( terms(i)+glm.hasIntercept,:) );   % get the variables used in this term
    if length(j)<2 && j <= nvars
        icol = glm.ivar(:, j);
    else
        % find will return the row and column indices
        % of non zeroes entries in dmat.
        % I want the column index so I use the transpose
        % of dmat. icol will be the non-zero column, and
        % since every row of dmat has at least one
        % non-zero column, irow will be uniformly increase
        % vector equal to 1:nobs
        
        % irow is needed even though it isn't used
        [icol,irow] = find( glm.dmat(:,glm.terms==terms(i))' );
    end
    if (isempty(icol) )
        x(:,i) = 1;
    else
        x(:,i) = icol;
    end
end



