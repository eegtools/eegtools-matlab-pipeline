function EEG = eeglab_subject_testart(input)

input_file_name = input.input_file_name;
output_file_name = input.output_file_name;
nch_eeg = input.nch_eeg;
FlatlineCriterion = input.FlatlineCriterion;
Highpass = input.Highpass;
ChannelCriterion = input.ChannelCriterion;
LineNoiseCriterion = input.LineNoiseCriterion;
BurstCriterion     = input.BurstCriterion;
WindowCriterion = input.WindowCriterion;



[path,name_noext,ext] = fileparts(input_file_name);
[path2,name_noext2,ext] = fileparts(output_file_name);


EEG     = pop_loadset(input_file_name);
EEG2    = pop_select(EEG,'channel',1:nch_eeg);
% EEG     = pop_eegfiltnew( EEG,1, 45, [], 0, [], 0);

try
    %      EEG2 = clean_rawdata(EEG2, 5, [0.25 0.75], 0.8, 4, 2, 0.5);
    %      EEG2 = clean_rawdata(EEG2, -1, -1, -1, -1, 2, 0.15);
    %     EEG2 = clean_rawdata(EEG2, 4, [0.25 0.75], 0.85, 4, 5, 0.25);
    
    % pop_prepPipeline(EEG2, struct('referenceChannels', [1:64],'detrendCutoff', 1,'detrendStepSize', 0.02,'detrendType', 'High Pass'));
    
%     EEG2 = clean_rawdata(EEG2, 4, 'off', 0.85, 4, 5, 'off'); % senza rimuovere tw
%     
%     EEG3 = clean_rawdata(EEG2, 4, 'off', 0.85, 4, 5, 0.25); % rimuovendo le tw

%   EEG : Final cleaned EEG recording.
%
%   HP : Optionally just the high-pass filtered data.
%
%   BUR : Optionally the data without final removal of "irrecoverable" windows.

    
    [EEG3,HP,BUR] = clean_artifacts(EEG2, 'FlatlineCriterion', FlatlineCriterion,...
                                'Highpass',          Highpass,...
                                'ChannelCriterion',  ChannelCriterion,...
                                'LineNoiseCriterion',  LineNoiseCriterion,...
                                'BurstCriterion',    BurstCriterion,...
                                'WindowCriterion',   WindowCriterion);
    
    
    % estraggo la maschera con le tw da rimuovere dal tracciato
    
    rej_tw = EEG3.etc.clean_sample_mask;
    % ora rimuovo le tw ma mettendo dei boundary per tracciarli (la funzione
    % non li mette)
    
    mask_remove = not(rej_tw); % 1 ciò che va tolto 
    dd = diff(mask_remove);
    
%     diff_mask_remove0 = [mask_remove(1), dd(1:end-1),   mask_remove(end)];
    
    diff_mask_remove = abs([mask_remove(1), dd(1:end-1),   mask_remove(end)]); % il primo punto non va mai tolto
    
    
    rej_tw_lim_vec = find(diff_mask_remove);    
%     ntw = length(rej_tw_lim_vec)/2;
    rej_tw_lim_mat = [rej_tw_lim_vec(1:2:end-1);rej_tw_lim_vec(2:2:end)]';
    EEG2 = eeg_eegrej( BUR, rej_tw_lim_mat);
    
    EEG2 = eeg_checkset( EEG2 );
    
    
    EEG2 = pop_interp(EEG2, EEG.chanlocs(1:nch_eeg), 'spherical');
    
    ss = size(EEG.data,1);
    
    if ss > nch_eeg
        EEG4 = eeg_eegrej( EEG, rej_tw_lim_mat);
        EEG2.data((nch_eeg+1):ss,:) = EEG4.data((nch_eeg+1):end, :);
        EEG2.chanlocs = EEG.chanlocs;
          EEG2 = eeg_checkset( EEG2 );
    end
    
    %     EEG.data(1:64,:) = EEG2.data;
    
    EEG = pop_saveset( EEG2, 'filename',name_noext2,'filepath',path2);
    
    %     EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio', 50,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  30]});
    %     EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio',50,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  45]});
    %     EEG = eeg_checkset( EEG );
    %     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    %
    %     EEG = pop_autobsseog( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[0  8]});
    %     EEG = eeg_checkset( EEG );
    %     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
    %
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



% [path,name_noext,ext] = fileparts(input_file_name);
% [path2,name_noext2,ext] = fileparts(output_file_name);
%
%
% EEG     = pop_loadset(input_file_name);
% EEG     = pop_select(EEG,'channel',1:64);
% EEG     = pop_eegfiltnew( EEG,1, 45, [], 0, [], 0);
% EEG = pop_resample( EEG, 256);
% EEG = eeg_checkset( EEG );
%
% try
%     EEG = clean_rawdata(EEG, 5, [0.25 0.75], 3, 3, 3, 0.5);
%     EEG = eeg_checkset( EEG );
%     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
%
%     %     EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio', 50,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  30]});
%     EEG = pop_autobssemg( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'emg_psd', {'ratio',20,'fs', EEG.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  10]});
%     EEG = eeg_checkset( EEG );
%     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
% %
% %     EEG = pop_autobsseog( EEG, [], [], 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[2  8]});
% %     EEG = eeg_checkset( EEG );
% %     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
%
% %     OUTEEG = pop_reref(OUTEEG, [], 'keepref', 'on');
% %     EEG = eeg_checkset( EEG );
%
% %     EEG = pop_saveset( EEG, 'filename',name_noext2,'filepath',path2);
%
% catch err
%
%     % This "catch" section executes in case of an error in the "try" section
%     err
%     err.message
%     err.stack(1)
% end
% end


