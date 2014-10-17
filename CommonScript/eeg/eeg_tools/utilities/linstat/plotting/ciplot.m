function [hh lh] = ciplot( x, y, ci, color_grouping, marker_grouping, size_grouping )
%CIPLOT confidence interval plot with multiple factor grouping
%
% scatter plot of x versus y with errorbars for up to 3 factors
%
% [hh lh] = ciplot( x, y, ci, color_grouping, marker_grouping, size_grouping );
% x, y and ci are m x 1 vectors of coordinates and 1/2 confidence
% intervals. the grouping variables if present are uses as in mscatter
%
% Example
%   load carbig
%   glm = encode( Acceleration, 3,1, Cylinders );
%   u = lsestimates(glm,1)
%   ciplot( 1:5, u.beta, u.ci );
%   set(gca,'xticklabel', glm.level_names{1}, 'xtick', 1:5 )
%   xlabel('cylinders'); ylabel('acceleration \pm 95% ci');
%See also mscatter, iplot, errorbar

% $Id: ciplot.m,v 1.8 2006/12/26 22:53:23 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if isvector(x)
    x = x(:);
end;

if isvector(y)
    y = y(:);
end;

newplot;
oldnextplot = get(gcf,'NextPlot');

m = size(x,1);
o = ones(m,1);

nfactors = 0;
 
if nargin < 6 || isempty( size_grouping) 
    size_grouping = o;
else
    nfactors = nfactors + 1;
end

if nargin < 5 || isempty( marker_grouping )
    marker_grouping = o;
else
    nfactors = nfactors + 1;
end;

if nargin < 4    
    %errorbar(x,y,ci, 'o','markerfacecolor', 'g', 'linestyle', '-');
    h = errorbar(x,y,ci, 'o','markerfacecolor', 'g');
    if (nargout > 0 )
        hh = h;
        lh = [];
    end;
    return;
else
    nfactors = nfactors + 1;
    if isempty(color_grouping)
        color_grouping = o;
    end;
end;


glm = encode( y, 3, [ 0 0 0; eye(3); 1 1 1], color_grouping, marker_grouping, size_grouping );

x(glm.missing,:) = [];
y(glm.missing,:) = [];


% setup the color mapping
ncg = glm.nlevels(1);
cgn = [ 0 0 0];
if ( ncg > 1 )
    cgn = colorfulcube( ncg );
end;


%% set up the marker grouping variable
nmg = glm.nlevels(2);

if ( nmg > 9 )
    error('linstats:ciplot:InvalidArgument', 'too many marker levels. Only 9 supported');
end;
mgn = 'osdv^<>ph';

%% set up size grouping variable
nsg = glm.nlevels(3);
kMinsz  = 6;
kJmpsz  = 4;
kMaxsz  = 35;
kDefsz  = 8;

sgn = ((1:nsg)-1)*kJmpsz + kMinsz;
if ( max(sgn) > kMaxsz )
     sgn = (sgn-min(sgn))*(kMaxsz-kMinsz)/range(sgn) + kMinsz;
end

if nsg == 1
    sgn = kDefsz;
end;

% now decode the groupings
ivar  = decode(glm);
D     = unique(ivar, 'rows');
ngrps = size(D,1);

if nfactors == 1
    ls = '-';
else
    ls = 'none';
end;
h = zeros(ngrps,1);
for i = 1:ngrps
    ii = ivar(:,4) == D(i,4);
    h(i) = errorbar( x(ii,:), y(ii,:), ci(ii,:), ...
        'LineStyle',ls, ...
        'MarkerFaceColor', cgn(D(i,1),:), ...
        'Marker', mgn(D(i,2)), ...
        'MarkerSize', sgn(D(i,3)) );
    hold on;
end

xlim = get(gca, 'XLim');
d = diff(xlim);
xlim(1) = min(xlim(1), min(min(x))-0.05*d);
xlim(2) = max(xlim(2), max(max(x))+0.05*d);
set(gca, 'XLim', xlim);

% color legend
colorbar off;
if ncg > 1
    if ( isinf(ncg) ) %i.e. it is continuous
        h(2) = colorbar;
    else
        [a,b] = unique(D(:,1) );
        lh(1) = clegend( h(b), glm.level_names{1}, 'location', 'northeast' );
        lname = deblank( inputname(4) );
        if isempty(lname)
            lname = 'x1';
        end;
        set(lh(1), 'xticklabel', lname );
    end;
end

% create marker legend
if nmg > 1
    [a,b] = unique(D(:,2));
     lh(2) = mlegend( h(b), glm.level_names{2}, 'location', 'southeast' );
     lname = deblank( inputname(5) );
     if isempty(lname)
            lname = 'x2';
     end;
     set(lh(2), 'xticklabel', lname );
end;

% size legend
if ( nsg > 1 )
    if ( isinf(nsg) ) %i.e. it is continuous
        %nothing to do - a legend would be uninterpretable
    else
        [a,b] = unique(D(:,3));
        lh(3) = slegend( h(b), glm.level_names{3}, 'location', 'west' );
        lname = deblank( inputname(6) );
        if isempty(lname)
            lname = 'x3';
        end;
        set(lh(3), 'xticklabel', lname );
    end
end

set(gca,'NextPlot', 'replace');
set(gcf,'NextPlot', oldnextplot);

xnam = inputname(1); 
ynam = inputname(2); 
xlabel(deblank(xnam)); 
ylabel(deblank(ynam)); 


if nargout > 0
    hh = h;
end;
