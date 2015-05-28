function EEG = eeglab_subject_testart(input_file_name, output_file_name)

[path,name_noext,ext] = fileparts(input_file_name);
[path2,name_noext2,ext] = fileparts(output_file_name);


EEG     = pop_loadset(input_file_name);
EEG     = pop_select(EEG,'channel',1:64);
EEG     = pop_eegfiltnew( EEG,1, 45, [], 0, [], 0);

try
    EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 2, 0.5);
    EEG = eeg_checkset( EEG );    
    EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    
    %     EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio', 50,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  30]});
    EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio',50,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  45]});    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    
    EEG = pop_autobsseog( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[0  8]});
    EEG = eeg_checkset( EEG );    
    EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    
%     OUTEEG = pop_reref(OUTEEG, [], 'keepref', 'on');
%     EEG = eeg_checkset( EEG );    
    
%     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)
end
end


