function glm  = subtract_effect( glm, terms )
% SUBTRACT_EFFECT subtracts the effect from the response
% 
% subtracting an effect has no effect on an anova from the remaining
% effects. it is useful for eliminating blocking variables in new models
% and for use in PCA, where you can see how the principal components would
% look holding blocked variables constant
%
% function [glm]  = subtract_effect( glm, terms )
% solve the linear model in glm to obtain least-squares 
% estimates for each level of the given terms
% the parameter estimates for the given terms are subtracted
% from the responses having the same level
% this function relies on decode and will only work 
% properly with over-determined encoding of 
% the design matrix. (See encode)
% assumes there is an intercept term present
%
% Example:
%   load carbig
%   X = [MPG Acceleration Weight Displacement];  % response variables
%   glm = encode( X, 3, 1, Origin, Cylinders );  % Cylinders is explanatory variable
%   anova_table(anova(glm))
%   glm = subtract_effect(glm,1);                % subtrct Origin
%   anova_table(anova(glm))   
%
%   see also encode, anova

% $Id: subtract_effect.m,v 1.7 2006/12/26 22:53:21 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% TODO
% make this work with other encodings. Since they are linear
% combinations of each other this shouldn't be insurmountable


% if (any(glm.var_types(terms) ~=3) )
%     error('linstats:subtract_effect:InvalidArgument', 'only supports overdetermined encoding (form 3)');
% end;

if isempty(glm.y)
   error('linstats:subtract_effect:InvalidArgument', 'the model needs a response variable (set glm.y)' );
end;

glm.ls = solve(glm);

% t is a column index vector into the parameter estimates
% it is the same length as y
D = decode(glm);

for i = 1:length(terms)
    t = D(:,terms(i));
    % offset because column 1 of coefficients is for grand mean
    t = t + find(glm.terms==terms(i),1) - 1 ;   

    % create intensities that are adjusted for tissue affects
    glm.y = glm.y-glm.ls.beta(t,:);
end;






