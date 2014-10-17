function [theta, isopt] = getTheta( mm )
% GETTHETA get model parameters in theta 
%
%  and a logical indicator, isopt of whether the parameter estimates have been optimizied
% 
% example
%     [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
%     mm = MModel(X, [1 2], 4 );      %  model 1st two dimensions
%     [theta isopt] = getTheta(mm)
%     mm = em(mm);
%     [theta isopt] = getTheta(mm)

% $Id: getTheta.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

theta = mm.bhat;
isopt = true;
if isempty(theta)
    theta = mm.b0;
    isopt = false;
end;
    
