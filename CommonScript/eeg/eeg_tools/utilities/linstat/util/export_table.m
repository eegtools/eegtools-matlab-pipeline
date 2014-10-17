function export_table( fn, col_names, varargin )
% EXPORT_TABLE writes a cell table to file
%
% This is much faster and much more reliable than cut and paste using the
% array editor to get data to excel or other program
%
% export_table( fn, col_names, varargin )
% See table for input arguments from 2 on. 
%
% Example
%   load carbig
%    X  = [MPG Acceleration Weight];  
%    export_table( 'example_table.xls', {'Origin', 'MPG', 'Acceleration', 'Weight', 'Displacement'}, ...
%                   cellstr(Origin), ...   % cell arrays are supported
%                   X, ...                  % matrices are supported
%                   Displacement);        % any number of columns are supported
% 
% See also export, table

% $Id: export_table.m,v 1.4 2006/12/26 22:54:07 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

fid = fopen(fn, 'w');

if ( fid <=0 ) 
    error('error opening file');
end;

nfmt = '%.4f\t';
sfmt = '%s\t'; 

hasheader = 0;
if ~isempty(col_names)
    hasheader = 1;
end

f = varargin{1};
if isvector(f)
    nrows = length(f(:));
else
    nrows = size(f,1);
end;


ncols = length(varargin);

%% print header;
if ( hasheader )
    fprintf( fid, '%s\t', col_names{:} );
    fprintf( fid, '\n');
end

for i = 1:nrows
    % print row name
    for j = 1:ncols
        d = varargin{j};

        if isvector(d)
            d = d(:);
        end;
        if ( isnumeric( d ) )
            fprintf( fid, nfmt, d(i,:) );
        else
            fprintf( fid, sfmt, d{i} );
        end
    end
    fprintf( fid, '\n');
end;


fclose(fid);