function h = variance_plot( stats )
%VARIANCE_PLOT plot to show reveal variance abnormalities
%
% plots variance versus predicted response
% If there is equal variance the data should not increase or decrease
% with yhat
%
% function h = variance_plot( stats )
%    stats is a structure from mstats
%    h is a handle to the plotted data
%
% Example
%     load carbig
%     glm = encode( MPG, 3, 2, Origin );
%     s = mstats(glm);
%     variance_plot(s);
%
% See also mstats

% $Id: variance_plot.m,v 1.3 2006/12/26 22:53:30 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

newplot;

x = stats.yhat;

hh = plot( stats.yhat, stats.resid.^2, 'o', 'markerfacecolor', 'g' );

xlim = get(gca, 'XLim');
d = diff(xlim);
xlim(1) = min(xlim(1), min(min(x))-0.05*d);
xlim(2) = max(xlim(2), max(max(x))+0.05*d);
set(gca, 'XLim', xlim);
xlabel('predicted');
ylabel('error^2');

if nargout > 1
    h = hh;
end
