function z = roc_compare( auc, se )
%ROC_COMPARE compares the area under multiple AUCs
%
% z = roc_compare( auc, se )
% AUC is a m x 1 vector or estimated areas under roc curves 
% SE  is a m x 1 vector of standard errors for the AUC estiamtes
% returns Z a vector of standardized distances (z-scores)
% representing the upper triangle of a square comparison matrix 
%
% see also roc_calc, roc_plot, pdist

% $Id: roc_compare.m,v 1.2 2006/12/26 22:54:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

z = pdist( [auc(:), se(:)], @roc_dist );



function d = roc_dist( x, y )
% each x and y contain
% x is one auc +/- se
% y can be one or more in each row

d = abs( y(:,1) - x(:,1) )./(sqrt( x(:,2).^2 + y(:,2).^2) );

