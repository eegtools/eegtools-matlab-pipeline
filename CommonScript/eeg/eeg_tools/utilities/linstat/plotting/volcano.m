function [xt, h] = volcano( logratio, pval )
%VOLCANO a volcano plot of probabilities and effect size
%
% volcano plots are used to visualize statistically significant events when
% there are hundreds (or more) tests being conducted.
%
% [xt, h] = volcano( logratio, pval )
% prepares volcano plot with foldChange on the x-axis and pvalue on the
% y-axis pvalue range from 0 to 1 returns fold change thresholds for which
% all other similar fold changes in the data set exceed the pval thresholds
% The preset thresholds are 0.001, 0.01, 0.05, .1
%
%Example
%  x = randn( 1000, 10 );               % 10,000 tests each with n=10 
%  x(1:50, 6:end) = x(1:50,6:end) + 3;  % 50 tests are true positives
%  groups = repmat( 1:2, 5, 1 );        % grouping index
%  groups = groups(:);
%  glm = encode( x', 3, 1, groups );    % linear model for anova. assume x
%                                       % are log2 transformed
%  a = anova(glm);                      % anova
%  volcano( 2*a.beta(2,:), a.pval )     % plot effect of groups 1/2 (<1)
%
% See also foldChange, 


% $Id: volcano.m,v 1.6 2006/12/26 22:53:30 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



crit = [.1 .05 .01 .001]';

% prepare plot
newplot

% calculate fold change
x = foldChange(logratio);
% fold changes go from [-Inf -1] and [1 to Inf] 
% so take out the gap in middle for plotting
x = x  - 1*sign(x);

% prepare a linear axis for the p-values
% divide by 2 so that z doesn't go below zero
i = pval==0;    % avoid Inf z scores 
pval(i) = min(pval(~i));    

z = -norminv(pval/2);

%% color by p-value
hh = scatter( x, z, z.^2, z, 'filled' );

% label the y-axis (new style); 
% turn grid on for threshold values
set(gca, 'ytick', -norminv(crit), 'yticklabel', crit, 'ygrid', 'on' );

% draw thresholds for fold-change. These are the 
% fold-change values for which  all such fold changes and greater give a
% exceed a p-value threshold

% sort x values by absolute fold change
[fc,o] = sort(abs(x), 'descend');
fc = x(o);
% same ordring for pvalues
ps = pval(o);
% for each pval threshold find the first fc that where all such
% fold changes exceed threshold
xx = zeros( length(crit));
for i = 1:length(crit);
    xx(i) = draw_fc_threshold( fc, ps, crit(i) );
end;

% reset to auto in case this plot is 'hold on'
% otherwise the xticklabels will change with each call;
set( gca, 'xticklabelmode', 'auto');
xl = str2num(get(gca,'xticklabel')); %#ok
xl = xl + sign(xl);
set(gca,'xticklabel', xl);
xlabel('fold change');

% only assign output if requested
if nargout > 0
    xx = abs(xx + sign(xx));
    xt = xx;
    h = hh;
end;



function [x,h] = draw_fc_threshold( fc, ps, alpha )
hold on;
x = nan;
i = find(ps>=alpha,1);
if ~isempty(i)
    ll = get(gca,'ylim');
    x = fc(i);
    h = plot( [x x], [norminv(1-alpha), ll(1)],  'k:', [-x -x], [norminv(1-alpha), ll(1)], 'k:' );
    % h = plot( [x x], ll,  'k:', [-x -x], ll, 'k:' );
end;

   
