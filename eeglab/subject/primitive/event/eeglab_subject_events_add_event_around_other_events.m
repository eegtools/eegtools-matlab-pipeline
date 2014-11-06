%% EEG = eeglab_subject_events_add_event_around_other_events(input_file_name, original_codes, new_code, timearound_original_code)
%
% scan all data looking for events with code: original_codes
% there insert a new code with value: new_code at around timearound_original_code
%
%%
function EEG = eeglab_subject_events_add_event_around_other_events(input_file_name, original_codes, new_code, timearound_original_code)

                                                    
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