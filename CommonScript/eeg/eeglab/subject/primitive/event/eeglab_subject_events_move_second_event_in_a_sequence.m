function EEG = eeglab_subject_events_move_second_event_in_a_sequence(input_file_name, class_eve1, class_eve2, timeshift)

    % function EEG = eeglab_subject_events_move_second_event_in_a_sequence(input_file_name, class_eve1, class_eve2, max_delay,code_new_eve,  settings_path)
    % characterizes the occurrence of one class of event eve1 before another eve2.
    % the second event is moved by "timeshift" seconds 

    EEG = pop_loadset(input_file_name);

    %select target event eve1 followed by event eve2
    [trgs,urnbrs,urnbrtypes,delays,tflds,urnflds] = eeg_context(EEG,class_eve1,class_eve2,1);  

    % number of selected events
    nevents = size(trgs,1);

    for index = 1 : nevents
        EEG.event(trgs(index,1)+1).latency = EEG.event(trgs(index,1)+1).latency + EEG.srate*timeshift;
    end

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end