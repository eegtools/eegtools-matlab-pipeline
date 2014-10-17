function x = subsref( g, S )
% SUBSREF  provides access to MModel data though the syntax mm(i,j)
%
% Example
%   g  = MMGate;
%   g.type          % show type

% $Id: subsref.m,v 1.2 2006/12/26 22:53:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if strcmp( S(1).type,'()' )
    error( 'MModel:subsref', '() not supported');
elseif strcmp( S(1).type, '.')
    switch( S(1).subs)
        case 'group'
            x = g.group;
        case 'crit'
            x = g.crit;            
        case 'method'
            x = g.method;
        case 'type'
            x = g.type;
        otherwise
            error( 'MModel:subsref', 'illegal access');            
    end;
end
if length( S) > 1
    x = subsref( x, S(2:end) );
end
