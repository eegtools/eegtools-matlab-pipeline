function cellout = struct2varargin(struct)
    field_names = fieldnames(struct);
    tf = length(field_names);
    cellout = [];    
    for nf = 1:tf
        current_name = field_names{nf};
        current_arg = struct.(current_name);
        if not(isempty(current_arg))
            cellout = [cellout,{current_name},{current_arg}];
        end
    end
end