function [yy,xx] = chist( f, horiz )
%CHIST categorical histogram
%
% [yy,xx] = chist( f, horiz )
% calucates and plots histograms for categorical 
% F is a cell array of strings or
% HORIZ is 1 for horizontal bars otherwise the bars are vertical
%
% Example
%   load carbig
%   chist(Origin);

% $Id: chist.m,v 1.5 2006/12/26 22:53:23 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

[gi,gn] = grp2ind( f );
[y,x] = hist( gi, 1:max(gi) );
if nargin > 1 && horiz == 1
    barh(x,y);
    set(gca,'yticklabel', gn );
    xlabel('number');
    yt = get(gca,'xtick');  
    yt = unique(floor(yt)); % only use whole numbers
    set(gca,'xtick', yt );
else
    bar(x,y);
    set(gca,'xticklabel', gn );
    ylabel('number');
    yt = get(gca,'ytick');  
    yt = unique(floor(yt)); % only use whole numbers
    set(gca,'ytick', yt );
end

if nargout > 0
    yy = y;
    xx = x;
end;

