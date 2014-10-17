%% function distances = eeglab_subject_events_distances_two_triggers_classes(input_file_name, start_codes, end_codes)
% scan all data looking for one event with code listed in the start_codes cell array
% then check if next event is one of those listed in the end_codes cell array.
% if so: write time distance between the two triggers 

% OUTPUT:  cell array with a number of row equal to the number of start_codes EVs , with inside {start ev type, end-start latency}
%%

function distances = eeglab_subject_events_distances_two_triggers_classes(input_file_name, start_codes, end_codes)

    EEG = pop_loadset(input_file_name);

    % force input trigger code to be a string
    for ev=1:length(start_codes)
        if isnumeric(start_codes{ev})
            start_codes{ev}=num2str(start_codes{ev});
        end
    end
    for ev=1:length(end_codes)
        if isnumeric(end_codes{ev})
            end_codes{ev}=num2str(end_codes{ev});
        end
    end     
    
 
    all_events_latency  = [EEG.event.latency];
    all_events_type     = {EEG.event.type};

    numev               = size(all_events_type, 2);
    distances           = {};

    valid_ev            = 0;
    for ev=1:(numev-1)
        for st=1:length(start_codes)
            if (strcmp(all_events_type{ev}, start_codes{st}))
                valid_ev        = valid_ev + 1;
                
                end_ev = all_events_type{ev+1};
                for et=1:length(end_codes)
                    if (strcmp(end_ev, end_codes{et}))
                        distances{valid_ev,1} = start_codes{st};
                        distances{valid_ev,2} = (all_events_latency(ev+1) - all_events_latency(ev))/EEG.srate;
                        continue;
                    end
                end
                continue;
            end
        end
    end
end