function EEG = eeglab_subject_bck_eeghist(EEG,bck)

bck_filepath       = bck.dir;
prefix             = bck.prefix;
 
bck_filename = [prefix, EEG.filename,'.m'];

if not(isdir(bck_filepath))
    mkdir(bck_filepath)
end

pop_saveh( EEG.history, bck_filename, bck_filepath);



end