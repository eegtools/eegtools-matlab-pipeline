function [h lh] = resid_plot( stats, varargin)
%RESID_PLOT plot of predicted response versus residuals. 
% plot of yhat versus studentized residuals to help reveal outlying
% responses
%
%[resid h lh]  = resid_plot( stats, color_grouping, marker_grouping, size_grouping)
%   stats is a structure from mstats
%   see help mscatter for explanations of the other input arguments
%   returns resid, the studentized residuals
%   h handle(s) to the plotted data
%   lh handles to the legends
%
%Example
%    load carbig
%    glm = encode( MPG, 3, 2, Origin );
%    s = mstats(glm);
%    resid_plot(s);
%
% see also sresid_plot, mscatter

% $Id: resid_plot.m,v 1.6 2006/12/26 22:53:28 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


newplot;
x = stats.yhat;
n = length(x);

if (nargin < 2)
    ngroups = min( max(2, floor(n./30) ), 30 );
    edges   = linspace(0,100,ngroups+1);

    p = prctile( stats.yhat(:), edges );
    [n,bin] = histc( stats.yhat(:),p );
    bin(bin==ngroups+1) = ngroups;
    [h lh] = mscatter( stats.yhat(:), stats.resid(:), bin );
    delete(lh(1));
else
    [h lh] = mscatter( stats.yhat(:), stats.resid(:), varargin{:} );
end;

h = refline( 0,0);
set(h,'linestyle', '-.', 'color', 'k');
xlabel('predicted');
ylabel('residual error');

xlim = get(gca, 'XLim');
d = diff(xlim);
xlim(1) = min(xlim(1), min(min(x))-0.05*d);
xlim(2) = max(xlim(2), max(max(x))+0.05*d);
set(gca, 'XLim', xlim);
