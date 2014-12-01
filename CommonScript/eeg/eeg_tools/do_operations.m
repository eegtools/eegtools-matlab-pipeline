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

if do_import
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj}; ... inputfile=fullfile(project.paths.original_data, [project.subjects.list{subj} project.import.original_data_suffix '.' project.import.original_data_extension]);
        proj_eeglab_subject_import_data(project, subj_name);
    end
end
        
if do_preproc        
    for subj=1:project.subjects.numsubj 
        subj_name=project.subjects.list{subj};
        
        proj_eeglab_subject_preprocessing(project, subj_name);
        if project.do_emg_analysis
            eeglab_subject_emgextraction_epoching(project, subj_name);
        end
    end
end

if do_auto_pauses_removal
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
if do_ica
    % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj}; 
        inputfile=fullfile(project.paths.input_epochs, [subj_name pre_epoching_input_file_name '.set']);
        eeglab_subject_ica(inputfile, project.paths.input_epochs, project.eegdata.eeg_channels_list, 'cudaica');
    end
end
%==================================================================================
if do_epochs
    % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
     for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj};
        proj_eeglab_subject_epoching(project, subj_name);
     end
end
%==================================================================================
if do_factors
    for subj=1:project.subjects.numsubj
        subj_name=project.subjects.list{subj};        
        proj_eeglab_subject_add_factor(project, subj_name);
    end
end
%==================================================================================





%% =====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
% G R O U P    P R O C E S S I N G  
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================
%=====================================================================================================================================================================


%===================================================================================================================================================================
% STUDY CREATION & DESIGN
%===================================================================================================================================================================
if do_study
    proj_eeglab_study_create(project);
end

if do_group_averages
   proj_eeglab_study_create_group_conditions(project); 
end

if do_design
    proj_eeglab_study_define_design(project);
end

if do_study_compute_channels_measures   
    proj_eeglab_study_compute_channels_measures(project, 'recompute', 'on', 'do_erp', '1', 'do_ersp', '1', 'do_erpim', '0', 'do_spec', '1', 'design_num_vec', design_num_vec); ..., 'sel_cell_string', 'CC_01'); ... ,
end

%==================================================================================
% PLOT RESULTS
%==================================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%% erp analysis
% anaylyzes and plots of erp curve for all time points (considering mean of time windows for statistics and graphics)
if do_study_plot_roi_erp_curve_continous
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_erp_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_erp_curve_tw_group_align
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_erp_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_erp_curve_tw_individual_align
    proj_eeglab_study_plot_roi_erp_curve(project, stat_analysis_suffix, project.postprocess.erp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp topographical maps for time windows of the selected design
if do_study_plot_erp_topo_tw
    proj_eeglab_study_plot_erp_topo_tw(project, stat_analysis_suffix, [], 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%% ersp analysis

% analyzes and plots of ersp time frequency distribution for all time-frequency points
if do_study_plot_roi_ersp_tf    
   project.results_display.ersp.display_only_significant_tf_mode='binary';
   proj_eeglab_study_plot_roi_ersp_tf(project, stat_analysis_suffix, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


if do_study_plot_roi_ersp_curve_continous
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.continous, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_ersp_curve_tw_group_noalign
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_ersp_curve_tw_group_align
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_group_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_ersp_curve_tw_individual_noalign
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_noalign, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end

% analyzes and plots of erp curve for time windows of the selected design
if do_study_plot_roi_ersp_curve_tw_individual_align
    proj_eeglab_study_plot_roi_ersp_curve_fb(project, stat_analysis_suffix, project.postprocess.ersp.mode.tw_individual_align, 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


% analyzes and plots of ersp topographical maps for the selected bands in the time windows of the selected design
if do_study_plot_ersp_topo_tw_fb
    proj_eeglab_study_plot_ersp_topo_tw_fb(project, stat_analysis_suffix, [], 'design_num_vec', design_num_vec, 'list_select_subjects', list_select_subjects);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%% export to R
if do_eeglab_study_export_ersp_tf_r
%     vec_sel_design=[2,8,9];
%     sel_designs=[1:3];
    for design_num=1:length(sel_designs)
        sel_des=vec_sel_design(sel_designs(design_num));
        eeglab_study_export_tf_r(project_settings, fullfile(epochs_path, [protocol_name, '.study']), sel_des, export_r_bands, tf_path);
    end
end




%=========================================================================================================
%=========================================================================================================
%=========================================================================================================
%=========================================================================================================
%=========================================================================================================
