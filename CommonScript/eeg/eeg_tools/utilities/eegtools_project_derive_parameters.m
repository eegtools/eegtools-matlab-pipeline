function project = eegtools_project_derive_parameters(project)

    % ======================================================================================================
    % EPOCHING
    % ======================================================================================================
    project.epoching.bc_st.ms   = project.epoching.bc_st.s*1000;            % baseline correction start latency
    project.epoching.bc_end.ms  = project.epoching.bc_end.s*1000;           % baseline correction end latency
    project.epoching.epo_st.ms  = project.epoching.epo_st.s*1000;             % epochs start latency
    project.epoching.epo_end.ms = project.epoching.epo_end.s*1000;             % epochs end latency

    ...project.epoching.baseline_mark.baseline_begin_target_marker_delay.ms = project.epoching.baseline_mark.baseline_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted

    % ======================================================================================================
    % POSTPROCESS
    % ======================================================================================================
    for fb=1:length(project.postprocess.ersp.frequency_bands)
        project.postprocess.ersp.frequency_bands_list{fb,1}=[project.postprocess.ersp.frequency_bands(fb).min,project.postprocess.ersp.frequency_bands(fb).max];
    end
    project.postprocess.ersp.frequency_bands_names = {project.postprocess.ersp.frequency_bands.name};

    % ERP
    project.erp.study_params.tmin_analysis.ms                  = project.erp.study_params.tmin_analysis.s*1000;
    project.erp.study_params.tmax_analysis.ms                  = project.erp.study_params.tmax_analysis.s*1000;
    project.erp.study_params.ts_analysis.ms                    = project.erp.study_params.ts_analysis.s*1000;
    project.erp.study_params.timeout_analysis_interval.ms      = project.erp.study_params.timeout_analysis_interval.s*1000;

    % ERSP
    project.ersp.study_params.tmin_analysis.ms                 = project.ersp.study_params.tmin_analysis.s*1000;
    project.ersp.study_params.tmax_analysis.ms                 = project.ersp.study_params.tmax_analysis.s*1000;
    project.ersp.study_params.ts_analysis.ms                   = project.ersp.study_params.ts_analysis.s*1000;
    project.ersp.study_params.timeout_analysis_interval.ms     = project.ersp.study_params.timeout_analysis_interval.s*1000;

    % ======================================================================================================
    % RESULTS DISPLAY
    % ======================================================================================================
    project.erp.results_display.time_range.ms           = project.erp.results_display.time_range.s*1000;
    project.ersp.results_display.time_range.ms          = project.ersp.results_display.time_range.s*1000;

end