function vv = mmplot( v, ax )
% MMPLOT interaactive plot to edit mixture model
% 
% Example
% [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] ); % 3d data
% mm = MModel(X, [1 2], 4 );   %  2d model of 1st two dimensions
% v  = MMView(mm);              % build view data with model overlayed
% mmplot(v);                    % plot view

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

newplot
if nargin < 2
    ax = gca;
end
axes(ax);
cla(ax, 'reset');

labels = v.labels;

% create menus 
xaxismenu = uicontextmenu;
yaxismenu = uicontextmenu;
zaxismenu = uicontextmenu;

for i = 1:length(labels)
    uimenu( xaxismenu, 'Label', labels{i}, 'Callback', @xAxisCallback);
    uimenu( yaxismenu, 'Label', labels{i}, 'Callback', @yAxisCallback );
    uimenu( zaxismenu, 'Label', labels{i}, 'Callback', @zAxisCallback );
end;

v.labelMenus  = {xaxismenu yaxismenu zaxismenu};
v             = doPlot(v);

if nargout > 0
    vv = v;
end;





function xAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gca, 'userdata');
d.dims(1) = get( hObject, 'position');
doPlot(d);


% --- Executes on selection change in yAxisMenu.
function yAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gca, 'userdata');
d.dims(2) = get( hObject, 'position');
doPlot(d);

% --- Executes on selection change in zAxisMenu.
function zAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gca, 'userdata');
d.dims(3) = get( hObject, 'position');
doPlot(d);