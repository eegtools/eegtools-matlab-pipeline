function eeglab_rename_set(oldname, newname)

    [newpath,newname_noext,ext] = fileparts(newname);
    
    EEG = pop_loadset(oldname);
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG,'filename', newname_noext, 'filepath', newpath);
end
