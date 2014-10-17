function [dh, bph] = mdensity_plot( x )
% MDENSITY_PLOT 
% overlay a boxplot on a density scatter plot
% the handles to the densities is given in h1
% and the handles to the boxplots are in bph.
% Intended for non-normal distributions with a
% lot of data
% Declaration
%   [dh, bph] = mdensity_plot( x )
%   returns dh, handle to the density plot
%   bph         handle to the box plot handles
% Example
%   x = [randn(1000,1)+1; 5*randn(5000,1)+50];
%   x(:,2) = [randn(1000,1)+10; 10*randn(5000,1)+100];
%   [dh, bph] = mdensity_plot( x);
%   delete(bph);
%   set(gca, 'color', 'k'); set(dh,'color', 'w');

% $Id: mdensity_plot.m,v 1.3 2006/12/26 22:53:26 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
newplot
[m,n] = size(x);
y = center( rand(m,n)*.95, -(1:n) + .475 );

if m < 100 
    msize = 6;
else
    msize = 3;
end;
h1 = plot( y, x, 'k.', 'markersize', msize );

ho = ishold;
hold on;

bph = boxplot( x); 

j = ~isnan(bph(7,:));
set(bph(7,j), 'markersize', 3 );    % adjust outliers
set(bph(1:6,:), 'linewidth', 2 );   % adjust lines

if ~ho
    hold off;
end;

% only give output if requested
if nargout > 0
    dh = h1;
end;