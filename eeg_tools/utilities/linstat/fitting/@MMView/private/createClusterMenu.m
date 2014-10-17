function v = createClusterMenu(v)
%CREATECLUSTERMENU private function to create context menus for model dims

% $Id: createClusterMenu.m,v 1.3 2006/12/27 16:17:41 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
if  isempty(v.addClusterMenu) || ~ishandle( v.addClusterMenu)
    cmenu = uicontextmenu;
    set(cmenu,'tag','PlotContextMenu');
    uimenu(cmenu, 'Label', 'add cluster',  'callback', @addClusterCallback );  
    uimenu(cmenu, 'Label', 'remove x',     'callback', @removeXDimCallback );  
    uimenu(cmenu, 'Label', 'remove y',     'callback', @removeYDimCallback );  
    uimenu(cmenu, 'Label', 'remove z',     'callback', @removeZDimCallback );  
    uimenu(cmenu, 'Label', 'optimize','callback', @optimizeCallback );    
    
    v.addClusterMenu = cmenu;
end


% hide remove-dimension menu items that aren't in the model
s = v.mm.s(v.dims);       % displayed dimensions that are in the model 
show = false( 3, 1 );
show(s) = true;           % display ones in the model


ch = flipud(get(v.addClusterMenu, 'children'));

ch = ch(2:4);       % the removeX menu items
set(ch, 'enable', 'off' );
set(ch(show), 'enable', 'on');



% toggle enable/disable optimize menu item
ch = flipud(get(v.addClusterMenu, 'children'));
if isOptimized(v.mm)
    set( ch(5), 'enable', 'off' );
else
    set( ch(5), 'enable', 'on' );
end

% add menu to plot
set(gca, 'UIContextMenu', v.addClusterMenu );


function addClusterCallback(hObject, E, H)%#ok
% called through a context menu item when
% viewing dimensions included in the current fit
v         = get(gca, 'userdata');
sel       = get(gca,'currentpoint');


% forward request to mm 
v.mm = addCluster(v.mm, sel(1,1:2), v.dims );


mmplot(v,gca);  %plot new ellipse


%% removeXDimCallback
function removeXDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(1)) = false;
v.mm         = setModelDims( v.mm, s );
mmplot(v);


%% removeYDimCallback
function removeYDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(2)) = false;
v.mm         = setModelDims( v.mm, s );
mmplot(v);

%% removeZDimCallback
function removeZDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(3)) = false;
v.mm         = setModelDims( v.mm, s );
mmplot(v);




%% optimizeCallback
function optimizeCallback(hObject, E, H) %#ok
v         = get(gca, 'userdata');
v.mm      = em(v.mm);
mmplot(v);
