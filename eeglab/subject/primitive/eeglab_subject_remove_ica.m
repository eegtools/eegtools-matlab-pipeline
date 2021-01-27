function [EEG] = eeglab_subject_remove_ica(input_file_name,ic2remove)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition
%    in the same filei
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured

EEG = [];

if not(isempty(ic2remove))    
    [file_path, name_noext, ext] = fileparts(input_file_name);
%     EEG = pop_loadset(input_file_name);

    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end


    EEG = pop_subcomp( EEG, ic2remove, 0);
    EEG = pop_saveset( EEG, 'filename',[name_noext, ext],'filepath',EEG.filepath);    
end


end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
