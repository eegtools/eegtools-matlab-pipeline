function g = MMGate( varargin )
% MMGate - extracts rows of x that meet gating criteria
%
%       g = MMGate
%       g = MMGate(g)
%       g = MMGate( type, method, crit, group )
%       g = MMGate( type, method, crit, group, mmodel )
%
% supported types are 'none', 'inclusion', and 'exclusion'
% supported methods are
%     'nearest and distance'      % both nearest and distance      
%     'nearest'                   % based on mah      
%     'distance'                  % mah < crit        
%     'unclustered'               % not within crit of any named cluster
%     'most likely'               % based on prob     
%     'probability'               % prob > crit  
%   


if nargin == 0
    g.type   = 'none';
    g.method = 0;
    g.crit   = 2;
    g.group  = 1;
elseif nargin == 1 && isa(varargin{1}, 'Gate')
    g = varargin{1};
    return;
elseif nargin >= 4;
    g.type   = checkType( varargin{1} );
    g.method = checkMethod( varargin{2} );
    g.crit   = checkCrit( varargin{3} );
    if nargin == 5 && isa( varargin{5}, 'MModel' )
        g.group  = checkGroup( varargin{4}, varargin{5} );
    else
        g.group = varargin{4};
    end
else
    error( 'FacsMM:Gate:Constructor', 'no such constructor available' );
end
      
    
g = class(g,'MMGate');