function eeglab_load_and_save_set(set_path)

    [path,name_noext,ext] = fileparts(set_path);
    EEG = pop_loadset(set_path);
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG,'filename',name_noext, 'filepath', path);
end
