function x = subsref( mm, S )
% subsref - provides access to modeled MModel data 
% Example
%       mm = MModel;
%       mm.x;   % get full data matrix X

% $Id: subsref.m,v 1.2 2006/12/26 22:53:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
if strcmp( S(1).type,'()' )
    error( 'MModel:subsref', '() not supported');
elseif strcmp( S(1).type, '.')
    switch( S(1).subs)
        case 'x'
            x = mm.x;
        case 'u'
            x = mm.u;
        case 'd2'
            x = mm.d2;            
        case 's'
            x = mm.s;
        case 'b0'
            x = mm.b0;
        case 'bhat'
            x = mm.bhat;
        case 'd'
            x = size(mm.b0.M,2);
        case 'k'
            x = size(mm.b0.M,1);
        case 'n'
            x = length(mm.s);
        case 'knames'
            x = mm.knames;
        case 'L'
            x = mm.L;
        otherwise
            error( 'MModel:subsref', 'illegal access');            
    end;
end
if length( S) > 1
    x = subsref( x, S(2:end) );
end
