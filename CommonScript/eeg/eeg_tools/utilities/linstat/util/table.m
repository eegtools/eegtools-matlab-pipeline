function T = table( col_names, varargin )
%TABLE create a cell table
%
% builds a cell array that can be writen to file using export or displayed
% using plot_table.
%
% T = table( col_names, varargin )
%     col_names is optional and is the table header
%     varargin are cellstr, vectors or matrices. 
%     T is a cell arrray of strings or numbers 
%Example
%  % example to export a data matrix with column and row names
%   load carbig
%   X  = [MPG Acceleration Weight];  
%   tbl =  table( {'Origin', 'MPG', 'Acceleration', 'Weight', 'Displacement'}, ..., 
%                cellstr(Origin), ...    % cell arrays are supported
%                X, ...                  % matrices are supported
%                Displacement);          % any number of columns are supported
%   export( 'example_table.xls', tbl);   % save as tab delimited text

% $Id: table.m,v 1.6 2006/12/26 22:54:13 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

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

% calculate the required table size 
% This is done so we can preallocate table
% which makes a large performance difference for
% vey large tables 

ncols = 0;

for i = 1:length(varargin)
    f = varargin{i};
                                                                                                                                                          
    if (size(f,1) ~= nrows) && isvector(f)
        f = f(:);
    end;
                                                                                                                                                          
    if size(f,1) ~= nrows
        istr = num2ord(i);
        error( 'linstats:table:InvalidArgument', 'the %s data term must contain %d rows', istr, nrows );
    end
                                                                                                                                                          
    if isnumeric( f )
        [mm,nn] = size(f);
        ncols(end+1) = nn; %#ok
    else
        ncols(end+1) = 1; %#ok
    end;
end

total_cols = sum(ncols);
T      = cell(nrows+hasheader,total_cols);      % preallocate the minimum number of columns

currow  = 1 + hasheader;
curcol = 1;                      % insert next vector at this position
 

for i = 1:length(varargin)
    f = varargin{i};

    if (size(f,1) ~= nrows) && isvector(f) 
        f = f(:);
    end;

    % if numberic build a vector for each cell_array

    [mm,nn] = size(f);
    if isnumeric(f)
        f = num2cell(f);
    elseif ischar(f)
        f = cellstr(f);
        nn = 1;
    end;
    T(currow:end,curcol:curcol+nn-1) = f;
    curcol = curcol+nn;
end

ncols = length(col_names);
if hasheader
      if (ncols > curcol-1)
          error('linstats:mscatter:InvalidArgument', 'too many column headings');
      end
      
      T(1,1:ncols) = col_names(:);
end;


