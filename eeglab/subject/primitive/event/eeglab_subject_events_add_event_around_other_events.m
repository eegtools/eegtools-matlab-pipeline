function EEG = eeglab_subject_events_add_event_around_other_events(input_file_name, original_codes, new_code, timearound_original_code)

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
    for ev=1:length(original_codes)
        if isnumeric(original_codes{ev})
            original_codes{ev}=num2str(original_codes{ev});
        end
    end
    if isnumeric(new_code)
        new_code=num2str(new_code);
    end
 
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};

    numev = size(all_events_type, 2);
    for ev=1:(numev)
        for cd=1:length(original_codes)
            if (strcmp(all_events_type{ev}, original_codes{cd}))
                EEG.event(end+1)        = EEG.event(ev); ... EEG.event(selev(index)); % Add event to end of event list
                EEG.event(end).type     = new_code;
                EEG.event(end).latency  = all_events_latency(ev) + timearound_original_code*EEG.srate;            
            end
        end
    end

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end