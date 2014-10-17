function view = MMView( varargin )
%MMView - stores a particular 2d view on md data including cell
%         populations to highlight tables.
%
% view provides a 2d view of any dimensions in a dataset
% and overlays a mixture model of a subset of those dimensions. 
%
%       view = MMView
%       view = MMView( mmv )
%       view = MMView( mm );
%       view = MMView( mm, mmg, labels )
%       view = MMView( as, x, labels )   % view an analysis step
%
% Example
% [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] ); % 3d data
% mm = MModel(X, [1 2], 4 );   %  2d model of 1st two dimensions
% v  = MMView(mm);              % build view data with model overlayed
% mmplot(v);                    % plot view

% $Id: MMView.m,v 1.2 2006/12/26 22:53:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
view.dims       = [ 1 2];
view.usize      = 3;            % size for unselected events
view.ssize      = 4;            % size for selected events

% default color map for selected observations
view.prism = [1   0   0
              1   1/2 0
              1   1   0
              0   1   0
              0   0   1
              2/3 0   1];

% context menus
view.addClusterMenu    = [];       % add cluster menu
view.ellipseMenus      = [];       % ellipse drop down menus
view.clickExtDimMenu   = [];       % click on view that external to model


view.labelMenus        = [];       % drop down label menus
view.selh              = [];       % selected scatter points
view.unselh            = [];       % unselected
view.ellipseh          = [];       % ellipses
    
          
if nargin == 0
    view.mm    = MModel;
    view.view  = MMGate;
    view.labels = {};
elseif nargin == 1 && isa( varargin{1}, 'MMView' );
    view = varargin{1};
    return;
elseif nargin == 1 && isa( varargin{1}, 'MModel' );
    view.mm       = varargin{1};
    view.view     = MMGate;
    if nargin == 3
        view.labels = varargin{3};
    else
        view.labels = cellstr( num2str( (1:size(view.mm.x,2))'));
    end
elseif nargin >= 2 && isa( varargin{1}, 'AnalysisStep' );
    as = varargin{1};
    view.mm     = setData(as.mm, varargin{2} );
    view.view   = as.gate;
    if ~isempty(as.views)
        view.dims   = as.views(:);
    end;
    if nargin == 3
        view.labels = varargin{3};
    else
        view.labels = cellstr( num2str( (1:size(view.mm.x,2))'));
    end
elseif nargin >= 2 && ...
        isa( varargin{1}, 'MModel' )  && ...
        isa( varargin{2}, 'MMGate' )
    view.mm       = varargin{1};
    view.view     = varargin{2};
    if nargin == 3
        view.labels = varargin{3};
    else
        view.labels = cellstr( num2str( (1:size(view.mm.x,2))'));
    end
else
    error( 'FacsMM:MMView:BadConstructor', 'Invalid constructor call' );
end

view = class(view, 'MMView');




