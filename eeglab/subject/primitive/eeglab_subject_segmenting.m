function [EEG] = eeglab_subject_segmenting(input_file_name,input)
%EEG = [];

% if not(isempty(segm2remove_sec))
    [file_path, name_noext, ext] = fileparts(input_file_name);
    EEG = pop_loadset(input_file_name);
    
    all_eve_labels = {EEG.event.type};
    all_eve_latencies = [EEG.event.latency];
    
    sel_b1 = ismember(all_eve_labels, input.baseline_begin);
    b1_latency = all_eve_latencies(sel_b1);
    
    
    sel_b2 = ismember(all_eve_labels, input.baseline_end);
    b2_latency = all_eve_latencies(sel_b2);
    
    sel_begin = ismember(all_eve_labels, input.list_begin);
    begin_latencies = all_eve_latencies(sel_begin);    
    
    sel_end = ismember(all_eve_labels, input.list_end);
    end_latencies = all_eve_latencies(sel_end);
    
    
   
    
    if length(begin_latencies) == length(end_latencies)
        
        if sum(sel_b1) == 1 && sum(sel_b2) == 1
            
            EEG2 = pop_select( EEG, ...
                'point',[b1_latency b2_latency] );
            EEG2 = pop_saveset(...
                EEG2, ...
                'filename',...
                [name_noext,'_baseline',ext],...
                'filepath',...
                input.output_folder);
            
        end
        
        
        ts = length(begin_latencies);
        
        % per ciascun segmento andiamo a segmentare
        for ns = 1:ts
            EEG2 = pop_select( EEG, ...
                'point',[begin_latencies(ns) end_latencies(ns)] );
            EEG2 = pop_saveset(...
                EEG2, ...
                'filename',...
                [name_noext,'_',input.list_label{ns},ext],...
                'filepath',...
                input.output_folder);
        end
        
    end
    
    
end
% end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
