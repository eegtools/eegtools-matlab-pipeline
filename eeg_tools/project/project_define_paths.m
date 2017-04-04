%% AIMS:
% define and create global and project PATHS 
%
% REQUIREMENTS:
% it requires the following variables:
% GLOBALS
...*    project.paths.projects_data_root            ... e.g. '/data/projects'    they contain PAP, MNI, UVIP etc...
...*    project.paths.projects_scripts_root         ... e.g. '/data/projects'  or  /data/behavior_lab_svn/behaviourPlatform...they contain PAP, MNI, UVIP etc...
...*    project.paths.global_scripts_root           ... e.g. '/media/dados/EEG/eegtools/matlab-pipeline'
...*    project.paths.plugins_root                  ... e.g. '/data/matlab_toolbox' .. contains eeglab, brainstorm, fieldtrip, spm
...*    project.paths.script.eeg_tools_project      ... e.g. '/media/dados/EEG/eegtools/matlab-pipeline/eeg_tools/project'


...*    project.paths.script.eeg_tools              ... e.g. '/media/dados/EEG/eegtools/matlab-pipeline/eeg_tools'

% PROJECT RELATED
...*    project.research_group
...*    project.research_subgroup    
...*    project.name
...*    project.conf_file_name

...**   project.analysis_name

...**   project.eegdata.eeglab_channels_file_name
...**   project.clustering.channels_file_name   
...**   project.brainstorm.channels_file_name

% LEGENDA
...*  defined in main
...** defined in project structure

%% GLOBAL PATHS HERE DEFINED
...     project.paths.eeglab
...     project.paths.shadowing_functions
...     project.paths.brainstorm
...     project.paths.plugin.fieldtrip

%% PIPELINE PATHS HERE DEFINED
...     project.paths.script.pipeline_root
...     project.paths.script.eeg_tools
...     project.paths.script.utilities
...     project.paths.script.brainstorm
...     project.paths.script.eeglab
...     project.paths.script.fieldtrip
...     project.paths.script.spm

%% PROJECT PATHS HERE DEFINED
...     project.paths.script.project
...     project.paths.project
...     project.paths.original_data         :           (project.paths.project,'original_data', project.import.original_data_folder)
...     project.paths.output_import         :           (project.paths.project,'epochs', project.import.output_folder)
...     project.paths.output_preprocessing  :           (project.paths.project,'epochs', project.import.output_folder)
...     project.paths.input_epochs          :           (project.paths.project,'epochs', project.import.output_folder)
...     project.paths.output_epochs         :           (project.paths.project,'epochs', project.analysis_name)
...     project.paths.results               :           (project.paths.project,'results', project.analysis_name)
...     project.paths.emg_epochs            :           (project.paths.project,'epochs_emg', project.analysis_name)

%%
function project = project_define_paths(project, varargin)

    set(0, 'DefaulttextInterpreter', 'tex');
     
    if nargin < 2
        start_toolbox = 1;
    else
        start_toolbox = varargin{1};        
    end

    %% ================================================================================================================
    % ==== GLOBAL ===================================================================================================
    %================================================================================================================
    strpath = path;

    %%  ------ PIPELINE SCRIPTS PATH

    % global script path
    project.paths.script.eeg_tools          = fullfile(project.paths.global_scripts_root, 'eeg_tools');
    project.paths.script.utilities          = fullfile(project.paths.script.eeg_tools, 'utilities', '');   
    project.paths.script.brainstorm         = fullfile(project.paths.global_scripts_root,'brainstorm');
    project.paths.script.eeglab             = fullfile(project.paths.global_scripts_root,'eeglab');
    project.paths.script.fieldtrip          = fullfile(project.paths.global_scripts_root,'fieldtrip');
    project.paths.script.spm                = fullfile(project.paths.global_scripts_root,'spm');

    addpath(project.paths.global_scripts_root);   ... to get genpath2
    addpath(project.paths.script.eeg_tools);        
        
    addpath(genpath2(project.paths.script.utilities));
    addpath(genpath2(project.paths.script.brainstorm));
    addpath(genpath2(project.paths.script.eeglab));
    addpath(genpath2(project.paths.script.fieldtrip));
    addpath(genpath2(project.paths.script.spm));

    
    % project script path    
    project.paths.script.project            = fullfile(project.paths.projects_scripts_root, project.research_group, project.research_subgroup , project.name, '');   
    addpath(genpath2(project.paths.script.project));   ... in general u don't need to import the others' projects svn folders    
    
    % other files
    project.paths.templates.spm                 = fullfile(project.paths.script.spm,'templates');
    project.clustering.channels_file_path       = fullfile(project.paths.script.eeg_tools, 'resources', project.clustering.channels_file_name);
    project.eegdata.eeglab_channels_file_path   = fullfile(project.paths.script.eeg_tools, 'resources', project.eegdata.eeglab_channels_file_name);
    
    
    
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
%     project.paths.spm                           = fullfile(project.paths.plugins_root, 'spm8', '');
%     if isempty(strfind(strpath, project.paths.spm)) && exist(project.paths.spm, 'dir')
%         addpath(genpath2(project.paths.spm));      
%     end

    % fieldtrip
    project.paths.plugin.fieldtrip                     = fullfile(project.paths.plugins_root, 'fieldtrip', '');
    if isempty(strfind(strpath, project.paths.plugin.fieldtrip)) && exist(project.paths.plugin.fieldtrip, 'dir')
        addpath(genpath2(project.paths.plugin.fieldtrip));      
    end

    %%  ------ PROJECT PATHS 

    % project path
    project.paths.project                       = fullfile(project.paths.projects_data_root, project.research_group, project.research_subgroup, project.name, '');

    % original data path
    project.paths.original_data                 = fullfile(project.paths.project, 'original_data', project.import.original_data_folder, '');
    if ~exist(project.paths.original_data, 'dir')
        mkdir(project.paths.original_data);
    end    

    % output import
    project.paths.output_import                 = fullfile(project.paths.project, 'epochs', project.import.output_folder, '');
    if ~exist(project.paths.output_import, 'dir')
        mkdir(project.paths.output_import);
    end     
    
    % output pre-processing
    project.paths.output_preprocessing             = fullfile(project.paths.project, 'epochs', project.preproc.output_folder, '');
     if ~exist(project.paths.output_preprocessing, 'dir')
        mkdir(project.paths.output_preprocessing);
    end      
     
    % imported eeglab continuous files 
    project.paths.input_epochs                  = fullfile(project.paths.project, 'epochs', project.epoching.input_folder, '');
    if ~exist(project.paths.input_epochs, 'dir')
        mkdir(project.paths.input_epochs);
    end

    % exported eeglab epochs files 
    project.paths.output_epochs                 = fullfile(project.paths.project, 'epochs', project.analysis_name, '');
    if ~exist(project.paths.output_epochs, 'dir')
        mkdir(project.paths.output_epochs);
    end

    % results files path
    project.paths.results                       = fullfile(project.paths.project, 'results', project.analysis_name, '');
    if ~exist(project.paths.results, 'dir')
        mkdir(project.paths.results);
    end

    %%
    if project.operations.do_emg_analysis

        % exported eeglab EMG epochs files 
        project.paths.emg_epochs                = fullfile(project.paths.project, 'epochs_emg', project.analysis_name, '');
        if ~exist(project.paths.emg_epochs, 'dir')
            mkdir(project.paths.emg_epochs);
        end

        % EMG MAT files 
        project.paths.emg_epochs_mat            = fullfile(project.paths.emg_epochs, 'mat', '');
        if ~exist(project.paths.emg_epochs_mat, 'dir')
            mkdir(project.paths.emg_epochs_mat);
        end    
    end


    %%
    if project.operations.do_cluster_analysis
        % exported cluster erp projection on the scalp be processed in Brainstorm
        project.paths.cluster_projection_erp    = fullfile(project.paths.project,'cluster_projection_erp',project.analysis_name, '');
        if ~exist(project.paths.cluster_projection_erp, 'dir')
            mkdir(project.paths.cluster_projection_erp);
        end
    end


    %%
    if project.operations.do_source_analysis

        % batches files path
        project.paths.batches                   = fullfile(project.paths.project,'batches', '');
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

%     if project.do_fieldtrip_analysis
% 
%         % imported fieldtrip continuous files
%         project.paths.input_epochs                  = fullfile(project.paths.project,'fieldtrip','continuous', project.import.output_folder, '');
%         if ~exist(project.paths.input_epochs, 'dir')
%             mkdir(project.paths.input_epochs);
%         end
% 
%         % exported eeglab epochs files
%         project.paths.output_epochs                 = fullfile(project.paths.project,'fieldtrip','epochs', project.analysis_name, '');
%         if ~exist(project.paths.output_epochs, 'dir')
%             mkdir(project.paths.output_epochs);
%         end
% 
%         % results files path
%         project.paths.results                       = fullfile(project.paths.project,'results','fieldtrip',project.analysis_name, '');
%         if ~exist(project.paths.results, 'dir')
%             mkdir(project.paths.results);
%         end
% 
%     end

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
