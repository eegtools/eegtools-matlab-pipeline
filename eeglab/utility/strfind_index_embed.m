function [out] = strfind_index_embed(cell_array,single_string)

if iscell(single_string)
    single_string = single_string{:};
end

    tcell = length(cell_array);
    sum_match = nan(size(cell_array));
    logical_match = cell(size(cell_array));
    str_match = cell(size(cell_array));
    all_contiguous_chars =  false(size(cell_array));
%     max_distance_char = zeros(size(cell_array));
%     all_contiguous_chars =  false(size(cell_array));
    for ncell = 1:tcell
        current_cell = cell_array{ncell};
        logical_match{ncell} = ismember(current_cell, single_string);        
        sum_match(ncell) = sum(logical_match{ncell});
        str_match{ncell} = current_cell(logical_match{ncell});
        all_contiguous_chars(ncell) = sum((regexp(single_string,current_cell)))>0;
%         max_distance_char(ncell) = sum(max(diff(find(ismember(single_string,current_cell)))));
%         all_contiguous_chars(ncell) = max_distance_char(ncell) == 1;

    end
    ind_match = find(sum_match);
    unique_match = unique(str_match); 
    ind_ch_match = ismember(unique_match,cell_array(all_contiguous_chars));
    ch_match = unique_match(ind_ch_match);
    match_length = cellfun(@length,ch_match);
    max_match_length = max(match_length);
    sel_best_match = match_length == max_match_length;
    best_match = ch_match(sel_best_match);
    
        
%     out.max_distance_char=max_distance_char;
% 
%     out.all_contiguous_chars=all_contiguous_chars;
    out.ind_match = ind_match;
    out.logical_match = logical_match;
    out.sum_match = sum_match;
    out.str_match = str_match;
    out.unique_match = unique_match;
    out.ch_match = ch_match;
    out.best_match = best_match;
    
end