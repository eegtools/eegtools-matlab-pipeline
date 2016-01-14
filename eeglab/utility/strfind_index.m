function [Index logical] = strfind_index(cell_array,string)
if iscell(string)
    Index = [];
    ls = length(string);
    
    for ns =1:ls
        IndexC = strfind(cell_array, string{ns});
        Index0 = find(not(cellfun('isempty', IndexC)));
        Index = [Index,Index0];
    end
    Index = sort(Index);
    
else
    
    IndexC = strfind(cell_array, string);
    Index = find(not(cellfun('isempty', IndexC)));
    
end

logical = ismember(1:length(cell_array),Index);
end