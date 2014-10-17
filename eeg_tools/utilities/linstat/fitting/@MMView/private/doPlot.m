function v = doPlot( v )
%DOPLOT internal function to plot mm data
%

% $Id: doPlot.m,v 1.4 2006/12/27 16:17:42 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
newplot

% subset columns
x = v.mm.x(:,v.dims);

colors = v.prism;
if v.mm.k > size(v.prism,1)
    colors = colorfulcube( v.mm.k, v.prism);
end
colormap(colors);

% plot data
i = gate( v.view, v.mm );

if strcmp( v.view.type, 'none' )
    c = [0.05 0.05 0.05 ];
else
    c = colors(groupi(v.view, v.mm),:);
end


% draw unselected first so selected show up better
h{2} = plot( x(~i,1), x(~i,2), ...
             'marker',    '.', ...
             'linestyle', 'none', ...
             'markersize',  v.usize, ...
             'color',       [.2 .2 .2] );
set(h{2},'hittest','off');
hold on;

h{1} = plot( x(i,1), x(i,2), ...
             'marker',    '.', ...
             'linestyle', 'none', ...
             'markersize',  v.ssize, ...
             'color',      c );

set(h{1},'hittest','off');


% plot ellipses
%    plot ellipses if view shows unique dimensions included in 
%    the model

s = v.mm.s;           % model dims
g(s==1) = 1:sum(s);     % convert dimensions of x -> dimensions in model

[theta, isopt] = getTheta(v.mm);
if isopt
    ls = '-';
else
    ls = '-.';
end

if length(unique(v.dims)) == length(v.dims) && all(s(v.dims))
    v  = createClusterMenu(v);
    eh = ellipse( theta.M, theta.V, g(v.dims) );
    set(eh, 'linestyle', ls, 'linewidth', 2);
    h{3} = eh;
    set(eh(:,1),'hittest', 'off');
    legend( eh(:,1), v.mm.knames, 'location', 'northeastoutside' );    
    v = createEllipseMenu( v, eh(:,2) );
else
    v = createExtDimMenu(v);
    h{3} = [];
end

% add optimization information
if ~isempty( v.mm.L )
    [xpos, ypos] = getAxisInset( 0.01, 0.95 );
    str = sprintf( 'LogL = %2.2f', v.mm.L );
    text(xpos, ypos, str );
end;

hold off;

addLabelDropDowns( v.labels(v.dims), v.labelMenus );

view.selh           = h{1};       % selected scatter points
view.unselh         = h{2};       % unselected
view.ellipseh       = h{3};       % ellipses
set(gca,'userdata', v );          % save data


