function gamplot( ch, phat )
%GAMPLOT overlay a gamma distribution on a a histogram of ch. 
%
% gamplot( ch, phat )
% CH   is a vector of observations
% PHAT is a three parameter, shape, scale and offset for a gamma distribution
%      if phat is not provided, it will be estimated using gamfit, In which
%      case, ch will be adjustedto start at 0, so that gamfit can find a 
%      solution. requires Matlab's gamfit from the statistics toolbox
%
%
% Example
%      x = gamrnd( 3, 3, 1000, 1 );
%      gamplot(x);

% $Id: gamplot.m,v 1.4 2006/12/26 22:53:25 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

%only fit the finite values of x
%because MatLab's gamfit does not 
%ignore them
ch(isnan(ch)) = [];
offset = min(ch)-eps;
ch = ch - offset;


if ( nargin < 2 )
    % bestfit a gamma distribution
    phat = gamfit( ch );
    phat(3) = offset;
end
    
%plot the histogram
m = length(ch);
s = std(ch);
x = linspace(max(0,min(ch)-s),max(ch)+s, sqrt(m)*log(m));
y = scaledhist(ch+offset,x+offset);
bar( x+offset, y);

y = gampdf( x, phat(1), phat(2) ) ;

hold on;
plot( x+offset, y, 'r');

