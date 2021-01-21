function [EEG] = eeglab_subject_recover_ica(input_file_name)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition
%    in the same filei
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured

[file_path, name_noext, ext] = fileparts(input_file_name);

%  icadir = fullfile(file_path,'icadir');
% 
% fname_out_ica = fullfile(icadir,[name_noext, '.mat']);
% load(fname_out_ica);

full_path_bck = fullfile(file_path,[name_noext,'_icabck', ext]); 


EEG = pop_loadset(full_path_bck);

% EEG.icaweights = out_ica.icaweights;
% EEG.icasphere  = out_ica.icasphere;
% EEG.icachansind  = out_ica.icachansind;
% EEG.icawinv  = out_ica.icawinv;
% EEG.icaact = out_ica.icaact;

% EEG = eeg_checkset(EEG);
% eeglab redraw;


EEG = pop_saveset( EEG, 'filename',[name_noext, ext],'filepath',EEG.filepath);



% out_ica.icaweights = EEG.icaweights;
% out_ica.icasphere  = EEG.icasphere;
% out_ica.icachansind  = EEG.icachansind;
% out_ica.icawinv  = EEG.icawinv;
% out_ica.icaact = EEG.icaact;



% EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);

end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
