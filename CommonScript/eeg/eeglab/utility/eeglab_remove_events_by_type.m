function eeglab_remove_events_by_type(filename, eventstype2remove)

    [newpath, newname_noext, ext] = fileparts(filename);
    
    EEG         = pop_loadset(filename);
    
    if not(iscell(eventstype2remove))
        error('eeglab_remove_events_by_type: list of events 2 remove is not a cella array');        
    end
    
    arr2remove  = ismember({EEG.event.type}, eventstype2remove);
    
    lev         = length({EEG.event.type});
    id2remove   = find(arr2remove>0);
    
    EEG         = pop_editeventvals(EEG, 'delete', id2remove);
    EEG         = eeg_checkset(EEG);
    EEG         = pop_saveset(EEG,'filename', newname_noext, 'filepath', newpath);
    
end
