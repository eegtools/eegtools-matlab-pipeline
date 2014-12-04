%==============================================================================================================================================
%==============================================================================================================================================
%==============================================================================================================================================
% SUBJECTS ANALYSIS
%==============================================================================================================================================
%==============================================================================================================================================
%==============================================================================================================================================

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% import raw data and write set/fdt file into epochs subfolder, perform: import, event to string, channel lookup, global filtering
project.operations.do_import                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% preprocessing of the imported file: SUBSAMPLING, CHANNELS TRANSFORMATION, INTERPOLATION, RE-REFERENCE, SPECIFIC FILTERING
project.operations.do_preproc                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% do custom modification to event triggers
project.operations.do_patch_triggers                                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% remove pauses and undesidered time interval marked by specific markers
project.operations.do_auto_pauses_removal                                           = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform ICA
project.operations.do_ica                                                           = 0; 

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% epoching
project.operations.do_epochs                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% add experimental factors information to the data
project.operations.do_factors                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform basic single-subject plotting and analysis, basically 1 condition spectral graphs, single epochs desynch, or 2 conditions comparisons
project.operations.do_singlesubjects_band_comparison                                = 0;



%==============================================================================================================================================
%==============================================================================================================================================
%==============================================================================================================================================
% GROUP ANALYSIS
%==============================================================================================================================================
%==============================================================================================================================================
%==============================================================================================================================================

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


%%=====================================================================================================================================================================
% Time domain (ERP)
%=====================================================================================================================================================================

%% erp_curve_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors 
% master-function: proj_eeglab_study_plot_roi_erp_curve

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% CONTINUOUS: perform (and save) statistics based the whole ERP curve
project.operations.do_study_plot_roi_erp_curve_continous                            = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

%% erp_topo_tw_standard, standard topographical erp modality
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb
% settings:
% project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar'  

% perform (and save) additional statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_erp_topo_tw_group_noalign                          = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_tw_group_align                            = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_erp_topo_tw_individual_noalign                     = 0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_erp_topo_tw_individual_align                       = 0;
% ===================================================================================================================================================================== 


%% erp_topo_tw_compact, compact topographical erp modality: evaluate and represent multiple comparisons within each time window 
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb
% settings:
% project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar'  

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

%%====================================================================================================================================================================== 
% Time-frequency domain (ERSP)
%=======================================================================================================================================================================

%% ersp_tf, standard ersp time frequency: evaluate and represent standard EEGLab statistics on the time-frequency distribution of ERSP, plot together levels of design factors  
% master-function: proj_eeglab_study_plot_roi_ersp_tf

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% CONTINUOUS: perform (and save) statistics based the whole ERSP
% time-frequency distribution (possibly decimated in the frequency and/or in the time domain)
project.operations.do_study_plot_roi_ersp_tf_continuous                             = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% TIMEWINDOW_FREQUENCYBAND: perform (and save) statistics based the ERSP
% time-frequency distribution freely binned in the frequency and/or in the time domain
project.operations.do_study_plot_roi_ersp_tf_tw_fb                                  = 0;

%% ersp_curve_fb_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
% master-function: proj_eeglab_study_plot_roi_ersp_curve_fb

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% continuous: perform (and save) statistics based the whole ERSP curve
project.operations.do_study_plot_roi_ersp_curve_continous_standard                  = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% TIMEWINDOW: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within group time windows
project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_standard           = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_group_align_standard             = 0;

% perform (and save) statistics based on individual subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_standard      = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_standard        = 0;
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------

%% ersp_curve_fb_compact, compact curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency band, plot separately levels of design factors 
% master-function: proj_eeglab_study_plot_roi_ersp_curve_fb

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% CONTINUOUS: perform (and save) statistics based the whole ERSP curve
project.operations.do_study_plot_roi_ersp_curve_continous_compact                   = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% TIMEWINDOW: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_compact            = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_group_align_compact              = 0;

% perform (and save) statistics based on individual subjects within time windows
project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_compact       = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_compact         = 0;

%% ersp_topo_tw_fb_compact, compact topographical ersp modality: evaluate and represent multiple comparisons within each time window 
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb
% TIMEWINDOW_FREQUENCYBAND

% perform (and save) additional statistics based on grand-mean of subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign                      = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_group_align                        = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign                 = 0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
project.operations.do_study_plot_ersp_topo_tw_fb_individual_align                   = 0;
% ===================================================================================================================================================================== 

project.operations.do_eeglab_study_export_ersp_tf_r                                 = 0;
