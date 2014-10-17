function x = subsref( ts, S )
% SUBSREF provides access to tsodel data though the syntax ts(i,j)
%         and ts.fieldname
%

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if strcmp( S(1).type,'()' )
    x = subsref( ts.tree, S );
elseif strcmp( S(1).type, '.')
    switch( S(1).subs)
        case 'tree'
            x = ts.tree;
        case 'nextnode'
            x = ts.nextnode;
        case 'nodeclass'
            x = ts.nodeclass;            
        case 'nodes'
            x = ts.nodes;
        otherwise
            error( 'tsodel:subsref', 'illegal access');            
    end;
    if length( S) > 1
        x = subsref( x, S(2:end) );
    end
end

