clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    project.paths.projects_data_root    = '/data/BIODATA/EEG';
    project.paths.svn_scripts_root      = '/wdata/SVN/behaviour_lab_svn';
    project.paths.plugins_root          = '/data/CODE/MATLAB';
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
project.conf_file_name      = 'template_project_structure';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
% I must just add the path of define_project_paths... then it loads everything
project.paths.script.eeg_tools          = fullfile(project.paths.svn_scripts_root, 'CommonScript', 'eeg','eeg_tools', ''); addpath(genpath(project.paths.script.eeg_tools)); 
eval(project.conf_file_name);                                                   % project structure
project                                 = define_project_paths(project);        % global and project paths definition. If 2nd param is 0 or absent, is faster, as it does not call eeglab
%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================
% to be edited according to experiment.....
%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================

stat_analysis_suffix='aocs_ao_C4_subject_similar_presound-TF_tw_fb';
stat_analysis_suffix=[stat_analysis_suffix,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS')];

design_num_vec          = [8:12 2:7];

% select number of subjects to be processed: can be  1) commented 2) set
% to [] 3( set to a cell array of strings 4) set to project.subjects.list
list_select_subjects    = project.subjects.list;% {'CC_01_vittoria', 'CC_02_fabio', 'CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara', 'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'}; ...project.subjects.list;

% if a list is not set, or is empty, all subjects in the project are
% processed 
if not(exist('list_select_subjects','var'))
    list_select_subjects    = project.subjects.list;
else
    if isempty(list_select_subjects) 
        list_select_subjects    = project.subjects.list;
    end
end
numsubj                         = length(list_select_subjects);
project.subjects.curr_list      = list_select_subjects;

% select a specific bannd to focus statistics in ersp tf (experimental)
mask_coef                       = [];
stat_freq_bands_list            = [];

% if the parameters are not set, they are assumed to be empty (i.e. no band
% selection)
if not(exist( 'mask_coef','var')) || not(exist( 'stat_freq_bands_list','var'))
    mask_coef=[];
    stat_freq_bands_list=[];
end

%% =====================================================================================================================================================================
%  OPERATIONS LIST 
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
project.operations.do_study_plot_roi_erp_curve_continous                            = 0;

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


%% ------------------------------------------------------------------------------------------
% ALLCH_ERP_TIME, evaluate and represent ERP of all channels as a fucntion
% of time and compare different conditions in a time x channels space (TANOVA)
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_allch_erp_time
project.proj_eeglab_study_plot_allch_erp_time                                              = 0;
%% ------------------------------------------------------------------------------------------
% ALLCH_ERP_TIME, evaluate and represent ERP of all channels as a fucntion
% of time and compare different conditions in a time x channels space
% (TANOVA) USING FIELDTRIB CLUSETR BASED PERMUTATION STATISTICS
%--------------------------------------------------------------------------------------------
project.operations.do_study_plot_cluster_fieldtrip                                         = 0;




%% -------------------------------------------------------------------------------------------
% ALLCH_ERP_CC_TIME
%--------------------------------------------------------------------------------------------
% master-function:                                       proj_eeglab_study_plot_allch_erp_cc_time
% settings:
% evaluate and represent cross correlation of ERP of all channels between levels of one factor as a function of time and
% compare different levels of the other factor in a time x channels space (TANOVA)
project.operations.do_study_plot_allch_erp_cc_time                                              = 0;








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
    
   do_operations
   
   
catch err
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)    
end
