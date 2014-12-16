function EEG = eeglab_subject_testart(input_file_name, output_path)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition in the same file
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured

[path,name_noext,ext] = fileparts(input_file_name);



EEG = pop_loadset(input_file_name);

EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 2, 0.5);
EEG = eeg_checkset( EEG );


% EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [50],'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  30]});
% EEG = eeg_checkset( EEG );


EEG = eeg_checkset( EEG );
% EEG = pop_autobsseog( EEG, [], [], 'sobi', {'eigratio', [1000000]}, 'eog_fd', {'range',[2  21]});
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',[name_noext,'_mc'],'filepath',output_path);
end


