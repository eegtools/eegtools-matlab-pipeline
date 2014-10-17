function v = createExtDimMenu(v)
% CREATEEXTDIMMENU private function to create context menu on non-model dims

% $Id: createExtDimMenu.m,v 1.3 2006/12/27 16:17:42 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

cmenu = v.clickExtDimMenu;
if  isempty(cmenu) || ~ishandle( cmenu)
    cmenu = uicontextmenu;
    set(cmenu,'tag','ExtDimContextMenu');
    uimenu(cmenu, 'Label', 'add x dim', 'Callback', @addXDimCallback );  
    uimenu(cmenu, 'Label', 'add y dim', 'Callback', @addYDimCallback );  
    uimenu(cmenu, 'Label', 'add z dim', 'Callback', @addZDimCallback ); 
    uimenu(cmenu, 'Label', 'optimize',  'Callback', @optimizeCallback );
    v.clickExtDimMenu = cmenu;
end

% Hide inappropriate choices
show                   = false(4,1);        % hide all
show(1:length(v.dims)) =  ~v.mm.s( v.dims );  % show add menu for dims 
                                            % that are not in the model

ch = flipud(get(v.clickExtDimMenu, 'children'));
set(ch(show), 'enable', 'on' );
set(ch(~show), 'enable', 'off');


if isOptimized(v.mm)
    set( ch(end), 'enable', 'off' );
else
    set( ch(end), 'enable', 'on' );
end

%
% add menu to plot
set(gca, 'UIContextMenu', cmenu );


%% addXDimCallback
function addXDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(1)) = true;
v.mm         = setModelDims( v.mm, s );
mmplot(v);


%% addYDimCallback
function addYDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(2)) = true;
v.mm         = setModelDims( v.mm, s );
mmplot(v);

%% addZDimCallback
function addZDimCallback(hObject, E, H)%#ok
v = get(gca,'userdata');
s            = v.mm.s;
s(v.dims(3)) = true;
v.mm         = setModelDims( v.mm, s );
mmplot(v);


%% optimizeCallback
function optimizeCallback(hObject, E, H) %#ok
v         = get(gca, 'userdata');
v.mm      = em(v.mm);
mmplot(v);



