%% =====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
% S U B J E C T    P R O C E S S I N G
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
strpath = path;
if ~strfind(strpath, project.paths.shadowing_functions)
    addpath(project.paths.shadowing_functions);      % eeglab shadows the fminsearch function => I add its path in case I previously removed it
end
%==================================================================================
if project.operations.do_import
    proj_eeglab_subject_import_data(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_testart
    % allow testing some semi-automatic aritfact removal algorhithms
    EEG = proj_eeglab_subject_testart(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================
if project.operations.do_preproc
    proj_eeglab_subject_preprocessing(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_emg_analysis
    eeglab_subject_emgextraction_epoching(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_auto_pauses_removal
    if isempty(list_select_subjects)
        list_select_subjects = project.subjects.list;
    end
    numsubj = length(list_select_subjects);
    for subj=1:numsubj
        subj_name   = list_select_subjects{subj};
        file_name   = proj_eeglab_subject_get_filename(project, subj_name, 'custom_pre_epochs', 'custom_suffix', custom_suffix);
        
        eeglab_subject_events_remove_upto_triggercode(file_name, project.task.events.start_experiment_trigger_value); ... return if find a boundary as first event
        eeglab_subject_events_remove_after_triggercode(file_name, project.task.events.end_experiment_trigger_value); ... return if find a boundary as first event
        pause_resume_errors = eeglab_subject_events_check_2triggers_orders(file_name, project.task.events.pause_trigger_value, project.task.events.resume_trigger_value);
        
        if isempty(pause_resume_errors)
            disp('====>> pause/remove triggers sequence ok....move to pause removal');
            eeglab_subject_remove_pauses(file_name, project.task.events.pause_trigger_value, project.task.events.resume_trigger_value);
        else
            disp('====>> errors in pause/resume trigger sequence');
            pause_resume_errors;
        end
    end
end
%==================================================================================
if project.operations.do_ica
    % do preprocessing ica
    EEG = proj_eeglab_subject_ica(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end

if project.operations.do_clean_ica
   % use/test semi automatic toolboxes based on ICA to identify bad components
    EEG = proj_eeglab_subject_clean_ica(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end


%==================================================================================
if project.operations.do_mark_trial
    % mark trial begin and end
    EEG = proj_eeglab_subject_marktrial(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_mark_baseline
    % mark baseline begin and end
    EEG = proj_eeglab_subject_markbaseline(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_uniform_montage
    % uniform montages between different polygraphs
    EEG = proj_eeglab_subject_uniform_montage(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================
if project.operations.do_reref
    % rereferencing 
    EEG = proj_eeglab_subject_reref(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end


%==================================================================================
if project.operations.do_check_mc
    % mark baseline begin and end
    EEG = proj_eeglab_subject_check_mc(project, 'list_select_subjects', list_select_subjects);
end
%==================================================================================
if project.operations.do_epochs
    % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
    EEG = proj_eeglab_subject_epoching(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================
if project.operations.do_handedness_epochs
    % swap data according to handedness and to epoching 
    EEG = proj_eeglab_subject_handedness_epoching(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================
if project.operations.do_factors
    EEG = proj_eeglab_subject_add_factor(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================
% if project.operations.do_singlesubjects_band_comparison
%     EEG = proj_eeglab_subject_add_factor(project, 'list_select_subjects', list_select_subjects);
% end
%==================================================================================
if project.operations.do_extract_narrowband
    EEG = proj_eeglab_subject_extract_narrowband(project, analysis_name ,'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);
end
%==================================================================================





%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%===================================================================================================================================================================
% STUDY CREATION & DESIGN
%===================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================

%=====================================================================================================================================================================
if project.operations.do_study
    proj_eeglab_study_create(project);
end
%==================================================================================
if project.operations.do_group_averages
    proj_eeglab_study_create_group_conditions(project);
end
%==================================================================================
if project.operations.do_design
    proj_eeglab_study_define_design(project);
end
%==================================================================================
if project.operations.do_study_compute_channels_measures
    proj_eeglab_study_compute_channels_measures(project, 'recompute', project.study.precompute.recompute, 'do_erp', project.study.precompute.do_erp, 'do_ersp', project.study.precompute.do_ersp, 'do_erpim', project.study.precompute.do_erpim, 'do_spec', project.study.precompute.do_spec, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects); 
end
%==================================================================================




%===================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
% PLOT RESULTS
%===================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================


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
if project.operations.do_study_plot_roi_erp_curve_continous
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erp_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erp_curve_tw_group_align
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erp_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erp_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% -------------------------------------------------------------------------------------------
% FOR ERP, EOG CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erpeog_curve

% CONTINUOUS: analyzes and plots of erp curve for all time points
if project.operations.do_study_plot_roi_erpeog_curve_continous
    proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpeog_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpeog_curve_tw_group_align
    proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpeog_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpeog_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% -------------------------------------------------------------------------------------------
% FOR ERP, emg CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erpemg_curve

% CONTINUOUS: analyzes and plots of erp curve for all time points
if project.operations.do_study_plot_roi_erpemg_curve_continous
    proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpemg_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpemg_curve_tw_group_align
    proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpemg_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erpemg_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


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
if project.operations.do_study_plot_erp_topo_tw_group_noalign
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_group_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_individual_noalign
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off');
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_individual_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

%--------------------------------------------------------
% COMPACT, topographical erp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
if project.operations.do_study_plot_erp_topo_compact_tw_group_noalign
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on grand-mean of subjects within time windows,
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_erp_topo_compact_tw_group_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on individual subjects within time windows
if project.operations.do_study_plot_erp_topo_compact_tw_individual_noalign
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');
end

% perform (and save) additional statistics based on individual subjects within time windows,
% adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_erp_topo_compact_tw_individual_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end



%% -------------------------------------------------------------------------------------------
% ALLCH_ERP_TIME
%--------------------------------------------------------------------------------------------
% master-function:                                       proj_eeglab_study_plot_allch_erp_time
% settings:
% evaluate and represent ERP of all channels as a function of time and
% compare different conditions in a time x channels space (TANOVA)

if project.operations.do_study_plot_allch_erp_time
    proj_eeglab_study_plot_allch_erp_time(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% -------------------------------------------------------------------------------------------
% ALLCH_ERP_CC_TIME
%--------------------------------------------------------------------------------------------
% master-function:                                       proj_eeglab_study_plot_allch_erp_cc_time
% settings:
% evaluate and represent cross correlation of ERP of all channels between levels of one factor as a function of time and
% compare different levels of the other factor in a time x channels space (TANOVA)

if project.operations.do_study_plot_allch_erp_cc_time
    proj_eeglab_study_plot_allch_erp_cc_time(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

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
if project.operations.do_study_plot_roi_ersp_tf_continuous
    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','continuous' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);
end

% decimate_times
if project.operations.do_study_plot_roi_ersp_tf_decimate_times
    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);
end

% decimate_freqs
if project.operations.do_study_plot_roi_ersp_tf_decimate_freqs
    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);
end

% decimate_times_freqs
if project.operations.do_study_plot_roi_ersp_tf_decimate_times_freqs
    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);
end

% time-frequency distribution freely binned in the frequency and/or in the time domain
if project.operations.do_study_plot_roi_ersp_tf_tw_fb
    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','tw_fb' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% -------------------------------------------------------------------------------------------
% ALLCH_ERSP_TIME
%--------------------------------------------------------------------------------------------
% master-function:                                       proj_eeglab_study_plot_allch_ersp_time
% settings:
% evaluate and represent ERP of all channels as a function of time and
% compare different conditions in a time x channels space (TANOVA)

if project.operations.do_study_plot_allch_ersp_curve_fb_time
    proj_eeglab_study_plot_allch_ersp_curve_fb_time(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% ------------------------------------------------------------------------------------------
% ERSP_CURVE, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_ersp_curve_fb

%--------------------------------------------------------
% STANDARD
%--------------------------------------------------------

% continuous
if project.operations.do_study_plot_roi_ersp_curve_continous_standard
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');
end

% TIMEWINDOW: perform (and save) statistics based on time windows

% grand-mean of subjects within group time windows
if project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_standard
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');
end

% grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_roi_ersp_curve_tw_group_align_standard
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');
end

% perform (and save) statistics based on individual subjects within time windows
if project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_standard
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');
end

% perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_standard
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');
end


%--------------------------------------------------------
% COMPACT
%--------------------------------------------------------

% continuous
if project.operations.do_study_plot_roi_ersp_curve_continous_compact
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');
end

% TIMEWINDOW: perform (and save) statistics based on time windows

% grand-mean of subjects within group time windows
if project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign_compact
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');
end

% grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_roi_ersp_curve_tw_group_align_compact
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');
end

% perform (and save) statistics based on individual subjects within time windows
if project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign_compact
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');
end

% perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_roi_ersp_curve_tw_individual_align_compact
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');
end




%% -------------------------------------------------------------------------------------------
% FOR ersp, EOG CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erspeog_curve

% CONTINUOUS: analyzes and plots of ersp curve for all time points
if project.operations.do_study_plot_roi_erspeog_curve_continous
    proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspeog_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspeog_curve_tw_group_align
    proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspeog_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspeog_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%% -------------------------------------------------------------------------------------------
% FOR ersp, emg CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_roi_erspemg_curve

% CONTINUOUS: analyzes and plots of ersp curve for all time points
if project.operations.do_study_plot_roi_erspemg_curve_continous
    proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% TIMEWINDOW: perform (and save) statistics based time windows

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspemg_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspemg_curve_tw_group_align
    proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspemg_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of ersp curve for time windows of the selected design
if project.operations.do_study_plot_roi_erspemg_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end






%% ------------------------------------------------------------------------------------------
% ERSP_TOPO_TW_FB, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_ersp_topo_tw_fb



%--------------------------------------------------------
% STANDARD, topographical ersp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

% perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_group_align
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

% perform (and save) additional statistics based on individual subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off');
end

% perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_align
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );
end

%--------------------------------------------------------
% COMPACT, topographical ersp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign_compact
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_group_align_compact
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on individual subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign_compact
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');
end

% perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_align_compact
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end


%%  export to R
% if project.operations.do_eeglab_study_export_ersp_tf_r
%     for design_num=1:length(sel_designs)
%         sel_des=vec_sel_design(sel_designs(design_num));
%         text_export_ersp_file();
%         get_stats_in_folder
%     end
% end
%
%
%











%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% erp analysis
% % anaylyzes and plots of erp curve for all time points (considering mean of time windows for statistics and graphics)
% if project.operations.do_study_plot_roi_erp_curve_continous
%     proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_erp_curve_tw_group_noalign
%     proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_erp_curve_tw_group_align
%     proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_erp_curve_tw_individual_noalign
%     proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_erp_curve_tw_individual_align
%     proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp topographical maps for time windows of the selected design
% if project.operations.do_study_plot_erp_topo_tw
%     proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, [], 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% ersp analysis
%
% % analyzes and plots of ersp time frequency distribution for all time-frequency points
% if project.operations.do_study_plot_roi_ersp_tf
%    project.results_display.ersp.display_only_significant_tf_mode='binary';
%    proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% if project.operations.do_study_plot_roi_ersp_curve_continous
%     proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_ersp_curve_tw_group_noalign
%     proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_ersp_curve_tw_group_align
%     proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_ersp_curve_tw_individual_noalign
%     proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of erp curve for time windows of the selected design
% if project.operations.do_study_plot_roi_ersp_curve_tw_individual_align
%     proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
% % analyzes and plots of ersp topographical maps for the selected bands in the time windows of the selected design
% if project.operations.do_study_plot_ersp_topo_tw_fb
%     proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, [], 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
% end
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%% export to R
% if project.operations.do_eeglab_study_export_ersp_tf_r
% %     vec_sel_design=[2,8,9];
% %     sel_designs=[1:3];
%     for design_num=1:length(sel_designs)
%         sel_des=vec_sel_design(sel_designs(design_num));
%         eeglab_study_export_tf_r(project_settings, fullfile(epochs_path, [protocol_name, '.study']), sel_des, export_r_bands, tf_path);
%     end
% end
%
%
%
%
% %=========================================================================================================
% %=========================================================================================================
% %=========================================================================================================
% %=========================================================================================================
% %=========================================================================================================
