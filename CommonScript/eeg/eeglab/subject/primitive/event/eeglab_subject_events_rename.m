%% EEG = eeglab_subject_events_rename(input_file_name, old_names, new_names)
% scan all data looking for one event with code listed in the start_codes cell array
% then check if next event is one of those listed in the end_codes cell array.
% if so: write time distance between the two triggers 

% OUTPUT:  cell array with a number of row equal to the number of start_codes EVs , with inside {start ev type, end-start latency}
%%

function EEG = eeglab_subject_events_rename(input_file_name, old_names, new_names)

    [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
    EEG = pop_loadset(input_file_name);

    if length(old_names) ~= length(new_names)
        disp('error in eeglab_subject_events_rename: number of elements of input parameters differ');
        return;
    end
    
    all_events_type     = {EEG.event.type};

    numev               = size(all_events_type, 2);

    for ev=1:numev
        for nev=1:length(old_names)
            if (strcmp(all_events_type{ev}, old_names{nev}))
                EEG.event(ev).type = new_names{nev}; 
                disp(['rename event in file: ' input_name_noext]);
                continue;
            end
        end
    end
    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency    
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);    
end