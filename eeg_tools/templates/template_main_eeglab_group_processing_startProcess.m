clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    
%     project.paths.projects_data_root    = '/media/dados/EEG';
%     project.paths.svn_scripts_root      = '/media/data/svn/rbcs_behaviourPlatform';
%     project.paths.plugins_root          = '/media/data/matlab/common/extensions';
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

eval(project.conf_file_name);                                               ... project structure
project                                 = define_project_paths(project);    ... global and project paths definition. If 2nd param is 0, is faster, as it does not call eeglab
init_operations_flags
%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================

...stat_analysis_suffix='erp_MPP_100000perm_wnd20ms_fdr';
stat_analysis_suffix='ERP_N2c_curve_plots_allconditions-';


if ~ isempty(stat_analysis_suffix)
    stat_analysis_suffix=[stat_analysis_suffix,'-',datestr(now,30)];
end

design_num_vec          = [1];
list_select_subjects    = [];
sel_cell_string         = [];

%% =====================================================================================================================================================================
%  OPERATIONS LIST 
%=====================================================================================================================================================================

% stat_analysis_suffix                            = 'ERP_allch';
stat_analysis_suffix                            = 'ERP_plot';
project.stats.erp.pvalue                        = 0.005;
project.stats.erp.num_permutations              = 2;            
project.stats.eeglab.erp.correction             = 'fdr';



project.postprocess.erp.roi_list  = {{'Pz'};{'CPz'};{'Cz'};{'FCz'};{'Fz'};{'AFz'};{'P8'};{'PO8'};{'CP6'};{'PO4'};{'PO8'};{'TP8'};};
project.postprocess.erp.roi_names = {'Pz','CPz','Cz','FCz','Fz','AFz','P8','PO8','CP6','PO4','PO8','TP8'};



% res = startProcess(project, 'study_compute_channels_measures', stat_analysis_suffix, design_num_vec, list_select_subjects);
 res = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);
% startProcess(project, 'study_plot_allch_erp_time');













































% % create a study from preprocessed datasets
% project.operations.do_study                                                         = 0;
% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % create one merged epochs file for each condition and group in the study
% project.operations.do_group_averages                                                = 0;
% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % create a set of experimental designs within a created study
% project.operations.do_design                                                        = 0;
% 
% %---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% % precompute channels measures for a set of designs: these measures are used in group statistics. 
% % Mandatory if some dataset of the study is changed.
% project.operations.do_study_compute_channels_measures                               = 0;
% %---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% 
% 
% %% ******************************************************************************************************************************************
% %==========================================================================================================================================
% % E R P  analysis
% %==========================================================================================================================================
% %******************************************************************************************************************************************
% % 13 modalities based on 2 functions
% %
% % proj_eeglab_study_plot_roi_erp_curve
% % proj_eeglab_study_plot_erp_topo_tw
% %==========================================================================================================================================
% 
% 
% 
% %% -------------------------------------------------------------------------------------------
% % ERP CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors 
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_erp_curve
% 
% % CONTINUOUS: analyzes and plots of erp curve for all time points
% project.operations.do_study_plot_roi_erp_curve_continous                            = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% % perform (and save) statistics based on grand-mean of subjects within group time windows
% project.operations.do_study_plot_roi_erp_curve_tw_group_noalign                     = 0;
% 
% % perform (and save) statistics based on grand-mean of subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_erp_curve_tw_group_align                       = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows
% project.operations.do_study_plot_roi_erp_curve_tw_individual_noalign                = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_erp_curve_tw_individual_align                  = 0;
% 
% 
% %% -------------------------------------------------------------------------------------------
% % FOR ERP, eog CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_erpeog_curve
% 
% % CONTINUOUS: analyzes and plots of erp curve for all time points
% project.operations.do_study_plot_roi_erpeog_curve_continous                            = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpeog_curve_tw_group_noalign                     = 0;
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpeog_curve_tw_group_align                       = 0;
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpeog_curve_tw_individual_noalign                = 0;
%     
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpeog_curve_tw_individual_align                  = 0;
% 
% 
% 
% %% -------------------------------------------------------------------------------------------
% % FOR ERP, emg CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_erpemg_curve
% 
% % CONTINUOUS: analyzes and plots of erp curve for all time points
% project.operations.do_study_plot_roi_erpemg_curve_continous                            = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpemg_curve_tw_group_noalign                     = 0;
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpemg_curve_tw_group_align                       = 0;
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpemg_curve_tw_individual_noalign                = 0;
%     
% 
% % analyzes and plots of erp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erpemg_curve_tw_individual_align                  = 0;
% 
% 
% %% -------------------------------------------------------------------------------------------
% % ERP_TOPO_TW
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_erp_topo_tw
% % settings:
% % project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar' 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% %--------------------------------------------------------
% % STANDARD, topographical erp modality
% %--------------------------------------------------------
% 
% % analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
% project.operations.do_study_plot_erp_topo_tw_group_noalign                          = 0; 
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_erp_topo_tw_group_align                            = 0; 
% 
% % perform (and save) additional statistics based on individual subjects within time windows
% project.operations.do_study_plot_erp_topo_tw_individual_noalign                     = 0;
% 
% % perform (and save) additional statistics based on individual subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_erp_topo_tw_individual_align                       = 0;
% 
% %--------------------------------------------------------
% % COMPACT, topographical erp modality
% %--------------------------------------------------------
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows
% project.operations.do_study_plot_erp_topo_compact_tw_group_noalign                  = 0; 
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_erp_topo_compact_tw_group_align                    = 0; 
% 
% % perform (and save) additional statistics based on individual subjects within time windows
% project.operations.do_study_plot_erp_topo_compact_tw_individual_noalign             = 0;
% 
% % perform (and save) additional statistics based on individual subjects within time windows, 
% % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_erp_topo_compact_tw_individual_align               = 0;
% 
% 
% 
% project.operations.do_eeglab_study_export_erp_r                                     = 0;
% 
% %% ******************************************************************************************************************************************
% %==========================================================================================================================================
% % E R S P  analysis (Time-frequency domain)
% %==========================================================================================================================================
% %******************************************************************************************************************************************
% % 23 modalities based on 3 main functions:
% % 
% % proj_eeglab_study_plot_roi_ersp_tf
% % proj_eeglab_study_plot_roi_ersp_curve_fb
% % proj_eeglab_study_plot_ersp_topo_tw_fb
% %==========================================================================================================================================
% 
% 
% 
% 
% %%-------------------------------------------------------------------------------------------
% % ERSP_TF, standard ersp time frequency: evaluate and represent standard EEGLab statistics on the time-frequency distribution of ERSP  
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_ersp_tf
% % perform (and save) statistics based the whole ERSP, time-frequency distribution (possibly decimated in the frequency and/or in the time domain)
% 
% % continuous
% project.operations.do_study_plot_roi_ersp_tf_continuous                             = 0;
% 
% % decimate_times 
% project.operations.do_study_plot_roi_ersp_tf_decimate_times                         = 0;
% 
% % decimate_freqs 
% project.operations.do_study_plot_roi_ersp_tf_decimate_freqs                         = 0;
% 
% % decimate_times_freqs
% project.operations.do_study_plot_roi_ersp_tf_decimate_times_freqs                   = 0;
% 
% % time-frequency distribution freely binned in the frequency and/or in the time domain
% project.operations.do_study_plot_roi_ersp_tf_tw_fb                                  = 0;
% 
% 
% %% ------------------------------------------------------------------------------------------
% % ERSP_CURVE, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_ersp_curve_fb
% 
% %--------------------------------------------------------
% % STANDARD
% %--------------------------------------------------------
% 
% % continuous
% project.operations.do_study_plot_roi_ersp_curve_continous_standard                  = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based on time windows
% 
% % grand-mean of subjects within group time windows
% project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_standard           = 0;
% 
% % grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_ersp_curve_tw_group_align_standard             = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows
% project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_standard      = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_standard        = 0;
% 
% 
% %--------------------------------------------------------
% % COMPACT
% %--------------------------------------------------------
% 
% % continuous
% project.operations.do_study_plot_roi_ersp_curve_continous_compact                   = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based on time windows
% 
% % perform (and save) statistics based on grand-mean of subjects within time windows
% project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_compact            = 0;
% 
% % perform (and save) statistics based on grand-mean of subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_ersp_curve_tw_group_align_compact              = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows
% project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_compact       = 0;
% 
% % perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_compact         = 0;
% 
% 
% 
% 
% %% -------------------------------------------------------------------------------------------
% % FOR ersp, eog CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_erspeog_curve
% 
% % CONTINUOUS: analyzes and plots of ersp curve for all time points
% project.operations.do_study_plot_roi_erspeog_curve_continous                            = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspeog_curve_tw_group_noalign                     = 0;
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspeog_curve_tw_group_align                       = 0;
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspeog_curve_tw_individual_noalign                = 0;
%     
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspeog_curve_tw_individual_align                  = 0;
% 
% 
% 
% %% -------------------------------------------------------------------------------------------
% % FOR ersp, emg CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_roi_erspemg_curve
% 
% % CONTINUOUS: analyzes and plots of ersp curve for all time points
% project.operations.do_study_plot_roi_erspemg_curve_continous                            = 0;
% 
% % TIMEWINDOW: perform (and save) statistics based time windows
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspemg_curve_tw_group_noalign                     = 0;
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspemg_curve_tw_group_align                       = 0;
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspemg_curve_tw_individual_noalign                = 0;
%     
% 
% % analyzes and plots of ersp curve for time windows of the selected design
% project.operations.do_study_plot_roi_erspemg_curve_tw_individual_align                  = 0;
% 
% 
% 
% %% ------------------------------------------------------------------------------------------
% % ERSP_TOPO_TW_FB, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
% %--------------------------------------------------------------------------------------------
% % master-function:                                      proj_eeglab_study_plot_ersp_topo_tw_fb
% 
% 
% 
% %--------------------------------------------------------
% % STANDARD, topographical ersp modality
% %--------------------------------------------------------
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows
% project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign                      = 0; 
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_ersp_topo_tw_fb_group_align                        = 0; 
% 
% % perform (and save) additional statistics based on individual subjects within time windows
% project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign                 = 0;
% 
% % perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_ersp_topo_tw_fb_individual_align                   = 0;
% 
% 
% %--------------------------------------------------------
% % COMPACT, topographical ersp modality
% %--------------------------------------------------------
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows
% project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign_compact              = 0; 
% 
% % perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_ersp_topo_tw_fb_group_align_compact                = 0; 
% 
% % perform (and save) additional statistics based on individual subjects within time windows
% project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign_compact         = 0;
% 
% % perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
% project.operations.do_study_plot_ersp_topo_tw_fb_individual_align_compact           = 0;
% 
% 
% 
% 
% project.operations.do_eeglab_study_export_ersp_tf_r                                 = 0;
% 
% %% =====================================================================================================================================================================
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% %  S T A R T    P R O C E S S I N G  
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% %=====================================================================================================================================================================
% 
% try
%   
%     
%     do_operations
% 
% 
% 
%    
% catch err
%     % This "catch" section executes in case of an error in the "try" section
%     err
%     err.message
%     err.stack(1)    
% end
