function [hh, lh] = mscatter( x, y, color_grouping, marker_grouping, size_grouping )
%MSCATTER scatter plot of x versus y grouped by up to 3 factors
% 
%
%[hh, lh] = mscatter( x, y, color_grouping, marker_grouping, size_grouping );
% X and Y are the m-vectors to be plotted as coordinate pairs
% COLOR_GROUPING a m-vector or cell array of strings that group
% observations in x and y. the grouping will be distinguished on color. 
% A legend is created for the groups. 
% MARKER_GROUPING is a scalar value for coloring all groups, empty for
% default coloring or a m-vector or cell array of strings that group
% observations in x and y. The groups will be drawn with a unique marker. a
% legend is created to show the marker group names
% SIZE_GROUPING is a scalar value for coloring all groups, empty for
% default coloring or a m-vector or cell array of strings that group
% observations in x and y. The groups will be drawn with a unique size.
% a legend is created to show the size group names
% returns
% HH the handles to the unique groupings of data
% LH the legend handles
% 
%Example
%      load carbig
%      X = [MPG Acceleration Weight Displacement];
%      i = ~any(isnan(X),2);  %find present values
%      X = zscore(X(i,:));
%      [coeff, score, latent] = princomp( X );
%      cylinders = Cylinders(i,:);
%      origin    = Origin(i,:);
%      mscatter( score(:,1), score(:,2), 'none', origin, 6 );

% $Id: mscatter.m,v 1.10 2006/12/26 22:53:27 Mike Exp $
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

kDefsz = 8;
if nargin < 5 
    size_grouping = o;
elseif isscalar(size_grouping)
    kDefsz  = size_grouping;
    size_grouping = o;    
end

mgn = 'osdv^<>ph';
if nargin < 4
    marker_grouping = o;
elseif isscalar( marker_grouping )
    mgn = marker_grouping;
    marker_grouping = o;
end;

lh =  nan(3,1);

if nargin < 3    
    h = plot(x,y,'o','markerfacecolor', 'g');
    if nargout > 0
        hh = h;
    end
    return;
end;

if isempty(color_grouping), color_grouping = o; end;
if isempty(marker_grouping), marker_grouping = o; end;    
if isempty(size_grouping), size_grouping = o; end;    

glm = encode( y, [3 3 3], [ 0 0 0; eye(3); 1 1 1], color_grouping, marker_grouping, size_grouping );

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
    error('linstats:mscatter:InvalidArgument','too many marker levels. Only 9 supported');
end;


%% set up size grouping variable
nsg = glm.nlevels(3);
kMinsz  = 6;
kJmpsz  = 4;
kMaxsz  = 35;

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
h     = nan(ngrps, 1);
for i = 1:ngrps
    ii = ivar(:,4) == D(i,4);
    xx = x(ii,:);
    if size(xx,1) == size(unique(xx),1)
        ls = 'none';
    else
        ls = 'none';
    end
    lc = 'k';
    if sgn(D(i,3)) < 5
        lc = cgn(D(i,1),:);
    end
    h(i) = line( x(ii,:), y(ii,:), ...
        'LineStyle',ls, ...
        'MarkerFaceColor', cgn(D(i,1),:), ...
        'Marker',          mgn(D(i,2)), ...
        'MarkerSize',      sgn(D(i,3)), ...
        'color', lc );
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
        lname = deblank( inputname(3) );
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
     lname = deblank( inputname(4) );
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
        lname = deblank( inputname(5) );
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