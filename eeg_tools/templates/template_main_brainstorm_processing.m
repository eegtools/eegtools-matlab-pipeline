clear project

%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system

os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    project.paths.projects_data_root    = '/media/geo/repository/groups/uvip_lab/claudio/';
    project.paths.projects_scripts_root = '/home/campus/behaviourPlatform';
    project.paths.plugins_root          = '/home/campus/work/work-matlab/matlab_toolbox';
    project.paths.framework_root        = '/home/campus/behaviourPlatform/CommonScript/eeg';
    project.paths.script.project       = '/home/campus/behaviourPlatform/VisuoHaptic/claudio/acop';%'/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_sordi/processing/matlab/';
    project.paths.project              = '';
else
    project.paths.projects_data_root    = 'C:\projects\';
    project.paths.projects_scripts_root = 'C:\behaviourPlatform';
    project.paths.plugins_root          = 'C:\work\work-matlab\matlab_toolbox';
    project.paths.framework_root        = 'C:\behaviourPlatform\CommonScript\eeg';
    project.paths.script.project        = 'C:\behaviourPlatform\VisuoHaptic\claudio\acop\';
    
end

%% ==================================================================================
%  PROJECT DATA
%==================================================================================
project.research_group      = '';
project.research_subgroup   = '';
project.name                = 'acop';                 ... must correspond to 'project.paths.local_projects_data' subfolder name
    % project.conf_file_name      = 'project_structure_echolocation_click';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
project.conf_file_name      = 'project_structure_acop2';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
    




project                                                 = project_init(project);

%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%=======================================================================================================================================================================
............................
    ............................
    ............................
    ............................
    
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
% to get project_init
% project.paths.script.eeg_tools_project = fullfile(project.paths.global_scripts_root, 'eeg_tools', 'project', ''); addpath(project.paths.script.eeg_tools_project);
project                                = project_init(project, false);             ... project structure
    %% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================


list_select_subjects    = project.subjects.list();% [1:2,5:7,9:20][1:2,5:7,9:20] [1:2,5:7,9:20]project.subjects.list([1,6]);

% if a list is not set, or is empty, all subjects in the project are
% processed
if not(exist('list_select_subjects','var'))
    list_select_subjects    = project.subjects.list;
else
    if isempty(list_select_subjects)
        list_select_subjects    = project.subjects.list;
    end
end
project.subjects.numsubj                         = length(list_select_subjects);
project.subjects.curr_list      = list_select_subjects;








operations = {...
    'do_subject_sensors_import_averaging', ...
    ...'do_subject_aggregate_conditions', ...
    'do_subject_tf_conditions',...
    'do_subject_tf_group_bands_conditions',...
    'do_subject_tf_baseline_correction_conditions',
    'do_subject_noise_estimation',...'do_subject_noise_estimation_factors',... 
    'do_data_estimation',...'do_data_estimation_factors',...
    'do_subject_recover_bem',...'do_subject_bem',...
    ...'do_subject_backup_bem',... 
    'do_subject_check_bem' ,...
    'do_subject_sources',...
    ...'do_subject_sources_factors',...
    'do_subject_tw_reduction',...
    ...'do_subject_tw_reduction_factors',...
    'do_subject_uncontrained2flat',...
    ...'subject_uncontrained2flat_factors',...
    ...'do_group_average_cond_results_group',...
    ...'do_group_average_cond_results_factors_group' ,...
    ...'do_group_stats_cond_group_ttest_new',...
    ...'pippo'...
    'do_group_average_cond_scalp_results_group'
    };


for nop =  length(operations)%1:length(operations):
    
    operation = operations{nop}
    project                                                 = project_init(project);
    
    result = startProcess_brainstorm(project, ...
        operation,  ...
        'list_select_subjects', list_select_subjects);
    
end




% clear project
% %% ==================================================================================
% % LOCAL PATHS
% %==================================================================================
% % to be edited according to calling PC local file system
% os = system_dependent('getos');
% if  strncmp(os,'Linux',2)
%     
%     project.paths.projects_data_root    = '/data/projects';
%     project.paths.projects_scripts_root = '/data/behavior_lab_svn/behaviourPlatform';
%     project.paths.plugins_root          = '/data/matlab_toolbox';
%     project.paths.global_scripts_root   = '/data/matlab_toolbox/eegtools-matlab-pipeline';
% else
%     project.paths.projects_data_root    = 'C:\Users\Pippo\Documents\EEG_projects';
%     project.paths.svn_scripts_root      = 'C:\Users\Pippo\Documents\MATLAB\svn_beviour_lab\EEG_Tools';
%     project.paths.plugins_root          = 'C:\Users\Pippo\Documents\MATLAB\toolboxes';
% end
% 
% %% ==================================================================================
% %  PROJECT DATA 
% %==================================================================================
% project.research_group      = 'PAP';
% project.research_subgroup   = '';
% project.name                = 'mirror_mirror';                 ... must correspond to 'project.paths.local_projects_data' subfolder name
% project.conf_file_name      = 'project_structure_brainstorm';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
% 
% %% =====================================================================================================================================================================
% %  DESIGN SPECIFICATION
% %=======================================================================================================================================================================
% ............................
% ............................
% ............................
% ............................
%     
% %% =====================================================================================================================================================================
% %  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
% %=====================================================================================================================================================================
% % to get project_init
% project.paths.script.eeg_tools_project = fullfile(project.paths.global_scripts_root, 'eeg_tools', 'project', ''); addpath(project.paths.script.eeg_tools_project); 
% project                                = project_init(project, false);             ... project structure
% %% =====================================================================================================================================================================
% %  OVERRIDE
% %=====================================================================================================================================================================
% 
% % project.subjects.list                 = {'alexander_active-Deci'}; ...,
% % 'alexander_active-Deci','andre_active-Deci','carol_active-Deci','claudia_active-Deci','dorine_active-Deci','elbert_active-Deci', 'elena_active-Deci','Hadassa_active-Deci','julian_active-Deci','laura_active-Deci','maggie_active-Deci','reinoud_active-Deci', 'stein_active-Deci','sunjin_active-Deci','susan_active-Deci','tomas_active-Deci','Viviane_active-Deci';
% % project.subjects.numsubj                = length(project.subjects.list);
% 
% 
% list_select_subjects                    = [];
% 
% % if a list is not set, or is empty, all subjects in the project are
% % processed 
% if not(exist('list_select_subjects','var'))
%     list_select_subjects    = project.subjects.list;
% else
%     if isempty(list_select_subjects) 
%         list_select_subjects    = project.subjects.list;
%     end
% end
% project.subjects.numsubj                         = length(list_select_subjects);
% project.subjects.curr_list      = list_select_subjects;
% 
% 
% 
% 
% 
% 
% project.brainstorm.sensors.name_maineffects    = {'M' 'MM' '300' '100'};
% project.brainstorm.sensors.tot_num_contrasts   = project.epoching.numcond + length(project.brainstorm.sensors.name_maineffects);
% 
% % used for ERP differences and paired ttest
% project.brainstorm.sensors.pairwise_comparisons = { ...
%                                                     {'M-100', 'MM-100'}; ...
%                                                     {'M-300', 'MM-300'}; ...
%                                                    };
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % SOURCES PARAMS 
% 
% % average FILE used to calculate sources
% % project.brainstorm.average_file_name    = 'data_average_tw_average_5_samples';        % after temporal reduction 1 sample for each component (in case of one component, it adds a fake second TP)
% % project.brainstorm.average_file_name    = 'data_average_tw_average_all_samples';      % after temporal reduction (2*window_samples_halfwidth + 1) * ncomponents 
% project.brainstorm.average_file_name    = 'data_average';  
% 
% 
% % unconstrained to flat sources
% project.brainstorm.sources.flatting_method = 1; % 0: no flatting, 1: norm, 2: PCA
% 
% 
% project.brainstorm.sources.params =  {
% %                           {'norm', 'dspm',     'orient',    'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
% %                           {'norm', 'dspm',     'orient',    'fixed', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                             {'norm', 'wmne',     'orient',  'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                             {'norm', 'wmne',     'orient',  'fixed', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', 0, 'loose_value', 0}; ...
% %                             {'norm', 'sloreta',  'orient',  'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
% %                             {'norm', 'dspm',  'orient',  'free', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
% %                             {'norm', 'mne',     'orient',    'free',  'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,  'tag', 'vol', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
% %                             {'norm', 'mne',     'orient',    'fixed', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,  'tag', 'vol', 'project.operations.do_norm', 0, 'loose_value', 0}; ...
% %                             {'norm', 'sloreta',     'orient',    'free',  'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,  'tag', 'vol', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
% %                              {'norm', 'dspm',     'orient',    'free', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,  'tag', 'vol', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                         };
% 
% project.brainstorm.analysis_times                       = {{'t-4', '-0.4000, -0.3040', 'mean'; 't-3', '-0.3000, -0.2040', 'mean'; 't-2', '-0.2000, -0.1040', 'mean'; 't-1', '-0.1000, -0.0040', 'mean'; 't1', '0.0000, 0.0960', 'mean'; 't2', '0.1000, 0.1960', 'mean'; 't3', '0.2000, 0.2960', 'mean'; 't4', '0.3000, 0.3960', 'mean'; 't5', '0.4000, 0.4960', 'mean'; 't6', '0.5000, 0.5960', 'mean'; 't7', '0.6000, 0.6960', 'mean'; 't8', '0.7000, 0.7960', 'mean'; 't9', '0.8000, 0.8960', 'mean'; 't10', '0.9000, 0.9960', 'mean'}};
% 
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % TF PARAMS 
% zscore_overwriting                      = 1; ... 1: calculate zscore and overwrite tf result file, 0: calculate zscore and create new tf result zscore file, -1: do not calculate zscore
% 
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % SOURCES DIMENSIONALITY REDUCTION & EXPORT
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf' }; 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | zscore'}; 
% project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | zscore | norm'}; 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | norm'}; 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | norm | Uniform400'}; 
% % project.brainstorm.postprocess.tag_list            = {'dspm | free | surf'}; 
% 
% 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | tw_all_5_samples'}; 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | tw_all_5_samples | atlas251'}; 
% % project.brainstorm.postprocess.tag_list            = {'wmne | free | surf | norm | tw_all_5_samples', 'wmne | free | surf | norm | tw_average_5_samples'};
% 
% 
% % ------- time reduction (file containing the components' peaks...it's an ERP CURVE TW with individual peak calculation) 
% % ONLY suited for that design (usually the #1) reporting all the plain conditions. not structured factors
% project.brainstorm.postprocess.tw_latencies_file = '/data/projects/PAP/moving_scrambled_walker/results/OCICA_250_raw/erp_N2_central_reduced_100000perm_wnd20ms_380-480_eye_regr_sign_all_full_005_fdr/all-erp_curve_individual_align-16-Dec-2015-17-39-21/erp_curve_roi-stat.mat';
% 
% 
% % ------- spatial reduction
% % indicates the Atlas name as defined in the GUI
% project.brainstorm.sources.downsample_atlasname                    = 'Uniform400';
% 
% 
% % ------- extract scouts
% project.brainstorm.postprocess.group_time_windows(1) = struct('name', 'N200', 'min', 0.2113, 'max', 0.2113);
% 
% project.brainstorm.postprocess.scout_list={
%                                   {'r_ACC'};    
%                                   {'r_MCC'};    
%                                   {'r_IFG'}
% };
% project.brainstorm.postprocess.scouts_names     = {'r_ACC','r_MCC','r_IFG'};
% project.brainstorm.postprocess.numscouts        = length(project.brainstorm.postprocess.scout_list);
% 
% % ------- zscore normalization and ttest vs baseline
% project.brainstorm.baselineanalysis.comparisons = project.epoching.condition_names;     
% project.brainstorm.baselineanalysis.baseline    = [project.epoching.bc_st.s, project.epoching.bc_end.s];
% project.brainstorm.baselineanalysis.poststim    = [0.05, 0.8];
% 
% project.brainstorm.stats.num_permutations       = 1000;
% project.brainstorm.stats.correction             = 'fdr';
% project.brainstorm.stats.pvalue                 = 0.05;
% 
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % GROUP ANALYSIS
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% project.brainstorm.groupanalysis.comment        = [];
% 
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_fixed_surf';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_fixed_surf';
% % project.brainstorm.groupanalysis.analysis_type = 'dspm_free_surf';
% project.brainstorm.groupanalysis.analysis_type = 'dspm_free_surf_norm';
% % project.brainstorm.groupanalysis.analysis_type = 'dspm_fixed_surf';
% % project.brainstorm.groupanalysis.analysis_type  = 'wmne_free_surf_zscore';
% % project.brainstorm.groupanalysis.analysis_type  = 'wmne_free_surf_zscore_norm';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_tw_all_5_samples';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_Uniform400';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_Uniform250';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_tw_all_5_samples_Uniform250';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_zscore_tw_average_5_samples_Uniform250';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_zscore_tw_all_5_samples';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_zscore';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_tw_average_5_samples_Uniform250';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_tw_all_5_samples_Uniform250';
% % project.brainstorm.groupanalysis.analysis_type = 'wmne_free_surf_norm_tw_all_5_samples';
% 
% project.brainstorm.groupanalysis.data_type      = 'results_';  % "matrix_" for scouts analysis
% project.brainstorm.groupanalysis.interval       = [0.050 0.6]; 
% project.brainstorm.groupanalysis.abs_type       = 0;  ... never normalize during z-transform
% project.brainstorm.groupanalysis.pairwise_comparisons = { ...
%                                                             {'M-100', 'MM-100'}; ...
%                                                             {'M-300', 'MM-300'}; ...
%                                                         };
% 
% 
% 
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % RESULTS POSTPROCESS & EXPORT
% %--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % substring used to get and process specific results file
% project.brainstorm.results_processing.process_result_string='twalker_cwalker_wmne_free_surf_tw_average_5_samples_Uniform250';     
% 
% 
% 
% factors_names       = {'translation', 'shape'};
% project.brainstorm.export.scout_name_inputfile   = ['wmne_free_surf_zscore_norm_scouts' '_' strjoin2(project.brainstorm.postprocess.scouts_names, '_')]; 
% project.brainstorm.export.scout_name_outputfile   = ['wmne_free_surf_zscore_norm_scouts' '_' strjoin2(project.brainstorm.postprocess.scouts_names, '_') '_' strjoin2({project.brainstorm.postprocess.group_time_windows.name}, '_')]; 
% 
%    
% %% ==================================================================================================================================================================
% % OPERATIONS LIST
% %% ==================================================================================================================================================================
% 
% % SENSORS DATA PROCESSING
% project.operations.do_sensors_import_averaging                         = 0;
% project.operations.do_sensors_averaging_main_effects                   = 0;
% project.operations.do_sensors_conditions_differences                   = 0;
% project.operations.do_sensors_group_erp_averaging                      = 0;        
% project.operations.do_sensors_common_noise_estimation                  = 0;   ... possible if baseline correction was calculated using all the conditions pre-stimulus
% project.operations.do_sensors_common_data_estimation                   = 0;
% 
% % VOLUME CONDUCTOR & SOURCE SPACE
% project.operations.do_bem                                              = 0;
% project.operations.do_check_bem                                        = 0;
% 
% % SOURCES CALCULATION
% project.operations.do_sources_calculation                              = 0;
% project.operations.do_sources_tf_calculation                           = 0;
% project.operations.do_sources_scouts_tf_calculation                    = 0;
% 
% % SOURCES DIMENSIONALITY REDUCTION & EXPORT
% project.operations.do_sources_unconstrained2flat                       = 0;
% project.operations.do_sources_time_reduction                           = 0;
% project.operations.do_sources_spatial_reduction                        = 0;
% project.operations.do_sources_extract_scouts                           = 0;
% project.operations.do_sources_extract_scouts_oneperiod_values          = 0;
% project.operations.do_sources_export2spm8                              = 0;
% project.operations.do_sources_export2spm8_subjects_peaks               = 0;
% project.operations.do_results_zscore                                   = 0;
%      
% % GROUP ANALYSIS
% project.operations.do_process_stats_paired_2samples_ttest_sources      = 0;
% project.operations.do_process_stats_baseline_ttest_sources             = 0;            
% 
% project.operations.do_process_stats_paired_2samples_ttest_ft_sources   = 0;
% project.operations.do_group_analysis_tf                                = 0;
% project.operations.do_group_analysis_scouts_tf                         = 0;
% 
% % RESULTS POSTPROCESS & EXPORT
% project.operations.do_group_results_averaging                          = 0;        
% project.operations.do_process_stats_sources                            = 0;            
% project.operations.do_process_stats_scouts_tf                          = 0;            
% project.operations.do_export_scouts_to_file                            = 0;
% project.operations.do_export_scouts_multiple_oneperiod_to_file         = 0;
% project.operations.do_export_scouts_to_file_factors                    = 0;
% project.operations.do_export_scouts_multiple_oneperiod_to_file_factors = 0;
% 
% 
% % OLD
% project.operations.do_process_stats_paired_2samples_ttest_old_sources  = 0;
% 
% 
% %% =====================================================================================================================================================================
% %=====================================================================================================================================================================
% %  S T A R T 
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% strpath = path;
% if ~strfind(strpath, project.paths.shadowing_functions)
%     addpath(project.paths.shadowing_functions);      % eeglab shadows the fminsearch function => I add its path in case I previously removed it
% end
% 
% 
% try
% 
%     do_operations_brainstorm
%     
% catch err
%    keyboard 
%    err
%    
% end
% 
% 
