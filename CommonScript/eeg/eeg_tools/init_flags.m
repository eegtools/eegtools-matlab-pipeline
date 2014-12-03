%=======================================================================0
% SUBJECTS ANALYSIS
%=======================================================================0
do_import=0;
do_preproc=0;
do_patch_triggers=0;
do_auto_pauses_removal=0;
do_ica=0; 
do_epochs=0;
do_factors=0;
do_singlesubjects_band_comparison=0;




%=======================================================================0
% GROUP ANALYSIS
%=======================================================================0
%% Preliminary steps
%%####################################################################################################################################################################

% create a study from preprocessed datasets
do_study=0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% create one merged epochs file for each condition and group in the study
do_group_averages=0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% create a set of experimental designs within a created study
do_design=0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% precompute channels measures for a set of designs: these measures are used in group statistics. 
% Mandatory if some dataset of the study is changed.
do_study_compute_channels_measures=0;
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------


%% Calculate and display statistics
%%####################################################################################################################################################################

%% Time domain (ERP)
%=====================================================================================================================================================================

%% erp_curve_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors 
% master-function: proj_eeglab_study_plot_roi_erp_curve

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% continuous: perform (and save) statistics based the whole ERP curve
do_study_plot_roi_erp_curve_continous=0;


%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% tw: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within group time windows
do_study_plot_roi_erp_curve_tw_group_noalign = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_erp_curve_tw_group_align = 0;

% perform (and save) statistics based on individual subjects within time windows
do_study_plot_roi_erp_curve_tw_individual_noalign = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_erp_curve_tw_individual_align = 0;


%% erp_topo_tw_standard, standard topographical erp modality
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb
% settings:
% project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar'  

% perform (and save) additional statistics based on grand-mean of subjects within time windows
do_study_plot_erp_topo_tw_group_noalign=0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_erp_topo_tw_group_align=0; 

% perform (and save) additional statistics based on individual subjects within time windows
do_study_plot_erp_topo_tw_individual_noalign=0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_erp_topo_tw_individual_align=0;
% ===================================================================================================================================================================== 


%% erp_topo_tw_compact, compact topographical erp modality: evaluate and represent multiple comparisons within each time window 
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb
% settings:
% project.results_display.erp.display_compact_topo_mode to represent comparisons: 'boxplot'/'errorbar'  

% perform (and save) additional statistics based on grand-mean of subjects within time windows
do_study_plot_erp_topo_compact_tw_group_noalign=0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_erp_topo_compact_tw_group_align=0; 

% perform (and save) additional statistics based on individual subjects within time windows
do_study_plot_erp_topo_compact_tw_individual_noalign=0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_erp_topo_compact_tw_individual_align=0;
% ===================================================================================================================================================================== 


%% Time-frequency domain (ERSP)
%=====================================================================================================================================================================

%% ersp_tf, standard ersp time frequency: evaluate and represent standard EEGLab statistics on the time-frequency distribution of ERSP, plot together levels of design factors  
% master-function: proj_eeglab_study_plot_roi_ersp_tf

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% continuous: perform (and save) statistics based the whole ERSP
% time-frequency distribution (possibly decimated in the frequency and/or in the time domain)
do_study_plot_roi_ersp_tf_continuous=0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% tw_fb: perform (and save) statistics based the ERSP
% time-frequency distribution freely binned in the frequency and/or in the time domain
do_study_plot_roi_ersp_tf_tw_fb=0;

%% ersp_curve_fb_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
% master-function: proj_eeglab_study_plot_roi_ersp_curve_fb

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% continuous: perform (and save) statistics based the whole ERSP curve
do_study_plot_roi_ersp_curve_continous_standard=0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% tw: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within group time windows
do_study_plot_roi_ersp_curve_tw_group_noalign_standard = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_ersp_curve_tw_group_align_standard = 0;

% perform (and save) statistics based on individual subjects within time windows
do_study_plot_roi_ersp_curve_tw_individual_noalign_standard = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_ersp_curve_tw_individual_align_standard = 0;
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------


%% ersp_curve_fb_compact, compact curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency band, plot separately levels of design factors 
% master-function: proj_eeglab_study_plot_roi_ersp_curve_fb

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% continuous: perform (and save) statistics based the whole ERSP curve
do_study_plot_roi_ersp_curve_continous_compact = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% tw: perform (and save) statistics based time windows

% perform (and save) statistics based on grand-mean of subjects within time windows
do_study_plot_roi_ersp_curve_tw_group_noalign_compact = 0;

% perform (and save) statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_ersp_curve_tw_group_align_compact = 0;

% perform (and save) statistics based on individual subjects within time windows
do_study_plot_roi_ersp_curve_tw_individual_noalign_compact = 0;

% perform (and save) statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_roi_ersp_curve_tw_individual_align_compact = 0;


%% ersp_topo_tw_fb_compact, compact topographical ersp modality: evaluate and represent multiple comparisons within each time window 
% master-function: proj_eeglab_study_plot_ersp_topo_tw_fb


% perform (and save) additional statistics based on grand-mean of subjects within time windows
do_study_plot_ersp_topo_tw_fb_group_noalign = 0; 

% perform (and save) additional statistics based on grand-mean of subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_ersp_topo_tw_fb_group_align = 0; 

% perform (and save) additional statistics based on individual subjects within time windows
do_study_plot_ersp_topo_tw_fb_individual_noalign = 0;

% perform (and save) additional statistics based on individual subjects within time windows, 
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
do_study_plot_ersp_topo_tw_fb_individual_align = 0;
% ===================================================================================================================================================================== 

do_eeglab_study_export_ersp_tf_r = 0;
