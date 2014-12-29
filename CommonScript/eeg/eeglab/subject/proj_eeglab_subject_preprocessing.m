%% EEG = proj_eeglab_subject_preprocessing(project, subj_name)
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% RE-REFERENCE
% SPECIFIC FILTERING
%
%%
function EEG = proj_eeglab_subject_preprocessing(project, varargin)

list_select_subjects  = project.subjects.list;


options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
    end
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    
    
    % function to preprocess already imported and filtered data
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name,'preprocessing');...fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
        [path,name_noext,ext]   = fileparts(input_file_name);
    EEG                     = pop_loadset(input_file_name);
    
    eeg_channels_list       = project.eegdata.eeg_channels_list;
    eog_channels_list       = project.eegdata.eog_channels_list;
    emg_channels_list       = project.eegdata.emg_channels_list;
    
    ff1_eeg=project.preproc.ff1_eeg; ff2_eeg=project.preproc.ff2_eeg;
    ff1_eog=project.preproc.ff1_eog; ff2_eog=project.preproc.ff2_eog;
    ff1_emg=project.preproc.ff1_emg; ff2_emg=project.preproc.ff2_emg;
    
    output_suffix           = project.import.output_suffix;
    output_path             = project.paths.input_epochs;
    
    %===============================================================================================
    % check if SUBSAMPLING
    %===============================================================================================
    if (EEG.srate > project.eegdata.fs)
        disp(['subsampling to ' num2str(project.eegdata.fs)]);
        EEG = pop_resample( EEG, project.eegdata.fs);
        EEG = eeg_checkset( EEG );
    end
    
    %===============================================================================================
    % CHANNELS TRANSFORMATION
    %===============================================================================================
    num_ch2transform = length(project.import.ch2transform);
    
    if num_ch2transform
        
        initial_ch_num      = EEG.nbchan;
        num_mono            = 0;
        num_poly            = 0;
        num_disc            = 0;
        num_new_ch          = 0;
        new_label           = {};
        new_data            = [];
        ch2discard          = [];
        
        for nb=1:num_ch2transform
            transf = project.import.ch2transform(nb);
            if ~isempty(transf.new_label)
                ... new ch
                    num_new_ch = num_new_ch + 1;
                new_label   = [new_label transf.new_label];
                if isempty(transf.ch2)
                    ... monopolar
                        ch2discard              = [ch2discard transf.ch1];
                    new_data(num_new_ch,:)  = EEG.data(transf.ch1,:);
                    num_mono                = num_mono + 1;
                else
                    ... bipolar
                        ch2discard              = [ch2discard transf.ch1 transf.ch2];
                    new_data(num_new_ch,:)  = EEG.data(transf.ch1,:)-EEG.data(transf.ch2,:);
                    num_poly                = num_poly + 1;
                end
            else
                ... ch 2 discard
                    ch2discard = [ch2discard transf.ch1];
                num_disc        = num_disc + 1;
            end
        end
        
        for nb=1:num_new_ch
            EEG.data((EEG.nbchan+nb),:) = new_data(nb, :);
            if ~isempty(EEG.chanlocs)
                EEG.chanlocs(EEG.nbchan+nb).labels  = new_label{nb};
            end;
        end
        EEG             = eeg_checkset(EEG);
        EEG             = pop_select(EEG, 'nochannel', ch2discard); ... remove the polych and all the remaining ch up to list end
            EEG             = eeg_checkset(EEG);
        
        num_ch          = initial_ch_num - length(ch2discard) + num_new_ch;
        num_discarded   = length(ch2discard) - num_new_ch;
        
        if num_ch ~= project.eegdata.nch
            disp(['Error in channels number manipulation: expected ' num2str(project.eegdata.nch) ', calculated ' num_ch]);
        else
            disp('--------------------------------------------------------------------------');
            disp(['starting number of electrodes:' num2str(initial_ch_num)]);
            disp([num2str(num_disc) ' channels will be discarded']);
            disp([num2str(num_poly*2) ' polygraphic channels will be trasformed in ' num2str(num_poly) ' poly channels and appended at the end']);
            disp([num2str(num_mono) ' monographic channels were appended at the end']);
            disp(['final number of channels will be:' num2str(project.eegdata.nch)]);
            disp('--------------------------------------------------------------------------');
        end
    end
    
    %===============================================================================================
    % INTERPOLATION
    %===============================================================================================
    for ns=1:length(project.subjects.data)
        if (strcmp(project.subjects.data(ns).name, subj_name))
            ch2interpolate=project.subjects.data(ns).bad_ch;
        end
    end
    
    if ~isempty(ch2interpolate)
        tchanint        = length(ch2interpolate);
        channels_list   = {EEG.chanlocs.labels};
        for nchint=1:tchanint;
            match_int(nchint,:) = strcmpi(channels_list,ch2interpolate(nchint));
        end
        intvec          = find(sum(match_int,1)>0);
        interpolation   = intvec;
        disp(['interpolating channels ' ch2interpolate])
        EEG             = pop_interp(EEG, [interpolation], 'spherical');
        EEG             = eeg_checkset( EEG );
    end
    %
    %     %===============================================================================================
    %     % RE-REFERENCE
    %     %===============================================================================================
    %     ... if left blank => do nothing, if project.import.reference_channels{1} = 'CAR' => apply CAR, else ...
    if ~isempty(project.import.reference_channels)
        reference=[];
        if ~strcmp(project.import.reference_channels{1}, 'CAR')
            
            tchanref        = length(project.import.reference_channels);
            channels_list   = {EEG.chanlocs.labels};
            for nchref=1:tchanref;
                ll                  = length(project.import.reference_channels{nchref});
                match_ref(nchref,:) = strncmp(channels_list, project.import.reference_channels(nchref), ll);
            end
            refvec      = find(sum(match_ref,1)>0);
            reference   = refvec;
        end
        
        if isempty(project.eegdata.no_eeg_channels_list)
            EEG = pop_reref(EEG, [reference], 'keepref', 'on');
        else
            EEG = pop_reref(EEG, [reference], 'exclude', project.eegdata.no_eeg_channels_list, 'keepref', 'on');
        end
        
        EEG = eeg_checkset( EEG );
    end
    
    %===============================================================================================
    % SPECIFIC FILTERING
    %===============================================================================================
    
    % filter for EEG channels
    EEG = proj_eeglab_subject_filter(EEG, project,'eeg','bandpass');
    EEG = eeg_checkset( EEG );
    
    % filter for EOG channels
    if ~isempty(eog_channels_list)
        EEG = proj_eeglab_subject_filter(EEG, project,'eog','bandpass');
        EEG = eeg_checkset( EEG );
    end
    % filter for EMG channels
    if ~isempty(emg_channels_list)
        EEG = proj_eeglab_subject_filter(EEG, project,'emg','bandpass');
        EEG = eeg_checkset( EEG );
    end
    
    
    
    
    
    %===============================================================================================
    % SAVE
    %===============================================================================================
    EEG = pop_saveset( EEG, 'filename', name_noext,'filepath',project.paths.input_epochs);
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 23/9/2014
% completely redesigned the channel transformation section. a proper structure has been introduced, allowing user to select discarded channels
% and how to treat bipolar and monopolar channels
% 16/9/2014
% referencing exclude channels according to items in project.eegdata.no_eeg_channels_list
% added channels manipulation info
% poly data are not appended, but substitute data in the proper channel
% remove channels at the end of the ch tail. for those setup using recording several polygraphic but using only part of them (e.g as with biosemi)
% 30/1/2014
% first version of the new project structure