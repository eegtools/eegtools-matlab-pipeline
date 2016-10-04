clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    
    project.paths.projects_data_root    = '/media/dados/EEG';
    project.paths.svn_scripts_root      = '/media/data/svn/rbcs_behaviourPlatform';
    project.paths.plugins_root          = '/media/data/matlab/common/extensions';
%     project.paths.projects_data_root    = '/data/projects';
%     project.paths.svn_scripts_root      = '/data/behavior_lab_svn/behaviourPlatform';
%     project.paths.plugins_root          = '/data/matlab_toolbox';
else
    project.paths.projects_data_root    = 'C:\Users\Pippo\Documents\EEG_projects';
    project.paths.svn_scripts_root      = 'C:\Users\Pippo\Documents\MATLAB\svn_beviour_lab\EEG_Tools';
    project.paths.plugins_root          = 'C:\Users\Pippo\Documents\MATLAB\toolboxes';
end

%% ==================================================================================
%  PROJECT DATA 
%==================================================================================
project.research_group      = 'MNI';
project.research_subgroup   = '';
project.name                = 'perception_action_musicians';                 ... must correspond to 'project.paths.local_projects_data' subfolder name
project.conf_file_name      = 'project_structure_brainstorm';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================


%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.script.common_scripts     = fullfile(project.paths.svn_scripts_root, 'CommonScript', '');                                                     addpath(project.paths.script.common_scripts);      ... to get genpath2
project.paths.script.eeg_tools          = fullfile(project.paths.script.common_scripts, 'eeg','eeg_tools', '');                                             addpath(project.paths.script.eeg_tools);           ... to get define_project_paths
project.paths.script.project            = fullfile(project.paths.svn_scripts_root, project.research_group, project.research_subgroup , project.name, '');   addpath(genpath2(project.paths.script.project));   ... in general u don't need to import the others' projects svn folders
project                                 = project_init(project);             ... project structure
%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================

% stat_analysis_suffix='erp_MPP_100000perm_wnd20ms_fdr';
% stat_analysis_suffix='ERP_N2c_curve_plots_allconditions-';
stat_analysis_suffix='ERP_N2_tw_align';


if ~ isempty(stat_analysis_suffix)
    stat_analysis_suffix=[stat_analysis_suffix,'-',datestr(now,30)];
end

design_num_vec          = [4]; ...[2,3];
list_select_subjects    = [];
sel_cell_string         = [];

%% =====================================================================================================================================================================
%  OPERATIONS LIST 
%=====================================================================================================================================================================

project.stats.eeglab.erp.correction                     = 'fdr';
project.stats.erp.pvalue                                = 0.05;
project.results_display.erp.compact_display_xlim        = [0 300];


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_temppar';
project                                                 = initProject(project); 
design_num_vec                                          = [1];
project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....

project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_tw_noalign_temppar';
project                                                 = initProject(project); 
design_num_vec                                          = [2,3,4];
project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N170','min',145, 'max',180, 'ref_roi', 'TP8');
project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);




% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_mesial';
project                                                 = initProject(project); 
design_num_vec                                          = [1];
project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....

project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_tw_align_mesial';
project                                                 = initProject(project); 
design_num_vec                                          = [2,3,4];
project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N200','min',175, 'max',225, 'ref_roi', 'FCz');
project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);




% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% ----------- E N D --------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------