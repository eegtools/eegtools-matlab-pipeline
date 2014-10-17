function j = regexpfind( str, pat )
%REGEXPFIND use regular expression to find patters
%
% wrapper around matlabsregexpi to make it MUCH more friendly
%
% returns a boolean vector,j, of matches in cell_str to thesearch string
% pat. Now isn't this much better than getting back the junk from matlab's
% regexp? Also, isn't this much better than having to change your strings
% into cell arrays? 
%
% Example
%   load carbig Origin
%   j = regexpfind( Origin, '^....a' );    


% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if ischar(str)
    str = cellstr(str);
end;
        
i = regexpi( str, pat );
j = cellfun(@isempty,i);
j = ~j;