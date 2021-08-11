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
function EEG = proj_eeglab_subject_mark_sleep_events(project, varargin)


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

%% copy forked functions into vised eeglab directory (to recover, remove and git pull)
ve_eegplot_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['ve_eegplot.m']);
ve_eegplot_dir = fullfile(project.paths.eeglab, 'plugins','Vised-Marks','vised','branch_func');
copyfile( ve_eegplot_m, ve_eegplot_dir);

if not(isfield(project.sleep,'channels_colors'))
    project.sleep.channels_colors = 'off';
end

for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    disp(input_file_name);
    if exist(input_file_name)
        try
            EEG                     = pop_loadset(input_file_name);
        catch
            [fpath,fname,fext] = fileparts(input_file_name);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
        end
    else
        disp('no such file!');
    end
    
    
    [tch, ttpts] = size(EEG.data);
    
    
    
    %     project.sleep.sleep_stages.markers = {'N1','N2','N3','REM','W'};
    % project.sleep.sleep_stages.colors = {[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1]};
    %
    % project.sleep.marks(1).label = 's';%spindle
    % project.sleep.marks(1).color = [1 0.5 0.5];
    %
    % project.sleep.marks(2).label = 'k';%k-complex
    % project.sleep.marks(2).color = [0.5 1 0.5];
    
    
    
    
    sleep_stages.markers = project.sleep.sleep_stages.markers;...{'N1','N2','N3','REM','W'};
        sleep_stages.colors =  project.sleep.sleep_stages.colors;...{[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1]};
        
    tot_ss = length(sleep_stages.markers); %total sleep stages
    
    
    
    if project.sleep.reset_marks
        if isfield( EEG,'marks')
            EEG=rmfield(EEG, 'marks');
        end
    end
    
    if not(isfield( EEG,'marks') && isfield( EEG.marks,'time_info'))
        % tolgo selezione da tutti i canali
        EEG.marks.chan_info.flags = zeros(tch,1);
        EEG.marks.chan_info.line_color = [0.7000 0.7000 0.7000];
        EEG.marks.chan_info.tag_color = [0.7000 0.7000 0.7000];
        EEG.marks.chan_info.order = -1;
        
        EEG.marks.chan_info.label = 'manual';
        EEG.marks.time_info(1).label = 'manual';
        EEG.marks.time_info(1).color = [0.5, 0.5, 0.5];
        EEG.marks.time_info(1).flags = zeros(1,ttpts);
        
        for nss = 1:tot_ss
            EEG.marks.time_info(nss+1).label = sleep_stages.markers{nss};
            EEG.marks.time_info(nss+1).color = sleep_stages.colors{nss};
            EEG.marks.time_info(nss+1).flags = zeros(1,ttpts);
        end
        
        tot_marks = length(project.sleep.marks);
        for nm = 1:tot_marks
            EEG.marks.time_info(tot_ss + nm + 1).label = project.sleep.marks(nm).label;
            EEG.marks.time_info(tot_ss + nm + 1).color = project.sleep.marks(nm).color;
            EEG.marks.time_info(tot_ss + nm + 1).flags = zeros(1,ttpts);
            EEG.marks.time_info(tot_ss + nm + 1).description =  project.sleep.marks(nm).description;
            
        end
        
        
    end
    
    eeglab_channels_file    = project.eegdata.eeglab_channels_file_path;
    allch = {EEG.chanlocs.labels};
    tot_ch = length(allch);
    for nch = 1:tot_ch
        current_ch = allch{nch};
        if sum(ismember('EEG',current_ch ))
            current_ch_clean = current_ch(5:end-3);
            EEG.chanlocs(nch).labels = current_ch_clean;
        end
    end
    EEG=pop_chanedit(EEG, 'lookup',eeglab_channels_file);
    
    EEG = eeg_checkset( EEG );
    
% str = 'vised_config.marks_col_alpha = 0.7;';
% evalin('base',str);

vised_config_file = fullfile(project.paths.framework_root,'eeg_tools','utilities',['vised_config.cfg']);

str = ['vised_config=text2struct_ve(','''',vised_config_file,'''',');'];
evalin('base',str);

    EEG = pop_vised(EEG,'pop_gui','off',...
        'data_type','EEG',...
        'winrej_marks_labels',{'manual'},...
        'marks_y_loc',project.sleep.vised.marks_y_loc,'inter_mark_int',0.015,'inter_tag_int',0.01,...
        'marks_col_int',0.1,'marks_col_alpha',0.2,...
        'command','EEG=ve_update(EEG);EEG.saved = ''no'';',...
        'butlabel','Update EEG structure',...
        'winlength',30,...
        'color',project.sleep.channels_colors,...'on',...
        'selectcommand',...
        {...
        've_eegplot(''defdowncom'',gcbf);';...
        've_eegplot(''defmotioncom'',gcbf);';...
        've_eegplot(''defupcom'', gcbf);'...
        },...
        'altselectcommand',...
        {...
        've_edit(''quick_chanflag'',''manual'');';...
        've_eegplot(''defmotioncom'', gcbf);';''...
        },...
        'extselectcommand',...
        {...
        've_edit;';...
        've_eegplot(''defmotioncom'', gcbf);';''...
        },...
        'keyselectcommand',...
        project.sleep.vised.keyselectcommand...
        );
    EEG.sleep_stages = project.sleep.sleep_stages.markers;
    
    %     stagedatadir = fullfile(project.paths.project, 'hume');
    %     stagedatapath = fullfile(stagedatadir,[EEG.filename(1:end-4),'.mat']);
    %     disp(stagedatapath);
    %     if exist(stagedatapath)
    %         load(stagedatapath);
    %     else
    %         disp('no such file!');
    %     end
    %
    %     % cc commentare
    %     stageData.stageNames = {'wake'; 'stage1'; 'stage2'; 'stage3'; 'stage4'; 'rem'; 'mt'};
    %
    %
    %     [nr_eeg,nc_eeg] = size(EEG.data);
    %
    %     EEG.pts_win = EEG.srate * stageData.win;
    %
    %     tot_epo = length(stageData.stageTime);
    %     id_epo = 1:tot_epo;
    %
    %      stadtimes= 1:(tot_epo*EEG.pts_win-1);
    % %     stadtimes= stageData.onsets(1):(stageData.onsets(end)+EEG.pts_win-1);
    %
    %
    %
    %     stadmat = repmat(stageData.stages',EEG.pts_win,1);
    %     [nr_stad,nc_stad] = size(stadmat);
    %     nchstad = nr_eeg + 1;
    %     stadvec = reshape(stadmat,1,nr_stad*nc_stad);
    %
    %     if length(stadtimes)> nc_eeg
    %         sel_times = stadtimes <= nc_eeg;
    %         stadtimes = stadtimes (sel_times);
    %         stadvec = stadvec (sel_times);
    %     end
    %
    %
    %
    %     init_stad_ch = nan(1,nc_eeg);
    %     EEG.data = [EEG.data;init_stad_ch];
    %     EEG.data(nchstad,stadtimes) = stadvec;
    %     EEG.chanlocs(nchstad) = EEG.chanlocs(1);
    %     EEG.chanlocs(nchstad).labels = 'SH';%stagingHume
    %
    %     for ne =1:length(EEG.event)
    %         evelat = EEG.event(ne).latency;
    %         evestad = stageData.stageNames(EEG.data(nchstad,evelat));
    %         EEG.event(ne).SleepStage = evestad;
    %     end
    
    EEG = eeg_checkset(EEG);
    
    %       global EEG
    %     evalin('base','EEG0 =EEG')
    
    %     eeglab redraw;
    EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
    
    EEG  = pop_loadset('filename', EEG.filename, 'filepath', EEG.filepath);
    
    %     eeglab redraw
    disp('NOTE: REMEMBER TO UPDATE EEG STRUCTURE AND SAVE DATA!')
    
    str = ['EEG  = pop_loadset( ''filename'',''' EEG.filename,''',','''filepath''',',','''',EEG.filepath,'''',');'];
    disp(str)
    evalin('base',str);
    evalin('base','eeglab redraw');

    %     pause()
end


end

