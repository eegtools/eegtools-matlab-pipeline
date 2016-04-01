%=====================================================================================================================================================================
% OPERATIONS LIST 
%=====================================================================================================================================================================

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% import raw data and write set/fdt file into epochs subfolder, perform: import, event to string, channel lookup, global filtering
project.operations.do_import                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% preprocessing of the imported file: SUBSAMPLING, CHANNELS TRANSFORMATION, INTERPOLATION, RE-REFERENCE, SPECIFIC FILTERING
project.operations.do_preproc                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% analysis of emg data
project.operations.do_emg_analysis                                                  = 0; 

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% do custom modification to event triggers
project.operations.do_patch_triggers                                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% remove pauses and undesidered time interval marked by specific markers
project.operations.do_auto_pauses_removal                                           = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% allow testing some semi-automatic aritfact removal algorhithms
project.operations.do_testart                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform ICA
project.operations.do_ica                                                           = 0; 

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% uniform montages between different polygraphs
project.operations.do_uniform_montage                                               = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% do reref
project.operations.do_reref                                                         = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% mark trial begin and end
project.operations.do_mark_trial                                                    = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% mark baseline begin and end
project.operations.do_mark_baseline                                                 = 0;
   
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% check mc file status: triggers, num epochs, errors
project.operations.do_check_mc                                                      = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% epoching
project.operations.do_epochs                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% custom epoching
project.operations.do_custom_epochs                                                 = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% custom epoching that swap electrodes according to handedness
project.operations.do_handedness_epochs                                             = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% add experimental factors information to the data
project.operations.do_factors                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform basic single-subject plotting and analysis, basically 1 condition spectral graphs, single epochs desynch, or 2 conditions comparisons
project.operations.do_singlesubjects_band_comparison                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% extract narrowband for each subject and selected condition and save separately each condition in a mat file
project.operations.do_extract_narrowband                                            = 0;




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
