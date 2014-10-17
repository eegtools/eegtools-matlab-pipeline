function export( fn, tbl, nfmt, sfmt  )
%EXPORT exports the data from a cell_array to the given file
%
%Example
%   export( fn, tbl  )

% $Id: export.m,v 1.5 2006/12/26 22:54:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

fid = fopen(fn, 'w');

if ( fid <=0 ) 
    error('linstats:export:FileOpenError', 'error opening file for writing');
end;

[m,n] = size(tbl);

if nargin < 3
    nfmt = '%.4f';
end

if nargin < 4
    sfmt = '%s'; 
end

for i = 1:m
    for j = 1:n
        d = tbl{i,j};
        if ( isnumeric( d ) )
            fprintf( fid, nfmt, d );
        else
            fprintf( fid, sfmt, d );
        end
        if (j < n )
            fprintf( fid, '\t' );
        else
            fprintf( fid, '\n' );
        end
    end
end;
    
fclose(fid);