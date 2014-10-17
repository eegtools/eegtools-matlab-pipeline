function y = scree( latent, alpha )
% SCREE scree plot
% 
% scree plot shows the variance explained by each principal component.
% Two lines are shown, one is the cumulative percent explained
% and the other is the percent explained by the ith component.
% 
%    y = scree(latent,alpha)
%        latent is a vector of eigenvalues sorted from highest to lowest
%        alpha is a cutoff. points from latent are drawn until the
%        cumulative sum equals or exceeds 1-alpha
%
% Example
%   X = [MPG Acceleration Weight Displacement];
%   X = zscore(X(~any(isnan(X),2),:));
%   [coeff, score, latent] = princomp( X  );
%   scree(latent);
%
% See also
%   pcplot, cvplot

% $Id: scree.m,v 1.7 2006/12/26 22:53:29 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

newplot

p = 100*latent/sum(latent);
pe = cumsum(p);

if ( nargin < 2 )
    alpha = 0.05;
end;

i = find(pe > 100*(1 - alpha),1);
if ( isempty(i) ), i = length(latent); end;

if nargout > 0
    y = [pe(1:i) p(1:i)];
end

line(1:i, pe(1:i),'marker', 'o', 'color', 'b', 'markerfacecolor', 'g' );
line(1:i, p(1:i),'marker', 's', 'color', 'k', 'markerfacecolor', 'g' ); 
h = refline( 0, 100*alpha);
set(h, 'linestyle', '-.', 'color', 'k');
h = refline( 0, 100*(1-alpha));
set(h, 'linestyle', '-.', 'color', 'k');

xlabel('number of factors' );
ylabel('percent explained' );
legend( {'cumulative', 'individual'}, 'location', 'northwest' );

title( 'scree plot');

