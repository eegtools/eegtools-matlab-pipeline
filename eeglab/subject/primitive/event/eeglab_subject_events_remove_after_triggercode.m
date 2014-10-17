function EEG = eeglab_subject_events_remove_after_triggercode(input_file_name, trigger_code)
%    
%    EEG = eeglab_subject_remove_after_triggercode(input_file_name, output_path, trigger_code, settings_path)
%    removes data segments from the first occurence of the marker code specified and the end of the video
%    input_file_name is the full path of the input file (.set EEGLab format)
%    trigger_code is the string denoting the trigger code defining where to stop the segments removal
%    settings_path is the full path of the settings file of the project
%    IMPORTANT: FILE WILL BE OVERWRITTEN (because pauses are useless for following processing)

    EEG                 = pop_loadset(input_file_name);
    
    all_events_latency  = [EEG.event.latency];
    all_events_type     = {EEG.event.type};
    
    % force input trigger code to be a string
    if isnumeric(trigger_code)
        trigger_code = num2str(trigger_code);
    end
        
    start_pause=0;
    for ev=1:size(all_events_type,2)
        type = all_events_type{ev};
        if(strcmp(type,trigger_code))
            start_pause = all_events_latency(ev);
            break;
        end
    end
    
    if (start_pause > 0)
        latency = (start_pause-1)/EEG.srate;

        EEG     = pop_select( EEG, 'notime', [latency EEG.xmax]);
        EEG     = pop_saveset( EEG , 'filename', EEG.filename ,'filepath', EEG.filepath);
    else
        disp('--------------------------------------------------------------------------------');
        disp('=====>> no interval removed by eeglab_subject_events_remove_after_triggercode');
    end        
end