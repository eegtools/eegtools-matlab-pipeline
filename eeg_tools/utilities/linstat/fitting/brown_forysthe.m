function [p, a] = brown_forysthe( glm )
% BROWN_FORYSTHE constant variance test for continuous x. 
%
% See also breusch_pagan, encode
%
% Example
% p = brown_forysthe( glm )
%     returns a p value from the test that the errors are equal
%         
%
% $Id: brown_forysthe.m,v 1.6 2006/12/26 22:53:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

n  = length(glm.y);
ls = mstats(glm);


%divide into at least 2 groups or if more than 60
%length up to 30/group or if more than 900 then 30 groups
ngroups = min( max(2, floor(n./30) ), 30 );
edges   = linspace(0,100,ngroups+1);
p = prctile( ls.yhat, edges );
[n,bin] = histc( ls.yhat,p );
bin(bin==ngroups+1) = ngroups;

y0 = nan(size(ls.yhat));

% calculate median absolute deviation by group
med = nan(ngroups,1);
for i = 1:ngroups
    k = bin==i;
    med(i) = median( ls.yhat(k) );
    y0(k) = abs(ls.yhat(k) - med(i));
end;

% test whether y0 equal all groups
groups = bin;
glm0 = encode( y0, 3, 1, groups );

a = anova(glm0);
p = a.pval;










