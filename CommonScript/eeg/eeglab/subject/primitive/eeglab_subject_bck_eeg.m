function EEG = eeglab_subject_bck_eeg(EEG,bck)

bck_filepath       = bck.dir;
prefix             = bck.prefix;
 
bck_filename = [prefix, EEG.filename];

if not(isdir(bck_filepath))
    mkdir(bck_filepath)
end

EEG = pop_saveset(EEG, 'filename',bck_filename, 'filepath', bck_filepath);



end