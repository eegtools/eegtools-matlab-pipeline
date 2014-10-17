function g = subsasgn( g, S, B )
%SUBSASGN assignment operator for class MMGate
%
%Example
%  g = MMGate;
%  g.crit = 2;      % set threshold to 2
%

% $Id: subsasgn.m,v 1.2 2006/12/26 22:53:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


if strcmp( S(1).type,'()' )
    error( 'MModel:subsasng', '() not supported');
elseif strcmp( S(1).type, '.')
    switch( S(1).subs)
        case 'group'
            g.group = B;
        case 'crit'
            g.crit   = checkCrit(B);
        case 'method'
            g.method = checkMethod(B);
        case 'type'
            g.type =  checkType(B);
        otherwise
            error( 'MModel:subsref', 'illegal access');
    end
end