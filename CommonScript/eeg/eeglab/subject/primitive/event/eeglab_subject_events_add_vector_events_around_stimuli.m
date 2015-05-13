function EEG = eeglab_subject_events_add_vector_events_around_stimuli(input_file_name1,data_vector, new_marker_type, new_marker_class)

% load configuration file   
EEG = pop_loadset(input_file_name1);


% Add new events to a loaded dataset         
        nevents = length(EEG.event);
        i = 1;
        for index = 1 : nevents
           if strcmpi(EEG.event(index).type, 'S20')     % Add events relative to existing events
                EEG.event(end+1) = EEG.event(index);    % Add event to end of event list
                ...EEG.event(end).latency = EEG.event(index).latency + (data_vector(EEG.event(index).epoch)/1000)*EEG.srate;    %  ...     % Specifying the event latency  before the referent event (in real data points) 
                EEG.event(end).latency = EEG.event(index).latency + (data_vector(i)/1000)*EEG.srate;    %  ...     % Specifying the event latency  before the referent event (in real data points) 
                EEG.event(end).type = new_marker_type;    % Make the type of the new event 'P'
                ...EEG.event(end).code = new_marker_class; 
                i = i+1;
           end;
        end;

        EEG = eeg_checkset(EEG, 'eventconsistency');     % Check all events for consistency
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
        ...EEG = pop_saveset(EEG);
end
        
        
%         EEG = pop_editeventvals( EEG, 'sort', { 'epoch', [0], 'latency', [0] } );     % Re-sort events
%         [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);   % Store dataset
%         eeglab redraw     % Redraw the main eeglab window