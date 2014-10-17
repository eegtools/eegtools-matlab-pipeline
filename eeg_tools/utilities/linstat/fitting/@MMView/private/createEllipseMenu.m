function v = createEllipseMenu( v, h )
%CREATEELLIPSEMENU private function to create context menus for ellipses

% $Id: createEllipseMenu.m,v 1.6 2006/12/27 16:17:42 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if  isempty(v.ellipseMenus) || ~ishandle( v.ellipseMenus) 
    cmenu = uicontextmenu;
    set(cmenu,'tag', 'EllipseContextMenu');
    uimenu( cmenu, 'label', 'move ...',    'callback', @moveCluster );
    uimenu( cmenu, 'label', 'merge ...',   'callback', @mergeCluster);
    uimenu( cmenu, 'label', 'delete',      'callback', @deleteCluster_Callback);
    uimenu( cmenu, 'label', 'name...',     'callback', @nameCluster_Callback); 
    uimenu( cmenu, 'label', 'logL contour','callback', @logl_contour, 'separator', 'on');
    uimenu( cmenu, 'label', 'optimize',    'callback', @optimizeCallback, 'separator', 'on' );
    gmenu = uimenu( cmenu, 'label', 'gate',   'separator', 'on' );    
    uimenu( gmenu, 'label', 'nearest and distance', 'callback', @setGate );
    uimenu( gmenu, 'label', 'nearest','callback',    @setGate );
    uimenu( gmenu, 'label', 'distance','callback',    @setGate );
    uimenu( gmenu, 'label', 'unclustered','callback', @setGate );
    uimenu( gmenu, 'label', 'most likely','callback', @setGate );
    uimenu( gmenu, 'label', 'probability','callback', @setGate );
    uimenu( gmenu', 'label', 'set threshold','callback',   @setCrit, 'separator', 'on' );
    
    v.ellipseMenus = cmenu;
end

% toggle enable/disable optimize menu item
ch = flipud(get(v.ellipseMenus, 'children'));
if isOptimized(v.mm)
    set( ch(6), 'enable', 'off' );
else
    set( ch(6), 'enable', 'on' );
end


% add menu to plot
set(h, 'UIContextMenu', v.ellipseMenus );



%% moveCluster
function moveCluster( hObject, E, H )%#ok

[v k] = getNearestCluster;
label = sprintf( 'move %s to ...', v.mm.knames{k});


cm = get(gca, 'UIContextMenu' );
uimenu( cm, 'label', label, 'callback', @doMoveCluster, 'userdata', k );

function doMoveCluster(hObject,E) %#ok

[v k sel] = getNearestCluster;
k         = get(hObject,'userdata');
v.mm      = setMeans( v.mm, k, sel(1,1:2), viewToModelDims(v) );
delete(hObject);

mmplot(v);

%% mergeCluster
function mergeCluster( hObject, E, H )%#ok
% prompts for another selection and then
% constrains the means and vairances to be equal in the
% current dimesions
[v k] = getNearestCluster;
label = sprintf( 'merge to %s ...', v.mm.knames{k} );

cm = get(hObject,'parent');
uimenu( cm, 'label', label, 'callback', @doMerge, 'userdata', k );


function doMerge( hObject, E, H )%#ok

[v k2] = getNearestCluster;
k1     = get( hObject,'userdata');
set( hObject, 'label', 'merge ... ', 'callback', @mergeCluster );

b0 = getTheta(v.mm);

[k,d] = size(b0.M);
if ~isempty( b0.h0);
    h0 = b0.h0;
else
    h0 = repmat( 1:k, d, 1)';
end

% dimensions to merge
s         = v.mm.s;
g(s==1)   = 1:sum(s);
i         = g(v.dims);

% merge k1 into k2 (heirarchical constraint)

n1 = h0(k1,i(1));
if ( all(sum(h0(:,i)==n1) ~= 1) )
    h0(k2,i) = n1;
else
    n2 = h0(k2,i(1));
    h0(k1,i) = n2;
end

b0.h0 = h0;
[b0.M,b0.V] = gm_constraint( b0.M, b0.V, h0 );

v.mm = setTheta(v.mm, b0 );

delete(hObject);
mmplot(v);


%% deleteCluster
function deleteCluster_Callback( hObject, E, H )%#ok
[v k]      = getNearestCluster;
v.mm       = deleteCluster( v.mm, k );
mmplot(v);

%% nameCluster_Callback
function nameCluster_Callback( hObject, E, H )%#ok
% prompts for another selection and then
% constrains the means and vairances to be equal in the
% current dimesions
[v k] = getNearestCluster;

oldname = v.mm.knames(k);

answer = inputdlg( 'Enter class name ', 'Name Class', 1, oldname );

if ~isempty(answer)
    v.mm = setKnames( v.mm, answer, k );
    set(gca,'userdata',v);
    mmplot(v);
end;



function logl_contour( hObject, E, H )%#ok
% overlay a contour of the loglikelihood surface for the selected 
% class onto the current plot. 15 equally spaced points in the current
% limits. 
% This function is only available when the current view is within the 
% same space as the current fit


[v k] = getNearestCluster;
theta = getTheta( v.mm );



s = v.mm.s;
g(s==1) = 1:sum(s);

dims = g(v.dims);             % corresponding dimensions in fit

[dims, order] = sort(dims);   % sort in same order as fit structure

lims = [get(gca,'xlim')' get(gca, 'ylim')'];
lims = lims(:,order);
xs = linspace( lims(1,:), lims(2,:), 15 )';
x = v.mm.x(:,s);
i = randsample( size(x,1), min(5000, size(x,1)));

[logl xgrid ygrid] = mmvn_logl_surface( x(i,:), theta, k,  dims, xs);

hold on;
if ~issorted(order)
    contour( ygrid, xgrid, logl);
else
    contour( xgrid, ygrid, logl);
end;


%% setGate
% gate on the currently selected clusterd
function setGate( hObject, E, H )%#ok
[v k]      = getNearestCluster;

v.view   = MMGate( 'inclusion', ...
                   get(hObject,'pos'), ...
                   v.view.crit, ...
                   v.mm.knames{k}, ...
                   v.mm );

mmplot(v);


%% setGate
% gate on the currently selected clusterd
function setCrit( hObject, E, H )%#ok

v   = getNearestCluster;

answer = inputdlg( 'Enter critical threshold', 'threshold', 1, {num2str(v.view.crit)} );
crit = str2double(answer);
if isfinite(crit)
    v.view.crit = crit;
end


mmplot(v);


%% getNearestCluster
function [v k sel] = getNearestCluster

v         = get(gca, 'userdata');
sel       = get(gca,'currentpoint');

bhat      = getTheta(v.mm);

s         = v.mm.s;
g(s==1)   = 1:sum(s);
i         = g(v.dims);

d2        = sum(center( bhat.M(:,i), sel(1,1:2) ).^2, 2 ); %sum( mah( sel(1,1:2), bhat.M(:, i), bhat.V(i,i,:)  );


[mind2, k] = min(d2);%#ok





%% optimizeCallback
function optimizeCallback(hObject, E, H)%#ok
v         = get(gca, 'userdata');
v.mm      = em(v.mm);
mmplot(v);
