function hh = ndscatter( A, labels, dims, plotcb, varargin )
% NDSCATTER flexible interactive plot for viewing n-dimensional data
%
% adds a context menu to the plot labels to allow dimensions to be selected
% interactively
%
% ndscatter( A, labels, dims, plotcb, varargin )
%   A is a mxn numeric matrix 
%   labels is a nx1 cell array of plot labels
%   dims is the initial dimensions to view
%   plotcb is a plotting routine that is called whenever the selected
%   dimensions change. It is of the form h = plotcb( x1, x2, ..., x(dims),
%   varargin); the first dim arguments will be the selected dimensions of A
%   varargin are the values passed into ndscatter. plotcb should return a
%   handle to the graphic
%   
%
% Example
% load carbig
% X = [MPG Acceleration Weight Displacement];
% i = ~any(isnan(X),2);  %find present values
% X = X(i,:);
% labels = {'MPG', 'Acc', 'Weight', 'Disp'};
% ndscatter( X, labels, 1:2, @plot, 'marker', '+', 'markersize', 3, 'linestyle', 'none');
%
% ndscatter( X, labels, 1:3, @plot3, 'marker', '+', 'markersize', 3, 'linestyle', 'none');
% 


% create labels
[m,n] = size(A);
if nargin < 2
    labels = cellstr( strcat( 'x', num2str( (1:n)') ) );
end
if nargin < 3
    dims = 1:min(n,3);
end

% create menus 
xaxismenu = uicontextmenu;
yaxismenu = uicontextmenu;
zaxismenu = uicontextmenu;

for i = 1:length(labels)
    uimenu( xaxismenu, 'Label', labels{i}, 'Callback', @xAxisCallback);
    uimenu( yaxismenu, 'Label', labels{i}, 'Callback', @yAxisCallback );
    uimenu( zaxismenu, 'Label', labels{i}, 'Callback', @zAxisCallback );
end;

% build userdata for callbacks
d.dims = dims;
d.A    = A;
d.labels = labels;
d.menus  = {xaxismenu yaxismenu zaxismenu};
if nargin < 4 || isempty(plotcb) 
    d.plotcb = @plot;
else
    d.plotcb = plotcb;
end
d.args = varargin;

h = doPlot(d);

% addbutton
if nargout > 0
    hh = h;
end


function h = doPlot( d )
% get the data to be plotted

[x{1:length(d.dims)}] = mat2vec(d.A(:,d.dims));

% update data before call to plotcb
set( gcf, 'userdata', d );

if isempty(d.args)
    h = d.plotcb(x{:});     % some callbacks will fail if we pass extra (empty) args
else
    h = d.plotcb(x{:}, d.args{:});
end
addLabelDropDowns( d.labels(d.dims), d.menus );


function addLabelDropDowns( labels, menus )
str = {'xlabel', 'ylabel', 'zlabel'};
for i = 1:min(3,length(labels) )
    lh = get(gca, str{i} );
    set( lh, 'string', labels{i}, ...
             'uicontextmenu', menus{i} );
end;
    




function xAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gcf, 'userdata');
d.dims(1) = get( hObject, 'position');
% plot
doPlot(d);


% --- Executes on selection change in yAxisMenu.
function yAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gcf, 'userdata');
d.dims(2) = get( hObject, 'position');
% plot
doPlot(d);

% --- Executes on selection change in zAxisMenu.
function zAxisCallback(hObject, eventdata)%#ok
% update user data
d = get(gcf, 'userdata');
d.dims(3) = get( hObject, 'position');
% plot
doPlot(d);
