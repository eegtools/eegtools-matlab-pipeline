function [EEG] = eeglab_subject_remove_segments(input_file_name,segm2remove_sec)
%EEG = [];

if not(isempty(segm2remove_sec))    
    [file_path, name_noext, ext] = fileparts(input_file_name);
%     EEG = pop_loadset(input_file_name);

    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end
    segm2remove_pts = segm2remove_sec*EEG.srate;
    EEG = eeg_eegrej( EEG,   segm2remove_pts);
    EEG = pop_saveset( EEG, 'filename',[name_noext, ext],'filepath',EEG.filepath);    
end
end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
