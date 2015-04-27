function  EEG =  eeglab_subject_add_label_eve_around( input_file_name, class_eve,list_class_eve,lagvec)

   
    EEG = pop_loadset(input_file_name);
            
    list_tot_eve={EEG.event.type};   
    tot_eve=length(list_tot_eve);
    
    EEG2=EEG;
    
    seleve=ismember(list_tot_eve,list_class_eve);    
    events=EEG2.event(seleve);
    EEG2.event=events;
    list_tot_eve2={EEG2.event.type};   
    tot_eve2=length(list_tot_eve2);
    

    % select the event to which we want to append the labels
    [trgs,urnbrs,urnbrtypes,delays,tflds,urnflds] = eeg_context(EEG2,class_eve);
    % trgs      - size(ntargets,4) matrix giving the indices of target events in the event structure in column 1 
    % and in the urevent structure in column 2.
    

    trgs_eve_ind=trgs(:,1);
    tot_trgs=length(trgs_eve_ind);
    
%     ll={EEG2.event(trgs_eve_ind).type}
%     display(ll)
    
    list_eve_around=cell(1,tot_trgs);
    for ntrg=1:tot_trgs%1:tot_trgs

        ind_trg=trgs_eve_ind(ntrg);
        ind_around=lagvec+ind_trg;
        
%         display(ind_trg)
%         display(ind_around)
        
        if min(ind_around)>0 && max(ind_around)<=tot_eve2


            around_labels=list_tot_eve2(ind_around);
            if ~ isempty(around_labels)
                around_merged_label=list_tot_eve2{trgs_eve_ind(ntrg)};
                bind='_';
                for nlab=1:length(around_labels)
                    around_merged_label=[around_merged_label,bind,around_labels{nlab}];            
                end
            end
            list_eve_around{ntrg}=around_merged_label;
        end
    end

%     display(list_eve_around)
    
     for index = 1 : tot_trgs
         
         code_new_eve=list_eve_around{index};
         if ~ isempty(code_new_eve)
              % Add events relative to existing events
              EEG.event(end+1) = events(trgs_eve_ind(index)); % Add event to end of event list
              EEG.event(end).type = code_new_eve; ...'S201';
         end
     end;
      
     EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
     EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    
end
            
            