%% function distances = eeglab_subject_events_distances_three_triggers_classes(input_file_name, start_codes, mid_codes, end_codes)
% scan all data looking for one event with code listed in the start_codes cell array
% then check if next event (ev+1) is one of those listed in the mid_codes cell array.
% if so: write time distance between the two triggers 
% then check if next event (ev+2) is one of those listed in the end_codes cell array.
% if so: write time distance between the two triggers 

% OUTPUT:  cell array with a number of row equal to the number of start_codes EVs , with inside {start ev type, mid-start latency, end-mid latency}
%%

function distances = eeglab_subject_events_distances_three_triggers_classes(input_file_name, start_codes, mid_codes, end_codes)

    EEG = pop_loadset(input_file_name);

    all_events_latency  = [EEG.event.latency];
    all_events_type     = {EEG.event.type};
    
    % force input trigger code to be a string
    for ev=1:length(start_codes)
        if isnumeric(start_codes{ev})
            start_codes{ev}=num2str(start_codes{ev});
        end
    end
    for ev=1:length(mid_codes)
        if isnumeric(mid_codes{ev})
            mid_codes{ev}=num2str(mid_codes{ev});
        end
    end    
    for ev=1:length(end_codes)
        if isnumeric(end_codes{ev})
            end_codes{ev}=num2str(end_codes{ev});
        end
    end    
    for ev=1:length(all_events_type)
        if isnumeric(all_events_type{ev})
            all_events_type{ev}=num2str(all_events_type{ev});
        end
    end    
    
 

    numev               = size(all_events_type, 2);
    distances           = {};

    valid_ev            = 0;
    for ev=1:(numev-2)
        for st=1:length(start_codes)
            if (strcmp(all_events_type{ev}, start_codes{st}))
                valid_ev        = valid_ev + 1;

                mid_ev = all_events_type{ev+1};
                for mt=1:length(mid_codes)
                    if (strcmp(mid_ev, mid_codes{mt}))
                        distances{valid_ev,1} = start_codes{st};
                        distances{valid_ev,2} = (all_events_latency(ev+1) - all_events_latency(ev))/EEG.srate;
                        continue;
                    end
                end
                
                end_ev = all_events_type{ev+2};
                for et=1:length(end_codes)
                    if (strcmp(end_ev, end_codes{et}))
                        distances{valid_ev,3} = (all_events_latency(ev+2) - all_events_latency(ev+1))/EEG.srate;
                        continue;
                    end
                end
                continue;
            end
        end
    end
end