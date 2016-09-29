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
project.research_group      = 'MNI';
project.research_subgroup   = '';
project.name                = 'perception_action_musicians';                 
project.conf_file_name      = 'project_structure_brainstorm';         
project.analysis_file_name  = 'analysis_structure_brainstorm';         ... analysis_structure file name...initialize default analysis parameters
%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================
%  ................................
%  ................................
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.script.common_scripts     = fullfile(project.paths.svn_scripts_root, 'CommonScript', '');                                                     addpath(project.paths.script.common_scripts);      ... to get genpath2
project.paths.script.eeg_tools          = fullfile(project.paths.script.common_scripts, 'eeg','eeg_tools', '');                                             addpath(project.paths.script.eeg_tools);           ... to get define_project_paths
project.paths.script.project            = fullfile(project.paths.svn_scripts_root, project.research_group, project.research_subgroup , project.name, '');   addpath(genpath2(project.paths.script.project));   ... in general u don't need to import the others' projects svn folders

eval(project.conf_file_name);                                               ... load project structure
project                                 = define_project_paths(project);    ... set path
analysis                                = initAnalysisStructure(project);   ... load analysis structure, possibly retrieving some project parameters useful for analysis
%% =====================================================================================================================================================================
%  ===================================================================================================================================================================
%  OPERATIONS LIST 
%=====================================================================================================================================================================

% datelabel = ['-' datestr(now,30);
datelabel = '';

analysis.name = ['ERP_tw_noalign_mesial' datelabel];
analysis.design_num_vec          = [4]; ...[2,3];
analysis.list_select_subjects    = [];


analysis.erp.roi_list={ {'Pz'};{'CPz'};{'Cz'};{'FCz'};{'Fz'}};
analysis.erp.roi_names={'Pz','CPz', 'Cz', 'FCz', 'Fz'};


startProcess(analysis, 'do_study_plot_roi_erp_curve_tw_individual_noalign');
startProcess(analysis, 'do_study_plot_roi_erp_curve_tw_individual_align');

% --------------------------------------------------------------------------------------
analysis.epr.stats.pvalue = 0.05;
startProcess(analysis, 'do_study_plot_roi_erp_curve_tw_individual_align');

% --------------------------------------------------------------------------------------
analysis.name ='ERP_tw_align_mesial_none001'
analysis.epr.stats.pvalue = 0.001;
analysis.epr.stats.correction = 'none';
startProcess(analysis, 'do_study_plot_roi_erp_curve_tw_individual_align');

% --------------------------------------------------------------------------------------
analysis.name ='ERP_tw_align_mesial_fdr05'
analysis.epr.stats.pvalue = 0.05;
analysis.epr.stats.correction = 'fdr';
startProcess(analysis, 'do_study_plot_roi_erp_curve_tw_individual_align');
















































%=====================================================================================================================================================================
% create a study from preprocessed datasets
project.operations.do_study                                                         = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% create one merged epochs file for each condition and group in the study
project.operations.do_group_averages                                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% create a set of experimental designs within a created study
project.operations.do_design                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% precompute channels measures for a set of designs: these measures are used in group statistics. 
% Mandatory if some dataset of the study is changed.
project.operations.do_study_compute_channels_measures                               = 0;
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------


%% ******************************************************************************************************************************************
%==========================================================================================================================================
% E R P  analysis
%==========================================================================================================================================
%******************************************************************************************************************************************
% 13 modalities based on 2 functions
%
% proj_eeglab_study_plot_roi_erp_curve
% proj_eeglab_study_plot_erp_topo_tw
%==========================================================================================================================================



%% -------------------------------------------------------------------------------------------
% ERP CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors 
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erp_curve

% CONTINUOUS: analyzes and plots of erp curve for all time points
project.operations.do_study_plot_roi_erp_curve_continous                            = 1;

% TIMEWINDOW: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within group time windows
project.operations.do_study_plot_roi_erp_curve_tw_group_noalign                     = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_erp_curve_tw_group_align                       = 0;

% perform (and save) statistics based on individual subjects within time windows
project.operations.do_study_plot_roi_erp_curve_tw_individual_noalign                = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_erp_curve_tw_individual_align                  = 0;


%% -------------------------------------------------------------------------------------------
% FOR ERP, eog CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erpeog_curve

% CONTINUOUS: analyzes and plots of erp curve for all time points
project.operations.do_study_plot_roi_erpeog_curve_continous                            = 0;

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpeog_curve_tw_group_noalign                     = 0;

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpeog_curve_tw_group_align                       = 0;

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpeog_curve_tw_individual_noalign                = 0;
    

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpeog_curve_tw_individual_align                  = 0;



%% -------------------------------------------------------------------------------------------
% FOR ERP, emg CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erpemg_curve

% CONTINUOUS: analyzes and plots of erp curve for all time points
project.operations.do_study_plot_roi_erpemg_curve_continous                            = 0;

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpemg_curve_tw_group_noalign                     = 0;

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpemg_curve_tw_group_align                       = 0;

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpemg_curve_tw_individual_noalign                = 0;
    

% analyzes and plots of erp curve for time windows of the selected design
project.operations.do_study_plot_roi_erpemg_curve_tw_individual_align                  = 0;


%% -------------------------------------------------------------------------------------------
% ERP_TOPO_TW
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_erp_topo_tw
% settings:
% project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar' 
% TIMEWINDOW: perform (and save) statistics based time windows

%--------------------------------------------------------
% STANDARD, topographical erp modality
%--------------------------------------------------------

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
project.operations.do_study_plot_erp_topo_tw_group_noalign                          = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_tw_group_align                            = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_erp_topo_tw_individual_noalign                     = 0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_tw_individual_align                       = 0;

%--------------------------------------------------------
% COMPACT, topographical erp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_erp_topo_compact_tw_group_noalign                  = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_compact_tw_group_align                    = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_erp_topo_compact_tw_individual_noalign             = 0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_compact_tw_individual_align               = 0;



project.operations.do_eeglab_study_export_erp_r                                     = 0;

%% ******************************************************************************************************************************************
%==========================================================================================================================================
% E R S P  analysis (Time-frequency domain)
%==========================================================================================================================================
%******************************************************************************************************************************************
% 23 modalities based on 3 main functions:
% 
% proj_eeglab_study_plot_roi_ersp_tf
% proj_eeglab_study_plot_roi_ersp_curve_fb
% proj_eeglab_study_plot_ersp_topo_tw_fb
%==========================================================================================================================================




%%-------------------------------------------------------------------------------------------
% ERSP_TF, standard ersp time frequency: evaluate and represent standard EEGLab statistics on the time-frequency distribution of ERSP  
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_ersp_tf
% perform (and save) statistics based the whole ERSP, time-frequency distribution (possibly decimated in the frequency and/or in the time domain)

% continuous
project.operations.do_study_plot_roi_ersp_tf_continuous                             = 0;

% decimate_times 
project.operations.do_study_plot_roi_ersp_tf_decimate_times                         = 0;

% decimate_freqs 
project.operations.do_study_plot_roi_ersp_tf_decimate_freqs                         = 0;

% decimate_times_freqs
project.operations.do_study_plot_roi_ersp_tf_decimate_times_freqs                   = 0;

% time-frequency distribution freely binned in the frequency and/or in the time domain
project.operations.do_study_plot_roi_ersp_tf_tw_fb                                  = 0;


%% ------------------------------------------------------------------------------------------
% ERSP_CURVE, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_ersp_curve_fb

%--------------------------------------------------------
% STANDARD
%--------------------------------------------------------

% continuous
project.operations.do_study_plot_roi_ersp_curve_continous_standard                  = 0;

% TIMEWINDOW: perform (and save) statistics based on time windows

% grand-mean of subjects within group time windows
project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_standard           = 0;

% grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_group_align_standard             = 0;

% perform (and save) statistics based on individual subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_standard      = 0;

% perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_standard        = 0;


%--------------------------------------------------------
% COMPACT
%--------------------------------------------------------

% continuous
project.operations.do_study_plot_roi_ersp_curve_continous_compact                   = 0;

% TIMEWINDOW: perform (and save) statistics based on time windows

% perform (and save) statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_compact            = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_group_align_compact              = 0;

% perform (and save) statistics based on individual subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_compact       = 0;

% perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_compact         = 0;




%% -------------------------------------------------------------------------------------------
% FOR ersp, eog CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erspeog_curve

% CONTINUOUS: analyzes and plots of ersp curve for all time points
project.operations.do_study_plot_roi_erspeog_curve_continous                            = 0;

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspeog_curve_tw_group_noalign                     = 0;

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspeog_curve_tw_group_align                       = 0;

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspeog_curve_tw_individual_noalign                = 0;
    

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspeog_curve_tw_individual_align                  = 0;



%% -------------------------------------------------------------------------------------------
% FOR ersp, emg CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erspemg_curve

% CONTINUOUS: analyzes and plots of ersp curve for all time points
project.operations.do_study_plot_roi_erspemg_curve_continous                            = 0;

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspemg_curve_tw_group_noalign                     = 0;

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspemg_curve_tw_group_align                       = 0;

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspemg_curve_tw_individual_noalign                = 0;
    

% analyzes and plots of ersp curve for time windows of the selected design
project.operations.do_study_plot_roi_erspemg_curve_tw_individual_align                  = 0;



%% ------------------------------------------------------------------------------------------
% ERSP_TOPO_TW_FB, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_ersp_topo_tw_fb



%--------------------------------------------------------
% STANDARD, topographical ersp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign                      = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_group_align                        = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign                 = 0;

% perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_individual_align                   = 0;


%--------------------------------------------------------
% COMPACT, topographical ersp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign_compact              = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_group_align_compact                = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign_compact         = 0;

% perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_individual_align_compact           = 0;




project.operations.do_eeglab_study_export_ersp_tf_r                                 = 0;

%% =====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%  S T A R T    P R O C E S S I N G  
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================

try
  
%     project.stats.erp.num_permutations = 2;
%     do_operations
% 
% 
%     design_num_vec          = [4];
%     project.stats.erp.num_permutations = 100000;
%     stat_analysis_suffix = 'erp_N1_N2_ventral_reduced_100000perm_wnd20ms_180-250_365-450_eye_regr_sign_all_full_005_fdr';
    ...stat_analysis_suffix = 'erp_N2_central_reduced_100000perm_wnd20ms_380-480_eye_regr_sign_all_full_005_fdr';
    ...stat_analysis_suffix = 'erp_MPP_100000perm_wnd20ms_250-400_400-700_eye_regr_sign_all_full_005_fdr';

%     proj_eeglab_study_plot_roi_erp_curve_regr_sign_all_full(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);        
    ...proj_eeglab_study_plot_roi_erp_curve_regr_all_full(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);        
%     proj_eeglab_study_plot_roi_erp_curve_regr_sign_by_tw_full(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);        
    ...proj_eeglab_study_plot_roi_erp_curve_regr_by_tw_full(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);        
    
   
catch err
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)    
end
