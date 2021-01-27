function OUTEEG = eeglab_subject_uniform_montage(input_file_name, montage_list, template_file, varargin)

    [path,name_noext,ext] = fileparts(input_file_name);

    options_num=size(varargin,2);
    opt=1;
    backup_path = path;
    while options_num>0
        switch varargin{opt}
            case 'backup_path'
                opt=opt+1;
                backup_path = varargin{opt};     
        end
        opt=opt+1;
        options_num = options_num-2;
    end

    tm                  = length(montage_list);
    all_template_locs   = readlocs(template_file);
    all_template_labels = {all_template_locs.labels};

    OUTEEG              = [];
    EEG_poly            = [];

%     EEG                 = pop_loadset(input_file_name);
    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end

    % list of channels in the current dataset
    ch_set              = {EEG.chanlocs.labels};

    sel_eeg             = ismember(ch_set,all_template_labels);
    sel_poly            = not(sel_eeg);

    OUTEEG              = pop_select(EEG,'channel',find(sel_eeg));
    EEG_poly            = pop_select(EEG,'channel',find(sel_poly));

    missing_ch          = [];

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
        missing_ch  = unique(missing_ch);
        tch2add     = length(missing_ch);
        ss          = size(OUTEEG.data,1);

        ch2add      = zeros(size(OUTEEG.data(1:tch2add,:,:)));

        n0          = OUTEEG.nbchan;

        for nch2add = 1:tch2add
            nn                  = n0+nch2add;
            OUTEEG.data(nn,:,:) = ch2add(nch2add, :,:);

            if not(isempty(OUTEEG.chanlocs))
                OUTEEG.chanlocs(nn)            = OUTEEG.chanlocs(1);
                OUTEEG.chanlocs(nn).labels     = missing_ch{nch2add};
                OUTEEG                         = pop_chanedit( OUTEEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
                OUTEEG                         = eeg_checkset( OUTEEG );
                OUTEEG                         = pop_interp(OUTEEG,nn, 'spherical');
                OUTEEG                         = eeg_checkset( OUTEEG );
            end;
        end

        OUTEEG              = pop_chanedit( OUTEEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
        OUTEEG              = eeg_checkset( OUTEEG );
    end
    
    merged_labels       = {OUTEEG.chanlocs.labels};
    sel_from_template   = ismember(all_template_labels, merged_labels);

    template_locs       = all_template_locs(sel_from_template);
    template_labels     = all_template_labels(sel_from_template);

    [c, ia, ib]         = intersect(template_labels, merged_labels);

    OUTEEG.data         = OUTEEG.data(ib,:,:);
    OUTEEG.chanlocs     = template_locs;
    OUTEEG              = pop_chanedit( OUTEEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration

    if not(isempty(EEG_poly))    
        poly_ch = {EEG_poly.chanlocs.labels};
        tchpoly = length(poly_ch);
        ss      = size(OUTEEG.data,1);
        n0      = OUTEEG.nbchan;    
        for nchpoly = 1:tchpoly
            nn                    = n0+nchpoly;
            OUTEEG.data(nn,:,:)   = EEG_poly.data(nchpoly, :,:);

            if not(isempty(OUTEEG.chanlocs))
                OUTEEG.chanlocs(nn)            = EEG_poly.chanlocs(nchpoly);
                OUTEEG                         = pop_chanedit( OUTEEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
                OUTEEG                         = eeg_checkset( OUTEEG );
            end
        end
        OUTEEG  = pop_chanedit( OUTEEG, 'lookup',template_file);    ...  considering using a same file, suitable for whichever electrodes configuration
        OUTEEG  = eeg_checkset( OUTEEG );
    
        OUTEEG  = pop_saveset( OUTEEG, 'filename', name_noext, 'filepath', path);
          
        
    end

    EEG = pop_saveset( EEG, 'filename', [name_noext,'_unmerged'], 'filepath', backup_path);
end

