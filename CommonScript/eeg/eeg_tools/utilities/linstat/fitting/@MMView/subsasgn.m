function g = subsasgn( g, S, B )
%SUBSASGN provides write access to mmview class 

% $Id: subsasgn.m,v 1.2 2006/12/26 22:53:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
if length(S) > 1
    g = subsasgn(g, S(2:end), B );
end;

if strcmp( S(1).type,'()' )
    error( 'MModel:subsasng', '() not supported');
elseif strcmp( S(1).type, '.')
    switch( S(1).subs)
        case 'view'
            g.view   = B; 
        case 'mm'
            g.mm     = B;
        case 'xi'
            g.dims(1)   = checkDim(g, B);
        case 'yi'
            g.dims(2)   = checkDim(g, B);
        case 'zi'
            g.dims(3)   = checkDim(g, B);
        case 'dims'
            g.dims      = checkDim(g, B);
        case 'usize'
            g.usize    = B;
        case 'ssize'
            g.ssize    = B;
        case 'prism'
            g.prism    = B;            
        case 'labels'
            g.labels   = B;
        otherwise
            error( 'MMView:subsref', 'illegal access');
    end
end

