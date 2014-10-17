function [lsm, L] = lsestimates( glm, term, response, alpha )
%LSESTIMATES - least squares estimates for model parameters
% lsm = lsestimates( glm, term, response, alpha )
%      glm is a model created with encode. 
%         this is only intended to be used in models with no continuous
%         variables (see note below for anacova models). It properly
%         supports only overdetermined forms. 
%      term is an optional scalar of vector selecting terms from glm.term
%              0 = intercept. If absent, all parameters are estimated
%      response is a integer or logical scalar or vector selecting a
%         subset of response variables. response must be less than
%         size(glm.y,2);
%         alpha sets the significance level for testing whether parameters
%         equal zero. 
% returns lsm, a statistics structure with the means in beta. 
%         L, a linear combination of parameters that make up the estimate,
%         which can be useful for constructing other related contrasts
%       
%Example
%   % Example:
%       load carbig
%       glm     = encode(MPG, 3, 1, Cylinders);
%       [lsm L] = lsestimates(glm); % get least-squares estimated
% NOTES for ANACOVA models
% The meaning of lsestimates is not very clear for ANACOA
% models, because the values of the continous variable changes
% so does the ls estimates. In other words the average response changes depending
% on the value of the continous variable, so which level should we adopt?
% Sometimes a neutral value is used 

% $Id: lsestimates.m,v 1.10 2006/12/26 22:53:17 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 




if nargin < 4
    alpha = 0.05;
end

if nargin >= 3 && ~isempty(response)
    glm.y = glm.y(:,response);
end;


% estimate parameters and covariance 
lsm = mstats(glm);

% build linear combinations of coefficients
% that will give the ls estimates for each level

% Test any code changes with models including
% 2nd and 3rd order interactions

% order of the ith term in the model
order = sum(glm.emodel,2);

% pad to make this square
order = repmat( order, 1, length(order) );

% build a matrix of linear combinations of 
% coefficients that will yield the desired
% least squares estimates
L = double(glm.emodel*glm.emodel' == order);

lsmeans = L'*lsm.beta;

lsm.beta = lsmeans;             % overwrite the beta from the fit

% % return without stats if there is more than one response
% if ( size(glm.y,2) > 1 )
%     return;
% end;

% To calculate the se, which is sqrt(variance)
% note that the variance of a constant*variable
% is given by
% var(k*x) = k.^2*var(x). 
% or for a variance-covariance matrix
% var(K*X) = K'*X*K

se    = sqrt(lsm.mse'*diag(L'*lsm.vinv*L)')';
 

%% confidence intervals
tcrit = tinv( 1 - alpha/2, lsm.dfe );
lsm.ci = tcrit.*se;
lsm.se = se;
lsm.t  = lsmeans./se;
lsm.pval = 2*tcdf( -abs(lsm.t), lsm.dfe );

M = glm.model;
if nargin >= 2 && ~isempty(term)
    i = M(term+1,:)==1;
    if ~all(glm.var_types(i) > 0)
        error('lsestimates are only available for categorical variables');
    end
    dfr = glm.df0(term);
else
    % find all terms that don't include continuous variables
    icov  = glm.var_types <= 0;
    term = find(~any(M(:,icov)==1,2))-1;
    
    % assume intercept term
    dfr = [lsm.dfr glm.df0(term(2:end))];
end
   
% extract just the values of interest
k = find(ismember(glm.terms,term));
lsm.beta= lsm.beta(k,:);
lsm.t   = lsm.t(k,:);
lsm.se  = lsm.se(k,:);
lsm.ci  = lsm.ci(k,:);
lsm.pval= lsm.pval(k,:);
lsm.source = lsm.source(k);
lsm.dfr    = dfr;

if isfield(ls,'singularity')
    lsm.singularity = lsm.singularity;
end;




