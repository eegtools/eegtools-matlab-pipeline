function EEG = eeglab_subject_events_move_event(input_file_name, original_code, shift_time)

    % scan all data looking for events with code: newev1_position_code
    % there insert a new code with value: newev1_code
    % then insert a further event with code 'newev2_code', 'timebefore_newev2_code' ms before the next event 
    % settings_path is the full path of the settings file of the project
    % start situation:          12       34       6           45
    % call parameters (file, 6, 2, 3, XX, file)
    % final situation:          12       34       6,2     3   45
    %                                                     <--->
    %                                                     timebefore_newev2_code seconds                                                     

    EEG = pop_loadset(input_file_name);

    % force input trigger code to be a string
    if isnumeric(original_code)
        original_code=num2str(original_code);
    end
 
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};

    numev = size(all_events_type, 2);
    for ev=1:(numev)
        if (strcmp(all_events_type{ev},original_code))
            EEG.event(ev).latency  = all_events_latency(ev) + shift_time*EEG.srate;            
        end
    end

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end