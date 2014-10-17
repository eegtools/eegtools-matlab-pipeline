function roc_pdf( real, test_value, bins )
% ROC_PDF separate density plots for true and false positive samples
%
% [x,y] = roc_pdf( real, test_value, bins )
% construct two probability distributions one of each of the positive
% and negative samples
%
% Example
%      x = randn( 1000, 10 );               % 10,000 tests each with n=10 
%      x(1:50, 6:end) = x(1:50,6:end) + 3;  % 50 tests are true positives
%      groups = repmat( 1:2, 5, 1 );        % grouping index
%      groups = groups(:);
%      glm = encode( x', 3, 1, groups );    % linear model for anova. assume x
%                                           % are log2 transformed
%      a = anova(glm);                      % anova
%      truth = false(1000,1);               % create a vector with the truth
%      truth(1:50) = true;       
%      roc_pdf( truth, a.pval);    % use pvalue for test score
%
% See also roc_plot, roc_calc

% $Id: roc_pdf.m,v 1.5 2006/12/26 22:53:28 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[test_value, order ] = sort(test_value);
real = real(order);

true_neg = real == 0;
true_pos = real ~= 0;

result_for_neg = test_value( true_neg );
result_for_pos = test_value( true_pos );

if ( nargin < 3 )
    o = range(test_value)*.05;
    bins = linspace( min(test_value)-o, max(test_value)+o, 10);
end

[ybar_neg,bins] = scaledhist( result_for_neg, bins );
[ybar_pos,bins] = scaledhist( result_for_pos, bins );
[yks_neg]  = ksdensity( result_for_neg, bins );
[yks_pos]  = ksdensity( result_for_pos, bins );

bar( bins, [ybar_neg' ybar_pos'] );
hold on;
plot( bins, [yks_neg' yks_pos'], 's-' );
xlabel('test');
ylabel('frequency');

legend( {'true +', 'true -', 'true + (smoothed)', 'true - (smoothed)' } );

