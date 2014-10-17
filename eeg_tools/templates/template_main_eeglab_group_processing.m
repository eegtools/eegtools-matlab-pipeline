clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    
    project.paths.projects_data_root    = '/data/projects';
    project.paths.svn_scripts_root      = '/data/behavior_lab_svn/behaviourPlatform';
    project.paths.plugins_root          = '/data/matlab_toolbox';
else
    project.paths.projects_data_root    = 'C:\Users\Pippo\Documents\EEG_projects';
    project.paths.svn_scripts_root      = 'C:\Users\Pippo\Documents\MATLAB\svn_beviour_lab\EEG_Tools';
    project.paths.plugins_root          = 'C:\Users\Pippo\Documents\MATLAB\toolboxes';
end

%% ==================================================================================
%  PROJECT DATA 
%==================================================================================
project.research_group      = 'PAP';
project.research_subgroup   = 'laura';
project.name                = 'cp_action_observation';                 ... must correspond to 'project.paths.local_projects_data' subfolder name
project.conf_file_name      = 'project_structure_observation';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name

%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================
...
...
...
...
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.common_scripts    = fullfile(project.paths.svn_scripts_root, 'CommonScript', '');                                                     addpath(project.paths.common_scripts);
project.paths.eeg_tools         = fullfile(project.paths.common_scripts, 'eeg_tools', '');                                                          addpath(project.paths.eeg_tools);
project.paths.scripts           = fullfile(project.paths.svn_scripts_root, project.research_group, project.research_subgroup , project.name, '');   addpath(genpath2(project.paths.scripts));   ... in general u don't need to import the others' projects svn folders

eval(project.conf_file_name);       ... project
project                         = define_project_paths(project);      ... global and project paths definition. If 2nd param is 0, is faster, as it does not call eeglab

%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================

stat_analysis_suffix='aocs_ao_C4_subject_similar_presound-TF_tw_fb';
if ~ isempty(stat_analysis_suffix)
    stat_analysis_suffix=[stat_analysis_suffix,'-',datestr(now,30)];
end

design_num_vec = [8:12 2:7];
list_select_subjects    = {'CC_01_vittoria', 'CC_02_fabio', 'CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara', 'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'}; ...project.subjects.sublist;

%% =====================================================================================================================================================================
%  OPERATIONS LIST 
%=====================================================================================================================================================================
do_study=0;
do_design=0;
do_study_compute_channels_measures=0;

% PLOT STATISTICS
do_study_plot_roi_erp_curve_continous=0;
do_study_plot_roi_erp_curve_tw_group_noalign = 0;
do_study_plot_roi_erp_curve_tw_group_align = 0;
do_study_plot_roi_erp_curve_tw_individual_noalign = 0;
do_study_plot_roi_erp_curve_tw_individual_align = 0;
do_study_plot_erp_topo_tw=0;

do_study_plot_roi_ersp_tf=1;
do_study_plot_roi_ersp_curve_continous=0;
do_study_plot_roi_ersp_curve_tw_group_noalign = 0;
do_study_plot_roi_ersp_curve_tw_group_align = 0;
do_study_plot_roi_ersp_curve_tw_individual_noalign = 0;
do_study_plot_roi_ersp_curve_tw_individual_align = 0;
do_study_plot_ersp_topo_tw_fb=0;

do_eeglab_study_export_ersp_tf_r=0;

%% =====================================================================================================================================================================
%  S T A R T    P R O C E S S I N G  
%=====================================================================================================================================================================
try
    
   do_operations
   
   
catch err
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)    
end
