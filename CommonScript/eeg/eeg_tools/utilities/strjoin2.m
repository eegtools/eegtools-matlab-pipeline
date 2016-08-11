function outstring = strjoin2(cell, delimiter)
    outstring            = cell{1};
    for x=2:length(cell)
        outstring = [outstring delimiter cell{x}];
    end
end