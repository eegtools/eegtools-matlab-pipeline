function [h,tbl] = sov_plot( a )
%SOV_PLOT a bar plot of sources of variability 
%
% h = sov_plot( a )
%   a is a structure from anova
%   returns h, a handle to the plot
%
% Example
%   load carbig
%   glm = encode( MPG, 3, 1, Origin, Cylinders );         
%   explanatory variable
%   a = anova(glm);
%   sov_plot(a);

% $Id: sov_plot.m,v 1.4 2006/12/26 22:53:29 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

newplot;

y = [nanmean( a.mss,2); nanmean(a.mse,2) ];

xl = regexprep(a.source,'\|.*$','');
h = bar( y );
set(gca,'xticklabel', cat(2,xl', 'mse') );
ylabel('Average Marginal Error' );
title('Sources of Variation');

tbl = table( {'source', 'MSS'}, [xl' 'mse']',  y );

