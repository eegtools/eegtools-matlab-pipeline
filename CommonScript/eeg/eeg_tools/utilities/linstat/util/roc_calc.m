function [fpf, tpf, auc, se ] = roc_calc( real, test_value, limit  )
%ROC_CALC calculations for reciever operating characteristic curve
%  
%  calculates the true positive fraction versus the false positive fraction for
%  all possible thresholds for a test-score. 
%
% [x, y, auc, se] = roc_plot( real, test_value, color, fpf_cutoff )
%  REAL is a m-vector of covertable to logical indicating which observations
%  are true positives. 
%  TEST_VALUE is a m-vector of test values. 
%  COLOR indicates which linecolor to use 
%  FPF_CUTOFF is optional and is used when calculating area. then auc is
%  calculated from [0..fpf_cutoff]
%  returns x, y the calculated values; auc the area under the curve; se, an
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
%    [x y] = roc_calc( truth, a.pval);    % use pvalue for test score
%    h = plot(x,y);
%
% See also roc_plot, roc_pdf

% $Id: roc_calc.m,v 1.3 2006/12/26 22:54:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

fpf = 0;
tpf = 0;
auc = nan;
se  = nan;


[test_value, order ] = sort(test_value);
real = real(order);

true_neg = real == 0;
true_pos = real ~= 0;
na = sum(true_pos);
nn = sum(true_neg);

if ( nn == 0  )
    warning('linstats:roc:InvalidArgument', 'no true negatives');
    return
end;

if ( na == 0 )
    warning('linstats:roc:InvalidArgument','roc: no true positives');
	return;
end;


tpf = scale(cumsum( true_pos ),na);
fpf = scale(cumsum( true_neg ),nn);

if ( nargout < 3 )
    return
end;

if ( nn < 2  )
    warning('linstats:roc:InvalidArgument','roc: too few true negatives');
    return
end;

if ( na < 2 )
    warning('linstats:roc:InvalidArgument','roc: too few true positives');
	return;
end;


if ( nargin > 3 )
    i = fpf <= limit;
    fpf = fpf(i);
end;

dx = diff( fpf );
dy = diff( tpf );
y = tpf(1:end-1) + dy./2;

% this is correct since x is not really continuous and smooth
% so some auc will include values from 0..limit-a, and others
% will include area from 0..limit-b. I would need to interpolate
% the remaining area from limit-b to limit.
auc = sum(dx.*y);
se = standardError( auc, na, nn );


function se = standardError( a, na, nn )
% a is the auc, 
% na is the number of positives 
% nn is the number of negatives

    q1 = a/(2-a);
    a2 = a*a;
    q2 = 2*a2/(1+a);
    
    se = sqrt( (a-a2 + (na-1)*(q1-a2) + (nn-1)*(q2-a2))/(na*nn) );