function i = getClusterIndex( g, mm )
% GETCLUSTERINDEX returns a cluster index based on mah distance
%
% Example
%        i = getClusterIndex( g, mm )

% $Id: getClusterIndex.m,v 1.2 2006/12/26 22:53:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

i      = ones( size(mm.x,1),1 );


if isempty(mm.x) || strcmp(g.type , 'none' );
    return;
end;


[mind2, i] = min( mm.d2, [], 2 );
