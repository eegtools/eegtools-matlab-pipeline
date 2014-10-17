function EEG = eeglab_subject_events_add_eve1_pre_eve2(input_file_name, class_eve1, class_eve2, max_delay,code_new_eve)

    % function EEG = eeglab_subject_add_eve1_pre_eve2(input_file_name, class_eve1, class_eve2, max_delay,code_new_eve,  settings_path)
    % characterizes the occurrence of one class of event eve1 before another eve2 (in case it was not already done in recording phase).
    % the old trigger is kept, while a new one is added to distinguish the special occurrrence:
    % input_file_name:      is the full path of the input file (.set EEGLab format)
    % class_eve1/2:         is a string corresponding to the code or type eve1/2: see event_classes=unique({EEG.event.type}) ;
    % max_delay:            is the maximum delay allowed for eve2 (eg. to avoid too late responses)
    % code_new_eve:         is the code (type) to be assigned to the new class of events
    % settings_path:        is the full path of the settings file of the project


    EEG = pop_loadset(input_file_name);


    %select target event eve1 followed by event eve2
    [trgs,urnbrs,urnbrtypes,delays,tflds,urnflds] = eeg_context(EEG,class_eve1,class_eve2,1);  

    %select only events with a delay shorter than max_delay
    selev=[];
    for e=1:length(trgs) % For each target event,
        if abs(delays(e)) < max_delay ... 1500 ...  % if  delay in acceptable range	
            selev = [selev trgs(e,1)];  % mark target for selection
        end
    end

    % number of selected events
    nevents = length(selev);
    disp(['inserting ' num2str(nevents) ' events']);

    for index = 1 : nevents
        % Add events relative to existing events
        EEG.event(end+1) = EEG.event(selev(index)); % Add event to end of event list
        EEG.event(end).type = code_new_eve; ...'S201';

    end;

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end