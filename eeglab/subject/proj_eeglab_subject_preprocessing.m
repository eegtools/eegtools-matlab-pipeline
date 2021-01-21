%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
%
% function to preprocess already imported and filtered data
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% EVENT FILTERING
% SPECIFIC FILTERING
%
%%
function EEG = proj_eeglab_subject_preprocessing(project, varargin)


list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);
% -------------------------------------------------------------------------------------------------------------------------------------


acquisition_system    = project.import.acquisition_system;
montage_list          = project.preproc.montage_list;
montage_names         = project.preproc.montage_names;
        

select_montage         = ismember(montage_names,acquisition_system);
ch_montage             = montage_list{select_montage};


    
    
eog_channels_list           = project.eegdata.eog_channels_list;
emg_channels_list           = project.eegdata.emg_channels_list;

for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    EEG                     = pop_loadset(input_file_name);
    
    dataset_ch_lab = {EEG.chanlocs.labels};
    dataset_eeg_ch_lab = intersect(dataset_ch_lab,ch_montage);
    nch_eeg_dataset = length(dataset_eeg_ch_lab);
%     dataset_eeg_ch_list = 1:length(nch_eeg_dataset);
    
    %===============================================================================================
    % CHANNELS TRANSFORMATION
    %===============================================================================================
    num_ch2transform = length(project.import.ch2transform);
    
    missing_ch = project.eegdata.nch_eeg - nch_eeg_dataset;
    
    
    
    if num_ch2transform
        
        initial_ch_num      = EEG.nbchan;
        num_mono            = 0;
        num_poly            = 0;
        num_disc            = 0;
        num_new_ch          = 0;
        new_label           = {};
        new_data            = [];
        ch2discard          = [];
        chpos2copy          = [];   % used to store from which channel get the position information
        for nb=1:num_ch2transform
            
          
            
            transf = project.import.ch2transform(nb);
            transf.ch1 = transf.ch1 - missing_ch;
            transf.ch2 = transf.ch2 - missing_ch;
            
            if ~isempty(transf.new_label)
                ... new ch
                    num_new_ch  = num_new_ch + 1;
                new_label   = [new_label transf.new_label];
                
                if isempty(transf.ch2)
                    ... monopolar
                        ch2discard              = [ch2discard transf.ch1];
                    chpos2copy              = [chpos2copy transf.ch1];
                    new_data(num_new_ch, :) = EEG.data(transf.ch1,:);
                    num_mono                = num_mono + 1;
                else
                    ... bipolar
                        ch2discard              = [ch2discard transf.ch1 transf.ch2];
                    chpos2copy              = [chpos2copy transf.ch1];
                    new_data(num_new_ch, :) = EEG.data(transf.ch1,:)-EEG.data(transf.ch2,:);
                    num_poly                = num_poly + 1;
                end
            else
                ... ch 2 discard
                    ch2discard      = [ch2discard transf.ch1];
                num_disc        = num_disc + 1;
            end
        end
        
        for nb=1:num_new_ch
            EEG.data((EEG.nbchan+nb), :)        = new_data(nb, :);
            EEG.chanlocs(EEG.nbchan+nb)         = EEG.chanlocs(chpos2copy(nb));
            EEG.chanlocs(EEG.nbchan+nb).labels  = new_label{nb};
        end
        
        for nd=1:length(ch2discard)
            EEG.chanlocs(ch2discard(nd)).labels = ['temp_' num2str(nd)];
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
    
    if(strcmp(project.preproc.interpolate_channels, 'on'))
        
        for ns=1:length(project.subjects.data)
            if (strcmp(project.subjects.data(ns).name, subj_name))
                ch2interpolate=project.subjects.data(ns).bad_ch;
            end
        end
        
        if not(isempty(ch2interpolate))
            tchanint        = length(ch2interpolate);
            channels_list   = {EEG.chanlocs.labels};
            for nchint=1:tchanint
                match_int(nchint, :) = strcmpi(channels_list,ch2interpolate(nchint));
            end
            intvec          = find(sum(match_int,1) > 0);
            interpolation   = intvec;
            disp(['interpolating channels ' ch2interpolate])
            EEG             = pop_interp(EEG, [interpolation], 'spherical');
            EEG             = eeg_checkset( EEG );
        end
    end
    
    
    
    
    
    %===============================================================================================
    % EVENTS FILTERING
    %===============================================================================================
    if not(isempty(project.import.valid_marker))
        if not(strcmp(project.import.valid_marker,'all'))
            allowed_events  = ismember({EEG.event.type}, project.import.valid_marker);
            EEG.event       = EEG.event(allowed_events);
            EEG             = eeg_checkset( EEG );
        end
    end
    
    %===============================================================================================
    % SPECIFIC FILTERING
    %===============================================================================================
    if project.preproc.do_global_notch
        EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandstop');
        EEG = eeg_checkset( EEG );
    end
    
     if project.preproc.do_global_bandpass
        EEG = proj_eeglab_subject_filter(EEG, project, 'global', 'bandpass');
        EEG = eeg_checkset( EEG );
    end
    
    if project.preproc.do_specific_bandpass
        % filter for EEG channels
        EEG = proj_eeglab_subject_filter(EEG, project,'eeg','bandpass');
        EEG = eeg_checkset( EEG );
        
        % filter for EOG channels
        if not(isempty(eog_channels_list))
            EEG = proj_eeglab_subject_filter(EEG, project,'eog','bandpass');
            EEG = eeg_checkset( EEG );
        end
        
        % filter for EMG channels
        if not(isempty(emg_channels_list))
            EEG = proj_eeglab_subject_filter(EEG, project,'emg','bandpass');
            EEG = eeg_checkset( EEG );
        end
    end
    %===============================================================================================
    % check if SUBSAMPLING
    %===============================================================================================
    if (EEG.srate > project.eegdata.fs)
        disp(['subsampling to ' num2str(project.eegdata.fs)]);
         EEG = pop_resample( EEG, project.eegdata.fs);
%         if strcmp(project.preproc.filter_algorithm, project.preproc.filter_algorithm)
%                        
% 
%         else
%             EEG = pop_resample( EEG, project.eegdata.fs);
%         end
        EEG = eeg_checkset( EEG );
    end
    
    %===============================================================================================
    % SAVE
    %===============================================================================================
    output_file_name        = proj_eeglab_subject_get_filename(project, subj_name, 'output_preprocessing');
    [path,name_noext,ext]   = fileparts(output_file_name);
    EEG                     = pop_saveset( EEG, 'filename', name_noext, 'filepath', path);
    %===============================================================================================
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 01/03/2016
% removed the re-referencing from the standard preprocessing step. user
% must do it after first ICA. after re-referencing ICA should be re-done
%
% 04/06/2015
% corrected polygraphic channels transformation, you can now name new channels as previous ones
%
% 30/12/2014
% restored event filtering routine, if project.import.valid_marker is not empty
%
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
%
% 23/9/2014
% completely redesigned the channel transformation section. a proper structure has been introduced, allowing user to select discarded channels
% and how to treat bipolar and monopolar channels
%
% 16/9/2014 (invalid change, modified by following modification)
% referencing exclude channels according to items in project.eegdata.no_eeg_channels_list
% added channels manipulation info
% poly data are not appended, but substitute data in the proper channel
% remove channels at the end of the ch tail. for those setup using recording several polygraphic but using only part of them (e.g as with biosemi)

% 30/1/2014
% first version of the new project structure