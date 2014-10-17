function [yhat, missing] = impute( y, glm )
%IMPUTE imputes missing values using least-squares predictions
%
%Example
%   yhat = impute( y, glm  )
%          y is an m x n matrix of m observations in n variables
%            some values of y may be missing (NaN)
%          glm is a linear model specified by encode
%          yhat is a new set of response where the missing values in y have
%           been predicted using the linear model in glm
%           If the coefficients are not estimable
%           then NaN is returned for that yhat
%           Hint: You can always call impute again with a reduce model
%           to fill in where the first call didn't work 
%
%Example
%   load carbig
%   glm   = encode( [], 3, 1, Cylinders );  % model without reponse
%   yhat  = impute( MPG, glm );             % impute missing values
%   glm.y = yhat;   % use the imputed values in the model
%   a = anova(glm);
%
%See also encode, model_building_tutorial

% $Id: impute.m,v 1.6 2006/12/26 22:53:16 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


m = size(y,1);

if ( m ~= size(glm.dmat,1) ) 
    error('linstats:impute:InvalidArgument','each response variable, y, must have the same number of rows as the design matrix, glm.dmat');
end;

% for the moment assume no missing values 
yhat = y;

%find missing values
missing = isnan(y);

%find rows with missing values
gi = find(any(missing))';

%build model with present values
D = glm;


for i = 1:length(gi);
    
    %index of gene with missing values
    j = gi(i);
    k = missing(:,j);   
    
    if sum(k)==0; continue; end;
    
    %build model with the values that are present
    dmat = glm.dmat(~k,:);

    %and estimate coefficients
    ls = solve( dmat, y(~k,j), glm.cmat );

    %now estimate yhat using full model and estimated coefficients
    Y = D.dmat*ls.beta;
    yhat(k,j) = Y(k);
end;