function errors = eeglab_subject_events_check_2triggers_orders(input_file_name, trigger_code1, trigger_code2)
%    
%    check if trigger_code1 is ALWAYS followed by a trigger_code2

    EEG = pop_loadset(input_file_name);
    
    if isnumeric(trigger_code1)
        trigger_code1=num2str(trigger_code1);
    end
    
    if isnumeric(trigger_code2)
        trigger_code2=num2str(trigger_code2);
    end
    
    errors=[];
    numev = size(EEG.event,2);
    for ev=1:(numev-1)
        if (strcmp(EEG.event(ev).type, trigger_code1))
           if (~strcmp(EEG.event(ev+1).type, trigger_code2))
               errors=[errors ev];
           end
        end
    end
end