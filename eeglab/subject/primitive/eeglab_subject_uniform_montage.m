function EEG = eeglab_subject_uniform_montage(input_file_name, output_path, montage_list, template_file)

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
    missing_ch = unique(missing_ch);
    tch2add = length(missing_ch);
    ss      = size(EEG.data,1);
    
    ch2add  = zeros(size(EEG.data(1:tch2add,:,:)));
    
    n0      = EEG.nbchan;
    
    for nch2add = 1:tch2add
        nn                 = n0+nch2add;
        EEG.data(nn,:,:)   = ch2add(nch2add, :,:);
        
        if not(isempty(EEG.chanlocs))
            EEG.chanlocs(nn)            = EEG.chanlocs(1);
            EEG.chanlocs(nn).labels     = missing_ch{nch2add};
            EEG                         = pop_chanedit( EEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
            EEG                         = eeg_checkset( EEG );
            EEG                         = pop_interp(EEG,nn, 'spherical');
            EEG                         = eeg_checkset( EEG );
        end;
    end
    EEG = pop_chanedit( EEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
    EEG = eeg_checkset( EEG );
    
    
    all_template_locs   = readlocs(template_file);
    all_template_labels = {all_template_locs.labels};
    
    merged_labels       = {EEG.chanlocs.labels};
    sel_from_template   = ismember(all_template_labels, merged_labels);
    
    template_locs   = all_template_locs(sel_from_template);
    template_labels = all_template_labels(sel_from_template);
    
    
    [c, ia, ib]     =intersect(template_labels, merged_labels);
    
    EEG.data        = EEG.data(ib,:,:);
    EEG.chanlocs    = template_locs;
    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[name_noext,'_merged'],'filepath',output_path);
end


