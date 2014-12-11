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
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj}; ... inputfile=fullfile(project.paths.original_data, [project.subjects.list{subj} project.import.original_data_suffix '.' project.import.original_data_extension]);
        proj_eeglab_subject_import_data(project, subj_name);
    end
end
%==================================================================================
if project.operations.do_preproc        
    for subj=1:project.subjects.numsubj 
        subj_name=project.subjects.list{subj};
        
        proj_eeglab_subject_preprocessing(project, subj_name);
        if project.do_emg_analysis
            eeglab_subject_emgextraction_epoching(project, subj_name);
        end
    end
end
%==================================================================================
if project.operations.do_auto_pauses_removal
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj};        
        file_name=fullfile(project.paths.input_epochs, [subj_name pre_epoching_input_file_name '.set']);
        
        eeglab_subject_events_remove_upto_triggercode(file_name, project.task.events.start_experiment_trigger_value); ... return if find a boundary as first event
        eeglab_subject_events_remove_after_triggercode(file_name, project.task.events.end_experiment_trigger_value); ... return if find a boundary as first event
        pause_resume_errors=eeglab_subject_events_check_2triggers_orders(file_name, project.task.events.pause_trigger_value, project.task.events.resume_trigger_value);
    
        if isempty(pause_resume_errors)
            disp('====>> pause/remove triggers sequence ok....move to pause removal');
            eeglab_subject_remove_pauses(file_name, project.task.events.pause_trigger_value, project.task.events.resume_trigger_value);
        else
            disp('====>> errors in pause/resume trigger sequence');
            pause_resume_errors
        end
    end
end
%==================================================================================
if project.operations.do_ica
    % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj}; 
        inputfile=fullfile(project.paths.input_epochs, [subj_name pre_epoching_input_file_name '.set']);
        eeglab_subject_ica(inputfile, project.paths.input_epochs, project.eegdata.eeg_channels_list, 'cudaica');
    end
end
%==================================================================================
if project.operations.do_epochs
    % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
     for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj};
        proj_eeglab_subject_epoching(project, subj_name);
     end
end
%==================================================================================
if project.operations.do_factors
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj};        
        proj_eeglab_subject_add_factor(project, subj_name);
    end
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
    proj_eeglab_study_compute_channels_measures(project, 'recompute', project.study.precompute.recompute, 'do_erp', project.study.precompute.do_erp, 'do_ersp', project.study.precompute.do_ersp, 'do_erpim', project.study.precompute.do_erpim, 'do_spec', project.study.precompute.do_spec, 'design_num_vec', design_num_vec); ..., 'sel_cell_string', 'CC_01'); ... ,
end
%==================================================================================
if project.operations.do_study_compute_statistics
    proj_eeglab_study_compute_statistics(project, 'recompute', project.stats.recompute, 'do_erp_time', project.stats.do_erp_time, 'do_ersp_time', project.stats.do_ersp_time, 'do_erp_topo', project.stats.do_erp_topo, 'do_ersp_topo', project.stats.do_erp_topo, 'design_num_vec', design_num_vec, 'sel_cell_string', 'CC_01');
end




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
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_group_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_individual_noalign
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');
end

% analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
if project.operations.do_study_plot_erp_topo_tw_individual_align
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
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
 

% %%  export to R
% if project.operations.do_eeglab_study_export_erp_r
% %     vec_sel_design=[2,8,9];
% %     sel_designs=[1:3];
%     for design_num=1:length(sel_designs)
%         sel_des=vec_sel_design(sel_designs(design_num));
%         eeglab_study_export_r(project_settings, fullfile(epochs_path, [protocol_name, '.study']), sel_des, export_r_bands, tf_path);
%     end
% end





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
  proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','continuous' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',10,'stat_freq_bands_list',[14,20]); 
end

% decimate_times
if project.operations.do_study_plot_roi_ersp_tf_decimate_times
  proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',10,'stat_freq_bands_list',[14,20]); 
end

% decimate_freqs
if project.operations.do_study_plot_roi_ersp_tf_decimate_freqs
  proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',10,'stat_freq_bands_list',[14,20]); 
end

% decimate_times_freqs
if project.operations.do_study_plot_roi_ersp_tf_decimate_times_freqs
  proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',10,'stat_freq_bands_list',[14,20]); 
end

% time-frequency distribution freely binned in the frequency and/or in the time domain
if project.operations.do_study_plot_roi_ersp_tf_tw_fb
   proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','tw_fb' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects); 
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


%% ------------------------------------------------------------------------------------------
% ERSP_TOPO_TW_FB, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors 
%--------------------------------------------------------------------------------------------
% master-function:                                      proj_eeglab_study_plot_ersp_topo_tw_fb



%--------------------------------------------------------
% STANDARD, topographical ersp modality
%--------------------------------------------------------

% perform (and save) additional statistics based on grand-mean of subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_group_noalign
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_group_align
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
end

% perform (and save) additional statistics based on individual subjects within time windows
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_noalign
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');
end

% perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
if project.operations.do_study_plot_ersp_topo_tw_fb_individual_align
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );
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


% %%  export to R
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
