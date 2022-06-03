function [EEG] = eeglab_subject_segmenting(input_file_name,input)
%EEG = [];

% if not(isempty(segm2remove_sec))
    [file_path, name_noext, ext] = fileparts(input_file_name);
%     EEG = pop_loadset(input_file_name);

    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end

    
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
        if (not(exist(input.output_folder)))
            mkdir(input.output_folder);
        end
        if sum(sel_b1) == sum(sel_b2) 
            tb = length(input.baseline_lab);
            for nb = 1:tb
                if tb == 1
                    name_baseline = [name_noext,'_','baseline',ext];
                else
                    current_baseline_lab = input.baseline_lab{nb};
                    name_baseline = [name_noext,'_',current_baseline_lab,ext];
                end
            
                disp(name_baseline);
            EEG2 = pop_select( EEG, ...
                'point',[b1_latency(nb) b2_latency(nb)] );
            EEG2 = pop_saveset(...
                EEG2, ...
                'filename',...
                name_baseline,...
                'filepath',...
                input.output_folder);
            end
            
        end
        
        
        ts = length(begin_latencies);
        
        % per ciascun segmento andiamo a segmentare
        for ns = 1:ts
            current_label = input.list_label{ns};
            disp(current_label);
            EEG2 = pop_select( EEG, ...
                'point',[begin_latencies(ns) end_latencies(ns)] );
            EEG2 = pop_saveset(...
                EEG2, ...
                'filename',...
                [name_noext,'_',current_label,ext],...
                'filepath',...
                input.output_folder);
        end
        
    end
    
    
end
% end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
