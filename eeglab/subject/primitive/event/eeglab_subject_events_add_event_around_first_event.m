function EEG = eeglab_subject_events_add_event_around_first_event(input_file_name, new_code, timearound_original_code)

    % scan data looking for first event
    % around "timearound_original_code" seconds insert a new code with value: new_code

    EEG = pop_loadset(input_file_name);

    % force input trigger code to be a string
    new_code=num2str(new_code);

    if (strcmp(EEG.event(1).type, 'boundary'))
        disp('--------------------------------------------------------------------------------');
        disp('=====>> first event is a boundary, I did not add a trigger around the first one');
        return;
    end
    if (strcmp(EEG.event(1).type, new_code))
        disp('--------------------------------------------------------------------------------');
        disp('=====>> first event is the same as input one, I did not add a trigger around the first one');
        return;
    end    
    
    first_latency           = EEG.event(1).latency;
    new_code_latency        = first_latency + timearound_original_code*EEG.srate;  
    
    EEG.event(end+1)        = EEG.event(1); ... EEG.event(selev(index)); % Add event to end of event list
    EEG.event(end).type     = new_code;
    EEG.event(end).latency  = new_code_latency;     

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end