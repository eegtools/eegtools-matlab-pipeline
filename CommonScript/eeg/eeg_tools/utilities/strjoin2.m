% emulate the strjoin function introduced in matlab 2013.
% join a cell array of string, introducing a delimiter, into a single string
function outstring = strjoin2(cell, varargin)

    if not(nargin-1)
        delimiter = ''; 
    else
        delimiter = varargin{1}; 
    end
        
    outstring            = cell{1};
    for x=2:length(cell)
        outstring = [outstring delimiter cell{x}];
    end
end