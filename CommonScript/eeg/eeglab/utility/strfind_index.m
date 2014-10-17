function [Index] = strfind_index(cell_array,string)

IndexC = strfind(cell_array, string);
Index = find(not(cellfun('isempty', IndexC)));

end