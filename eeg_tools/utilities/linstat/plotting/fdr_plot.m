function [fdr, u, sig] = fdr_plot( p )
%FDR_PLOT false discovery rate plote.
% plot of the emprical null distribution with overlay of an estimated null
% distribution. The emprical null is shown as a bar chart and the smoothed
% overall density is overlayed. The false discovery rate is the
% Prob(p|null). Used when there are enough tests to infer a null
% distrbiution.
%
% [fdr, u, sig] = fdr_plot( p )
% P is a mx1 vector of probabilities.
% FDR is the m x 1 vector of false discovery rates
% U is a the mean of the emprical null distribution (converted to z)
% SIG is the standard deviation of the null distribution
%
%Example
%   x = randn( 1000, 10 );                % 10,000 tests each with n=10 
%   x(1:50, 6:end) = x(1:50,6:end) + 3;  % 50 tests are true positives
%   groups = repmat( 1:2, 5, 1 );        % grouping index
%   groups = groups(:);
%   glm = encode( x', 3, 1, groups );    % linear model for anova
%   a = anova(glm);                      % anova
%   fdr_plot( a.pval )                   % fdr
%
% See also fdr_calc

% $Id: fdr_plot.m,v 1.4 2006/12/26 22:53:25 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 



[fdr, u, sig, z, x, fx, fx0 ] = fdr_calc( p );

% plot histogram
newplot
h = scaledhist( z, x );
bar( x, h );
xlabel('norminv(p)');
ylabel('frequency');
hold on;

% overlay estimated density
plot( x, fx, 'b-' ); 


plot( x, fx0, 'r-' );
legend({'empirical', 'smoothed', 'null'});

if nargout == 0
    clear fdr u sig
end

