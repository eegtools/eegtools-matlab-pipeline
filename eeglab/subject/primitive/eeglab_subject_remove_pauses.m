function EEG = eeglab_subject_remove_pauses(EEG, start_pause_code, stop_pause_code)
    %    
    %    EEG = eeglab_subject_remove_pauses(input_file_name, output_path, start_pause_code, stop_pause_code, settings_path)
    %    removes data segments corresponding to experimental pauses: it is
    %    supposed that all pauses have a start and a stop marker.  
    %    input_file_name is the full path of the input file (.set EEGLab format)
    %    start_pause_code is the string denoting the start of the pauses
    %    stop_pause_code is the string denoting the end of the pauses
    %    settings_path is the full path of the settings file of the project
    %IMPORTANT: FILE WILL BE OVERWRITTEN (because pauses are useless for following processing)

%     EEG = pop_loadset(input_file_name);
    
    if isnumeric(start_pause_code)
        start_pause_code=num2str(start_pause_code);
    end
    
    if isnumeric(stop_pause_code)
        stop_pause_code=num2str(stop_pause_code);
    end    
    
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};
    
    select_start_pauses=strcmp(all_events_type,{start_pause_code});
    select_stop_pauses=strcmp(all_events_type,{stop_pause_code});
    
    start_pauses=floor(all_events_latency(select_start_pauses));
    stop_pauses=ceil(all_events_latency(select_stop_pauses)); 
    
    if (length(start_pauses) ~= length(stop_pauses))
        disp ('!!!!!!!!  ERROR !!!!!!! : num start pauses differs from end ones');
        disp(start_pauses)
        disp(stop_pauses)
        return
    end
    numinterval_removed=num2str(length(start_pauses));
    disp(['removing ' numinterval_removed ' intervals']);
    
    EEG = eeg_eegrej(EEG, [start_pauses;stop_pauses]');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', EEG.filename , 'filepath', EEG.filepath);
end


% function EEG = eeglab_subject_remove_pauses(input_file_name, start_pause_code, stop_pause_code)
%     %    
%     %    EEG = eeglab_subject_remove_pauses(input_file_name, output_path, start_pause_code, stop_pause_code, settings_path)
%     %    removes data segments corresponding to experimental pauses: it is
%     %    supposed that all pauses have a start and a stop marker.  
%     %    input_file_name is the full path of the input file (.set EEGLab format)
%     %    start_pause_code is the string denoting the start of the pauses
%     %    stop_pause_code is the string denoting the end of the pauses
%     %    settings_path is the full path of the settings file of the project
%     %IMPORTANT: FILE WILL BE OVERWRITTEN (because pauses are useless for following processing)
% 
%     EEG = pop_loadset(input_file_name);
%     
%     if isnumeric(start_pause_code)
%         start_pause_code=num2str(start_pause_code);
%     end
%     
%     if isnumeric(stop_pause_code)
%         stop_pause_code=num2str(stop_pause_code);
%     end    
%     
%     all_events_latency=[EEG.event.latency];
%     all_events_type={EEG.event.type};
%     
%     select_start_pauses=strcmp(all_events_type,{start_pause_code});
%     select_stop_pauses=strcmp(all_events_type,{stop_pause_code});
%     
%     start_pauses=floor(all_events_latency(select_start_pauses));
%     stop_pauses=ceil(all_events_latency(select_stop_pauses)); 
%     
%     if (length(start_pauses) ~= length(stop_pauses))
%         disp ('!!!!!!!!  ERROR !!!!!!! : num start pauses differs from end ones');
%         start_pauses
%         stop_pauses
%         return
%     end
%     numinterval_removed=num2str(length(start_pauses));
%     disp(['removing ' numinterval_removed ' intervals']);
%     
%     EEG = eeg_eegrej(EEG, [start_pauses;stop_pauses]');
%     EEG = eeg_checkset(EEG);
%     EEG = pop_saveset(EEG, 'filename', EEG.filename , 'filepath', EEG.filepath);
% end