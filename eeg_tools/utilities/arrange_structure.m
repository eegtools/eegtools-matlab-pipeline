function out_structure = arrange_structure(in_structure, field)

    len1    = length(in_structure);
    switch field
        case {'group_time_windows', 'subject_time_windows'}
            len2 = length((in_structure(1).(field)));
            
            out_structure = cell(len1, 1);
            for d=1:len1
                for tw=1:len2
                    str = ((in_structure(d).(field)(tw)));
                    out_structure{d}{tw} = [str.min str.max];
                end                
            end
        case 'group_time_windows_names'
            len2 = length((in_structure(1).('group_time_windows')));            
            out_structure = cell(len1, 1);
            for d=1:len1
                for tw=1:len2
                    str = ((in_structure(d).('group_time_windows')(tw)));
                    out_structure{d}{tw} = char(str.name);
                end                
            end           
    end

end