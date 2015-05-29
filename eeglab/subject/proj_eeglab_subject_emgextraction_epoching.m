% read input .set file, do a global baseline correction and then do epoching 
% varargin = output path, use the 3rd parameter or, if empty, use input filename path

function EEG = proj_eeglab_subject_emgextraction_epoching(project, varargin)    


    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'preprocessing';
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

    epo_st                  = project.epoching.emg_epo_st.s;
    epo_end                 = project.epoching.emg_epo_end.s;
    bc_st_point             = project.epoching.emg_bc_st_point;
    bc_end_point            = project.epoching.emg_bc_end_point;
    mrkcode_cond            = project.epoching.mrkcode_cond;
    eeg_input_path          = project.paths.input_epochs;

    for subj=1:numsubj
        
        subj_name               = list_select_subjects{subj};
        input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        [path,name_noext,ext]   = fileparts(input_file_name);

        EEG                     = pop_loadset(input_file_name);

        num_emg_channels        = length(project.eegdata.emg_channels_list);

        % keep only EMG channels and save a new file set
        EEG = pop_select(EEG, 'channel', project.eegdata.emg_channels_list);
        EEG = eeg_checkset(EEG);    
        EEG = pop_saveset(EEG, 'filename', [name_noext project.import.emg_output_postfix '.set'], 'filepath', project.paths.emg_epochs);    

        EEG = pop_epoch(EEG, [mrkcode_cond{1:length(mrkcode_cond)}], [epo_st         epo_end], 'newname', 'all_conditions', 'epochinfo', 'yes');

        % baseline correction trail BY trial independently (EEG.data is [ch,tp,epochs])
        baseline_values = zeros(EEG.trials);
        for ch=1:size(EEG.data,1)   
            baseline_values=mean(squeeze(EEG.data(ch, bc_st_point:bc_end_point, :))); ...  [1xEEG.trials]
            for ep=1:EEG.trials
                for tp=1:EEG.pnts
                    EEG.data(ch,tp,ep) = EEG.data(ch,tp,ep) - baseline_values(ep);
                end
            end
        end

        % save a file set with all the epochs after baseline correction
        EEG = eeg_checkset(EEG);    
        EEG = pop_saveset(EEG, 'filename', [name_noext project.import.emg_output_postfix '_epochs_bc' '.set'], 'filepath', project.paths.emg_epochs);    

        emg_structure.cond_names    = project.epoching.condition_names;
        emg_structure.channels_name = project.eegdata.emg_channels_list_labels;

        % perform processing and then save condition datasets
        for cond=1:length(mrkcode_cond)
            EEG2 = pop_epoch(EEG, mrkcode_cond{cond}, [epo_st         epo_end], 'newname', emg_structure.cond_names{cond}, 'epochinfo', 'yes');

            for emgch=1:num_emg_channels
                % muscle, cond, epoch, timepoint (squeeze & transpose)
                emg_structure.channels_data{emgch}{cond}=squeeze(EEG2.data(emgch,:,:)).';
            end

        end

        save(fullfile(project.paths.emg_epochs_mat, [name_noext project.import.emg_output_postfix '.mat']), 'emg_structure');
    end
end