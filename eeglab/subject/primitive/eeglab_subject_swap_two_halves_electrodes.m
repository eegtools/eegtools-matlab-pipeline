%% function EEG = eeglab_subject_swap_two_halves_electrodes(input_file_name, output_file_name)    
% read input .set file, swap the first half of the electrodes (eg. 1-32) witht the second half (33-64).
% fight pippo setup ! when the first electrodes cable is plugged into the second plug
%%
function EEG = eeglab_subject_swap_two_halves_electrodes(input_file_name, output_file_name)    

    [input_path, input_name_noext, input_ext]       = fileparts(input_file_name);
    [output_path, output_name_noext, output_ext]    = fileparts(output_file_name);
    
    EEG         = pop_loadset(input_file_name);
    pnts        = EEG.pnts;
    tempvector  = zeros(1, pnts);
    half_ch     = EEG.nbchan/2;
    for ch=1:half_ch
        other_ch                = ch + half_ch;
        % swap data vectors
        tempvector              = EEG.data(ch,:);
        EEG.data(ch,:)          = EEG.data(other_ch,:);
        EEG.data(other_ch,:)    = tempvector(:);
    end
    disp(['=========>> de-pippoing subject ' input_name_noext]);
    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',output_name_noext, 'filepath', output_path);
end