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
function EEG = proj_eeglab_subject_sleep_staging_hume(project, varargin)


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


% acquisition_system    = project.import.acquisition_system;
% montage_list          = project.preproc.montage_list;
% montage_names         = project.preproc.montage_names;
eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
reset_stageData         = project.sleep.hume.reset_stageData;

% select_montage         = ismember(montage_names,acquisition_system);
% ch_montage             = montage_list{select_montage};
%
%
%
%
% eog_channels_list           = project.eegdata.eog_channels_list;
% emg_channels_list           = project.eegdata.emg_channels_list;

for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    % hume
    project.paths.plugin.hume              = fullfile(project.paths.plugins_root, 'hume', 'Hume');
    if exist(project.paths.plugin.hume, 'dir')
    
        montagedir_project = fullfile(project.paths.project, 'hume');
        if not(exist(montagedir_project))
            mkdir(montagedir_project);
        end
        montagedir_hume = fullfile(project.paths.plugin.hume, 'montages');
        [montage_path_hume,montage_path_project] = create_montage_hume(input_file_name,montagedir_hume,montagedir_project);
        
        stagedatadir = fullfile(project.paths.project, 'hume');
        if not(exist(stagedatadir))
            mkdir(stagedatadir);
        end
        [stagedata_path] = create_stagedata_hume(input_file_name,stagedatadir,reset_stageData, project);
        
        cd(project.paths.plugin.hume);
        %         hume_pipeline(project,subj_name,input_file_name);
        
        
        %% copy forked functions into hume directory (to recover, remove and git pull)
        sleepScoring_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['sleepScoring.m']);
        sleepScoringdir_hume = fullfile(project.paths.plugin.hume, 'gui');
        copyfile( sleepScoring_m, sleepScoringdir_hume);
        
        
        spectrogram_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['spectrogramRpt_SingleCh.m']);
        spectrogramdir_hume = fullfile(project.paths.plugin.hume, 'gui');
        copyfile( spectrogram_m, spectrogramdir_hume);
        
        
        
        hume
        disp(input_file_name);
        disp(stagedata_path);
        disp(montage_path_hume);
        disp(montage_path_project);

        pathdatadir = fullfile(project.paths.project, 'hume');
        file_percorsi = fullfile(pathdatadir,[subj_name,'_paths.txt']);
        fid = fopen(file_percorsi,'w+');
        fprintf(fid,'%s\n',input_file_name);
        fprintf(fid,'%s\n',stagedata_path);
        fprintf(fid,'%s\n',montage_path_hume);
        fprintf(fid,'%s\n',montage_path_project);
        fprintf(fid,'%s\n',sleepScoring_m);
        fprintf(fid,'%s\n',spectrogram_m);


        fclose(fid)

        edit(file_percorsi); 
        %         pause
        disp('finito');
    end
    
    
    %     try
    %         EEG                     = pop_loadset(input_file_name);
    %     catch
    %         [fpath,fname,fext] = fileparts(input_file_name);
    %         EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    %     end
    % %     dataset_ch_lab = {EEG.chanlocs.labels};
    % %     dataset_eeg_ch_lab = intersect(dataset_ch_lab,ch_montage);
    % %     nch_eeg_dataset = length(dataset_eeg_ch_lab);
    %
    %     %% gestione canali
    %     old_chan = {EEG.chanlocs.labels};
    %     chan_match = project.import.complete_montage;
    %     rr = length(chan_match);
    %     cc = length(old_chan);
    %
    %     mat_ch = false(rr,cc);
    %
    %
    %     for nr = 1:rr
    %         selch = strfind_index(old_chan, chan_match{nr});
    %         if not(isempty(selch))
    %             mat_ch(nr, selch) = true;
    %         end
    %     end
    %
    %
    %     new_chan = old_chan;
    %
    %     for nc = 1:cc
    %         cr = mat_ch(:,nc);
    %         tcr0 = sum(cr);
    %
    %         if tcr0
    %             strxx = unique(chan_match(cr));
    %             tcrx = length(strxx);
    %
    %             if tcrx > 1
    %                 ll = cellfun(@length,strxx);
    %                 ss = ll == max(ll);
    %                 zz = ll(ss);
    %                 strxx = strxx(zz);
    %             end
    %             new_chan(nc) = strxx;
    %             %
    %
    %         end
    %
    %     end
    %
    %     for nc = 1:cc
    %         EEG.chanlocs(nc).labels = new_chan{nc};
    %     end
    %
    %
    %
    %     missing_ch = find(not(ismember(chan_match, {EEG.chanlocs.labels})));
    %
    %
    %     if not(isempty(missing_ch))
    %
    %         num_new_ch = length(missing_ch);
    %         ch2add = chan_match(missing_ch);
    %
    %         for nb=1:num_new_ch
    %             EEG.data((EEG.nbchan+nb), :)        = 0;
    %             EEG.chanlocs(EEG.nbchan+nb)         = EEG.chanlocs(1);
    %             EEG.chanlocs(EEG.nbchan+nb).labels  = ch2add{nb};
    %         end
    %
    %         EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    %         EEG = eeg_checkset( EEG );
    %
    %         eegch = {EEG.chanlocs.labels};
    %
    %         [eegch_sorted ind_eegch] = sort(eegch);
    %         %                     [allch_sorted ind_allch] = sort(allch);
    %         %
    %         %                     [ind_eegch_sorted ind_ind_eegch] = sort(ind_eegch);
    %         %                     [ind_allch_sorted ind_ind_allch] = sort(ind_allch);
    %
    %
    %         %                     mapping = ind_eegch(ind_ind_allch);
    %         %                     EEG.data = EEG.data(mapping,:);
    %         %                     EEG.chanlocs = EEG.chanlocs(mapping,:);
    %
    %         EEG.data = EEG.data(ind_eegch,:);
    %         EEG.chanlocs = EEG.chanlocs(ind_eegch,:);
    %
    %         EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    %         EEG = eeg_checkset( EEG );
    %
    %         interpolation = find(ismember({EEG.chanlocs.labels},ch2add));
    %         EEG             = pop_interp(EEG, [interpolation], 'spherical');
    %         EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    %         EEG = eeg_checkset( EEG );
    %
    %         ch2discard = find(not(ismember({EEG.chanlocs.labels}, chan_match)));
    %         EEG             = pop_select(EEG, 'nochannel', ch2discard);
    %         EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    %         EEG = eeg_checkset( EEG );
    %
    %     end
    %     EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    %     EEG = eeg_checkset( EEG );
    %
    %     %===============================================================================================
    %     % SAVE
    %     %===============================================================================================
    %     output_file_name        = proj_eeglab_subject_get_filename(project, subj_name, 'output_preprocessing');
    %     [path,name_noext,ext]   = fileparts(output_file_name);
    %     EEG                     = pop_saveset( EEG, 'filename', name_noext, 'filepath', path);
    %     %===============================================================================================
end
end
