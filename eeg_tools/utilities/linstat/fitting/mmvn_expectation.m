function [logL E p] = mmvn_expectation(X, varargin)
%MMVN_EXPECTATION mixture multivariate expectation 
%
% calculates an expectation that each obs belongs to each class
% 
% Example:
% logL  = mmvn_expectation(X,theta)      % provide mmvn struct
% logL  = mmvn_expectation(X, M, );      % provide M 
% logL  = mmvn_expectation(X, M, V);     % provide M and V
% logL  = mmvn_expectation(X, M, V, W);  % provide M, V, and W
%         see mmvn_gen for calling syntaxes
% returns logL the average log of the likelihood for each observation
% [logL E p] = mmvn_expectation(...);
%           also returns E, the scaled probabilities (each row sums to 1)
%           also returns p, the sum of the probabilities
%
% See also mmvn_gen
%

%% $Id: mmvn_expectation.m,v 1.8 2006/12/26 22:53:18 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

theta = mmvn_getTheta(varargin{:});

E = mmvn_pdf( X, theta );


% scale so sum(E,2) = 1;
p = sum(E,2);
p(p==0) = realmin;              % smallest p val we can represent. 
                                % E will still be 0, but logL wont be -Inf

logL = nanmean(log(p));
                                
if nargout > 1
    % TODO if all(E==0,2) it should probably be set to the previous W so that each obs still
    % sums to 1 and the weighted mean is calculated properly
    E = E./repmat(p,1,size(E,2)); 
end;


