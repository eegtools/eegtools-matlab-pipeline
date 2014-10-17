function [x, y, auc, se, hh] = roc_plot( real, test_value, color, fpf_cutoff )
%ROC_PLOT reciever operating characteristic curve
%  
%  plots the true positive fraction versus the false positive fraction for
%  all possible thresholds for a test-score. 
%
% [x, y, auc, se] = roc_plot( real, test_value, color, fpf_cutoff )
%  REAL is a m-vector of covertable to logical indicating which observations
%  are true positives. 
%  TEST_VALUE is a m-vector of test values. 
%  COLOR indicates which linecolor to use 
%  FPF_CUTOFF is optional and is used when calculating area. then auc is
%  calculated from [0..fpf_cutoff]
%  returns x, y the plotted values; auc the area under the curve; se, an
%  estimate for the standard error of the auc; and hh the handle to the
%  plot
%
% Example
%    x = randn( 1000, 10 );               % 10,000 tests each with n=10 
%    x(1:50, 6:end) = x(1:50,6:end) + 3;  % 50 tests are true positives
%    groups = repmat( 1:2, 5, 1 );        % grouping index
%    groups = groups(:);
%    glm = encode( x', 3, 1, groups );    % linear model for anova. assume x
%                                         % are log2 transformed
%    a = anova(glm);                      % anova
%    truth = false(1000,1);               % create a vector with the truth
%    truth(1:50) = true;                
%    roc_plot( truth, a.pval);            % use pvalue for test score
%
% See also roc_calc

% $Id: roc_plot.m,v 1.3 2006/12/26 22:53:29 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

newplot;

if ( nargin < 4)
    fpf_cutoff = 1;
end;
[x,y,auc,se] = roc_calc( real, test_value, fpf_cutoff );

hh = [];

if ( nargin >= 3 )
    if ( strmatch( color , 'none' ) )
        return;
    end;
else    
    color = 'b';
end;

if ( isempty(x) && isempty(y) )
    x = 0; y = 0;
end;
hh = plot( x, y, color);
hold on;
% plot( fpf, test_value, [color '-.'] );

% h = refline( 1, 0);
% set(h, 'color', 'k');
xlabel('false positive fraction');
ylabel('true positive fraction' );
grid on;

