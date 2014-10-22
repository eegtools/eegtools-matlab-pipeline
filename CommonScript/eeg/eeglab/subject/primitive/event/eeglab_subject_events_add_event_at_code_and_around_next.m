function EEG = eeglab_subject_events_add_event_at_code_and_around_next(input_file_name, newev1_position_code, newev1_code, newev2_code, timearound_newev2_code)

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
    if isnumeric(newev1_position_code)
        newev1_position_code=num2str(newev1_position_code);
    end
    if isnumeric(newev1_code)
        newev1_code=num2str(newev1_code);
    end
    if isnumeric(newev2_code)
        newev2_code=num2str(newev2_code);
    end


    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};

    numev = size(all_events_type, 2);
    new_events_num=0;
    for ev=1:(numev-1)
        curr_ev=all_events_type{ev};
        if (strcmp(all_events_type{ev},newev1_position_code))
            
            EEG.event(end+1) = EEG.event(ev); ... EEG.event(selev(index)); % Add event to end of event list
            EEG.event(end).type = newev1_code;
            EEG.event(end).latency = all_events_latency(ev);
           
%             new_events_num=new_events_num+1;
%             newev.type=newev1_code;
%             newev.latency=all_events_latency(ev);
%             newev.ev=EEG.event(ev);
%             new_events_list{new_events_num}=newev;

            EEG.event(end+1) = EEG.event(ev); ... EEG.event(selev(index)); % Add event to end of event list
            EEG.event(end).type = newev2_code;
            EEG.event(end).latency = all_events_latency(ev+1) + timearound_newev2_code*EEG.srate;
            
%             new_events_num=new_events_num+1;
%             newev.type=newev2_code;
%             newev.latency=all_events_latency(ev+1)-timebefore_newev2_code*EEG.srate;
%             newev.ev=EEG.event(ev+1);
%             new_events_list{new_events_num}=newev;
        end
    end

%     % number of selected events
%     nevents = size(new_events_list,2);
%     for index = 1 : nevents
%         % Add events relative to existing events
%         newev=new_events_list{index};
%         EEG.event(end+1) = newev.ev; ... EEG.event(selev(index)); % Add event to end of event list
%         EEG.event(end).type = newev.type;
%         EEG.event(end).latency = newev.latency;
% 
%     end;

    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
end