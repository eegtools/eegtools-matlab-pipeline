function EEG = eeglab_subject_uniform_montage(input_file_name, montage_list,output_path)

[path,name_noext,ext] = fileparts(input_file_name);


tm = length(montage_list);

EEG = pop_loadset(input_file_name);

% list of channels in the current dataset
ch_set = {EEG.chanlocs.labels};

missing_ch = [];

% for each montage to be merged
for nm=1:tm
    ch_montage             = montage_list {nm};
    ind_missing            = not(ismember(ch_montage,ch_set));
    if sum(ind_missing)
        missing_ch_montage = ch_montage(ind_missing);
        missing_ch         = [missing_ch, missing_ch_montage];
    end
end

if not(isempty(missing_ch))
    tch2add = length(missing_ch);
    ss      = size(EEG.data,1);
    
    ch2add  = zeros(size(EEG.data(1:tch2add,:,:)));
    
    for nch2add = 1:tch2add        
        nn                 = EEG.nbchan+nch2add;
        EEG.data(nn,:,:)   = ch2add(nch2add, :);
        
        if not(isempty(EEG.chanlocs))
                EEG.chanlocs(nn).labels  = missing_ch{nb};
                EEG                      = pop_interp(EEG,nn, 'spherical');
                EEG                      = eeg_checkset( EEG ); 
        end;         
    end
    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[name_noext,'_merged'],'filepath',output_path);
end


 