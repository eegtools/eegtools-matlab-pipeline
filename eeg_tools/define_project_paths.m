%% AIMS:
% define and create global and project PATHS 

% REQUIREMENTS:
% it requires the following variables:
% GLOBALS
... project.paths.svn_scripts_root              ... e.g. '/data/behavior_lab_svn/behaviourPlatform'
... project.paths.common_scripts                ... e.g. '/data/behavior_lab_svn/behaviourPlatform/CommonScript'
... project.paths.eeg_tools                     ... e.g. '/data/behavior_lab_svn/behaviourPlatform/CommonScript/eeg_tools'
... project.paths.projects_data_root            ... e.g. '/data/projects'
... project.paths.plugins_root                  ... e.g. '/data/matlab_toolbox'

% PROJECT RELATED
... project.research_group
... project.research_subgroup    
... project.name
... project.conf_file_name
... project.analysis_name

... project.eegdata.eeglab_channels_file_name
... project.clustering.channels_file_name   
... project.brainstorm.channels_file_name


function project = define_project_paths(project, start_toolbox)

    if nargin < 2
        start_toolbox = 1;
    end

    %% ================================================================================================================
    % ==== GLOBAL ===================================================================================================
    %================================================================================================================
    strpath = path;

    %%  ------ PLUGIN PATH

    % eeglab
    project.paths.eeglab                        = fullfile(project.paths.plugins_root, 'eeglab','');
    if isempty(strfind(strpath, project.paths.eeglab))
        addpath(project.paths.eeglab);
    end
    
    if start_toolbox
        eeglab
    end
    
    project.paths.shadowing_functions           = fullfile(project.paths.eeglab, 'functions', 'octavefunc', 'optim','');

    % brainstorm
    project.paths.brainstorm                    = fullfile(project.paths.plugins_root, 'brainstorm3', '');
    if isempty(strfind(strpath, project.paths.brainstorm)) && exist(project.paths.brainstorm, 'dir')
        addpath(project.paths.brainstorm);      
        brainstorm setpath;
    end

    % SPM
    project.paths.spm                           = fullfile(project.paths.plugins_root, 'spm8', '');
    if isempty(strfind(strpath, project.paths.spm)) && exist(project.paths.spm, 'dir')
        addpath(genpath2(project.paths.spm));      
    end



    %%  ------ COMMON SCRIPTS PATH

    % global script path
    addpath(genpath2(fullfile(project.paths.eeg_tools, 'utilities', '')));

    addpath(genpath2(fullfile(project.paths.common_scripts, 'brainstorm_new', '')));
    addpath(genpath2(fullfile(project.paths.common_scripts, 'eeglab','')));

    addpath(genpath2(fullfile(project.paths.common_scripts, 'spm', '')));
    addpath(genpath2(fullfile(project.paths.common_scripts, 'R', '')));

    project.paths.global_spm_templates          = fullfile(project.paths.common_scripts, 'spm','templates', '');
    project.clustering.channels_file_path       = fullfile(project.paths.eeg_tools, project.clustering.channels_file_name);
    project.eegdata.eeglab_channels_file_path   = fullfile(project.paths.eeg_tools, project.eegdata.eeglab_channels_file_name);



    %%  ------ PROJECT PATHS 

    % project path
    project.paths.project                       = fullfile(project.paths.projects_data_root, project.research_group, project.research_subgroup, project.name, '');

    % original data path
    project.paths.original_data                 = fullfile(project.paths.project,'original_data', project.import.original_data_folder, '');
    if ~exist(project.paths.original_data, 'dir')
        mkdir(project.paths.original_data);
    end    

    % imported eeglab continuous files 
    project.paths.input_epochs                  = fullfile(project.paths.project,'epochs', project.import.output_folder, '');
    if ~exist(project.paths.input_epochs, 'dir')
        mkdir(project.paths.input_epochs);
    end

    % exported eeglab epochs files 
    project.paths.output_epochs                 = fullfile(project.paths.project,'epochs', project.analysis_name, '');
    if ~exist(project.paths.output_epochs, 'dir')
        mkdir(project.paths.output_epochs);
    end

    % results files path
    project.paths.results                       = fullfile(project.paths.project,'results',project.analysis_name, '');
    if ~exist(project.paths.results, 'dir')
        mkdir(project.paths.results);
    end

    %%
    if project.do_emg_analysis

        % exported eeglab EMG epochs files 
        project.paths.emg_epochs                = fullfile(project.paths.project,'epochs_emg',project.analysis_name, '');
        if ~exist(project.paths.emg_epochs, 'dir')
            mkdir(project.paths.emg_epochs);
        end

        % EMG MAT files 
        project.paths.emg_epochs_mat            = fullfile(project.paths.emg_epochs,'mat', '');
        if ~exist(project.paths.emg_epochs_mat, 'dir')
            mkdir(project.paths.emg_epochs_mat);
        end    
    end


    %%
    if project.do_cluster_analysis
        % exported cluster erp projection on the scalp be processed in Brainstorm
        project.paths.cluster_projection_erp    = fullfile(project.paths.project,'cluster_projection_erp',project.analysis_name, '');
        if ~exist(project.paths.cluster_projection_erp, 'dir')
            mkdir(project.paths.cluster_projection_erp);
        end
    end


    %%
    if project.do_source_analysis

        % batches files path
        project.paths.batches                   = fullfile(project.paths.scripts,'batches', '');
        if ~exist(project.paths.batches, 'dir')
            mkdir(project.paths.batches);
        end

        % brainstorm database
        project.paths.brainstorm_db             = fullfile(project.paths.project, project.brainstorm.db_name, '');

        % brainstorm database data folder for files renaming
        project.paths.brainstorm_data           = fullfile(project.paths.brainstorm_db,'data', '');

        % brainstorm project channels file
        project.brainstorm.channels_file_path   = fullfile(project.paths.project, project.brainstorm.channels_file_name);

        % exported sources results files path
        project.paths.spmsources                = fullfile(project.paths.project,'spm_sources', '');
        if ~exist(project.paths.spmsources, 'dir')
            mkdir(project.paths.spmsources);
        end

        % spm stats files path
        project.paths.spmstats                  = fullfile(project.paths.spmsources,'stats', '');
        if ~exist(project.paths.spmstats, 'dir')
            mkdir(project.paths.spmstats);
        end    

    end

    %% ------------- OT

    % exported time frequency representations
    % project.paths.tf                            = fullfile(project.paths.project,'timefrequency',project.analysis_name, '');
    % if ~exist(project.paths.tf, 'dir')
    %     mkdir(project.paths.tf);
    % end

    % exported erp to be processed in R
    % project.paths.erp=fullfile(project.paths.project,'erp',project.analysis_name, '');
    % if ~exist(project.paths.erp, 'dir')
    %     mkdir(project.paths.erp);
    % end
end