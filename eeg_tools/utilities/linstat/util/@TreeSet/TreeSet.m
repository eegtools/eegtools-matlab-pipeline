function ts = TreeSet( varargin )
% TreeSet  collection of unique nodes arranged in parent child location
%          the class of objects stored in the tree is determined by the
%          first item added
% Example 
%       ts = TreeSet()          % default
%       ts = TreeSet( ts )      % copy
%       ts = TreeSet( m  )      % emtpy tree preallocated with m nodes
%

%     
% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin == 0
    ts.tree  = sparse(100,100);
    ts.nodes = cell(100,1);
    ts.nextnode   = 1;
    ts.nodeclass  = [];
elseif nargin == 1
    if isa( varargin{1},'TreeSet' )
        ts = varargin{1};
        return;
    elseif isnumeric(varargin{1}) && isscalar( varargin{1})
        ts.tree = sparse( varargin{1} );
        ts.nodes = cell(varargin{1},1);
        ts.nextnode  = 1;
        ts.nodeclass = [];
    end
else
    error('FacsMM:TreeSet:TreeSet', 'bad constructor arguments');
end


ts = class(ts,'TreeSet');


