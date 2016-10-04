% it will contain as much CASE branches as the available processes
% result is an EEG structure in case of subject processing 
% otherwise is
function result = startProcess(project, action_name, stat_analysis_suffix, design_num_vec, list_select_subjects, varargin)

    strpath = path;
    if ~strfind(strpath, project.paths.shadowing_functions)
        addpath(project.paths.shadowing_functions);      % eeglab shadows the fminsearch function => I add its path in case I previously removed it
    end

    result = [];
%     try
        
        switch action_name

            %% =====================================================================================================================================================================
            % S U B J E C T    P R O C E S S I N G
            %=====================================================================================================================================================================
            case 'do_import'
                proj_eeglab_subject_import_data(project, 'list_select_subjects', list_select_subjects);

            case 'do_testart'
                % allow testing some semi-automatic aritfact removal algorhithms
                result = proj_eeglab_subject_testart(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'do_preproc'
                proj_eeglab_subject_preprocessing(project, 'list_select_subjects', list_select_subjects);

            case 'do_emg_analysis'
                eeglab_subject_emgextraction_epoching(project, 'list_select_subjects', list_select_subjects);

            case 'do_auto_pauses_removal'

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

            case 'do_ica'
                % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
                result = proj_eeglab_subject_ica(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'do_uniform_montage'
                % uniform montages between different polygraphs
                result = proj_eeglab_subject_uniform_montage(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'do_reref'
                % rereferencing 
                result = proj_eeglab_subject_reref(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'do_mark_trial'
                % mark trial begin and end
                result = proj_eeglab_subject_marktrial(project, 'list_select_subjects', list_select_subjects);

            case 'do_mark_baseline'
                % mark baseline begin and end
                result = proj_eeglab_subject_markbaseline(project, 'list_select_subjects', list_select_subjects);

            case 'check_mc'
                % mark baseline begin and end
                result = proj_eeglab_subject_check_mc(project, 'list_select_subjects', list_select_subjects);

            case 'epochs'
                % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
                result = proj_eeglab_subject_epoching(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'handedness_epochs'
                % swap data according to handedness and to epoching 
                result = proj_eeglab_subject_handedness_epoching(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'factors'
                result = proj_eeglab_subject_add_factor(project, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            case 'singlesubjects_band_comparison'
                disp('to be implemented');

            case 'extract_narrowband'
                result = proj_eeglab_subject_extract_narrowband(project, stat_analysis_suffix, 'list_select_subjects', list_select_subjects, 'custom_suffix', custom_suffix);

            %% ===================================================================================================================================================================
            % STUDY CREATION & DESIGN
            %===================================================================================================================================================================
            case 'study'
                proj_eeglab_study_create(project);

            case 'group_averages'
                proj_eeglab_study_create_group_conditions(project);

            case 'design'
                proj_eeglab_study_define_design(project);

            case 'study_compute_channels_measures'
                proj_eeglab_study_compute_channels_measures(project, 'recompute', project.study.precompute.recompute, 'erp', project.study.precompute.erp, 'ersp', project.study.precompute.ersp, 'erpim', project.study.precompute.erpim, 'spec', project.study.precompute.spec, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects); 

            %=====================================================================================================================================================================
            % DO ANALYSIS
            %===================================================================================================================================================================

            %% ==========================================================================================================================================
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

            case 'study_plot_roi_erp_curve_continous'
                proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            % TIMEWINDOW: perform (and save) statistics based time windows
            case 'study_plot_roi_erp_curve_tw_group_noalign'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erp_curve_tw_group_align'
            % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erp_curve_tw_individual_noalign'
            % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erp_curve_tw_individual_align'
            % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            %% -------------------------------------------------------------------------------------------
            % FOR ERP, EOG CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_roi_erpeog_curve

            case 'study_plot_roi_erpeog_curve_continous'
            % CONTINUOUS: analyzes and plots of erp curve for all time points
                proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            % TIMEWINDOW: perform (and save) statistics based time windows
            case 'study_plot_roi_erpeog_curve_tw_group_noalign'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpeog_curve_tw_group_align'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpeog_curve_tw_individual_noalign'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpeog_curve_tw_individual_align'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpeog_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            %% -------------------------------------------------------------------------------------------
            % FOR ERP, emg CURVE_standard, standard curve erp modality: evaluate and represent standard EEGLab statistics on the curve of ERP, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_roi_erpemg_curve

            case 'study_plot_roi_erpemg_curve_continous'
                % CONTINUOUS: analyzes and plots of erp curve for all time points
                proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            % TIMEWINDOW: perform (and save) statistics based time windows
            case 'study_plot_roi_erpemg_curve_tw_group_noalign'
            % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpemg_curve_tw_group_align'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpemg_curve_tw_individual_noalign'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erpemg_curve_tw_individual_align'
                % analyzes and plots of erp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erpemg_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);


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

            case 'study_plot_erp_topo_tw_group_noalign'
                % analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            case 'study_plot_erp_topo_tw_group_align'
                % analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            case 'study_plot_erp_topo_tw_individual_noalign'
                % analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off');

            case 'study_plot_erp_topo_tw_individual_align'
                % analyzes and plots of erp topographical maps for the selected bands in the time windows of the selected design
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            %--------------------------------------------------------
            % COMPACT, topographical erp modality
            %--------------------------------------------------------
            case 'study_plot_erp_topo_compact_tw_group_noalign'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

            case 'study_plot_erp_topo_compact_tw_group_align'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows,
                % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

            case 'study_plot_erp_topo_compact_tw_individual_noalign'
                % perform (and save) additional statistics based on individual subjects within time windows
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');

            case 'study_plot_erp_topo_compact_tw_individual_align'
                % perform (and save) additional statistics based on individual subjects within time windows,
                % adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

            %% -------------------------------------------------------------------------------------------
            % ALLCH_ERP_TIME
            %--------------------------------------------------------------------------------------------
            % master-function:                                       proj_eeglab_study_plot_allch_erp_time
            % settings:
            % evaluate and represent ERP of all channels as a function of time and
            % compare different conditions in a time x channels space (TANOVA)

            case 'study_plot_allch_erp_time'
                proj_eeglab_study_plot_allch_erp_time(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);


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

            case 'study_plot_roi_ersp_tf_continuous'
                % continuous
                proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','continuous' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);

            case 'study_plot_roi_ersp_tf_decimate_times'
                % decimate_times
                proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);

            case 'study_plot_roi_ersp_tf_decimate_freqs'
                % decimate_freqs
                proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);

            case 'study_plot_roi_ersp_tf_decimate_times_freqs'
                % decimate_times_freqs
                proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','decimate_times_freqs' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'mask_coef',mask_coef,'stat_freq_bands_list',stat_freq_bands_list);

            case 'study_plot_roi_ersp_tf_tw_fb'
                % time-frequency distribution freely binned in the frequency and/or in the time domain
                proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix,'ersp_tf_resolution_mode','tw_fb' , 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            %% ------------------------------------------------------------------------------------------
            % ERSP_CURVE, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_roi_ersp_curve_fb

            %--------------------------------------------------------
            % STANDARD
            %--------------------------------------------------------
            case 'study_plot_roi_ersp_curve_continous_standard'
                % continuous
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');

            % TIMEWINDOW: perform (and save) statistics based on time windows
            case 'study_plot_roi_ersp_curve_tw_group_noalign_standard'
                % grand-mean of subjects within group time windows
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');

            case 'study_plot_roi_ersp_curve_tw_group_align_standard'
                % grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');

            case 'study_plot_roi_ersp_curve_tw_individual_noalign_standard'
                % perform (and save) statistics based on individual subjects within time windows
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');

            case 'study_plot_roi_ersp_curve_tw_individual_align_standard'
                % perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','off');

            %--------------------------------------------------------
            % COMPACT
            %--------------------------------------------------------

            case 'study_plot_roi_ersp_curve_continous_compact'
                % continuous
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');

            % TIMEWINDOW: perform (and save) statistics based on time windows
            case 'study_plot_roi_ersp_curve_tw_group_noalign_compact'
                % grand-mean of subjects within group time windows
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');

            case 'study_plot_roi_ersp_curve_tw_group_align_compact'
                % grand-mean of subjects within time windows,adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');

            case 'study_plot_roi_ersp_curve_tw_individual_noalign_compact'
                % perform (and save) statistics based on individual subjects within time windows
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');

            case 'study_plot_roi_ersp_curve_tw_individual_align_compact'
                % perform (and save) statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_plots','on');


            %% -------------------------------------------------------------------------------------------
            % FOR ersp, EOG CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_roi_erspeog_curve

            % CONTINUOUS: analyzes and plots of ersp curve for all time points

            case 'study_plot_roi_erspeog_curve_continous'        
                proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            % TIMEWINDOW: perform (and save) statistics based time windows

            case 'study_plot_roi_erspeog_curve_tw_group_noalign'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspeog_curve_tw_group_align'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspeog_curve_tw_individual_noalign'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspeog_curve_tw_individual_align'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspeog_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            %% -------------------------------------------------------------------------------------------
            % FOR ersp, emg CURVE_standard, standard curve ersp modality: evaluate and represent standard EEGLab statistics on the curve of ersp, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_roi_erspemg_curve

            % CONTINUOUS: analyzes and plots of ersp curve for all time points

            case 'study_plot_roi_erspemg_curve_continous'        
                proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            % TIMEWINDOW: perform (and save) statistics based time windows

            case 'study_plot_roi_erspemg_curve_tw_group_noalign'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspemg_curve_tw_group_align'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspemg_curve_tw_individual_noalign'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            case 'study_plot_roi_erspemg_curve_tw_individual_align'
                % analyzes and plots of ersp curve for time windows of the selected design
                proj_eeglab_study_plot_roi_erspemg_curve(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);

            %% ------------------------------------------------------------------------------------------
            % ERSP_TOPO_TW_FB, evaluate and represent standard EEGLab statistics on the curve of ERSP in a selected frequency, plot together levels of design factors
            %--------------------------------------------------------------------------------------------
            % master-function:                                      proj_eeglab_study_plot_ersp_topo_tw_fb

            %--------------------------------------------------------
            % STANDARD, topographical ersp modality
            %--------------------------------------------------------

            case 'study_plot_ersp_topo_tw_fb_group_noalign'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            case 'study_plot_ersp_topo_tw_fb_group_align'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            case 'study_plot_ersp_topo_tw_fb_individual_noalign'
                % perform (and save) additional statistics based on individual subjects within time windows
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off');

            case 'study_plot_ersp_topo_tw_fb_individual_align'
                % perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','off' );

            %--------------------------------------------------------
            % COMPACT, topographical ersp modality
            %--------------------------------------------------------
            case 'study_plot_ersp_topo_tw_fb_group_noalign_compact'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

            case 'study_plot_ersp_topo_tw_fb_group_align_compact'
                % perform (and save) additional statistics based on grand-mean of subjects within time windows. adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

            case 'study_plot_ersp_topo_tw_fb_individual_noalign_compact'
                % perform (and save) additional statistics based on individual subjects within time windows
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on');

            case 'study_plot_ersp_topo_tw_fb_individual_align_compact'
                % perform (and save) additional statistics based on individual subjects within time windows, adjusting the group time windows to time windws which are re-aligned to the latencies of time window extrema
                proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects,'display_compact_topo','on' );

        end
        
        result = [];
%     catch err
%         % This "catch" section executes in case of an error in the "try" section
%         err
%         err.message
%         err.stack(1)
%         result = err;
%         throw(err);
%     end
        
end

