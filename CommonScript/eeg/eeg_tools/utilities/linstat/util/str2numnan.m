function num = str2numnan( str )
% STR2NUMNAN converts a str of cellstr into numbers
%
% converts cell array or character arrays into numbers
% and converts white space strings to NaN;
%
% num = str2numnan( STR )
% STR is a character array or cell array of strings with m elements
% returns a m x 1 vector of numberic representations
%
% Example
%   S = { '1' '2' ' ' '4000'}';
%   str2numnan(S);         % works with cell arrays of strings
%   str2numnan(char(S));   % works with char arrays
%   str2num(S);            % matlab's str2num fails
%   str2num(char(S));      % matlab's str2num skips some rows in S

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

c = 0;
if iscell(str)
    c = 1;
    [m0,n0] = size(str); %original size
    str = char(str);
end;

k = find( all(str==32,2) );
if ~isempty(k)
    [m n] = size(str);
    if ( n < 3 )
        pad = repmat( ' ', m, 3-n );
        str = [pad str];
    end
    str(k,end-2:end) = repmat( 'nan', length(k), 1 );
end
num = str2num(str); %#ok

if c == 1   % input was cell array of strings, so go back to original size
    num = reshape(num, [m0 n0] );
end