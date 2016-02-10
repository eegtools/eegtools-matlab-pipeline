function project = eegtools_project_derive_parameters(project)

    % ======================================================================================================
    % EPOCHING
    % ======================================================================================================
    project.epoching.bc_st.ms   = project.epoching.bc_st.s*1000;            % baseline correction start latency
    project.epoching.bc_end.ms  = project.epoching.bc_end.s*1000;           % baseline correction end latency
    project.epoching.epo_st.ms  = project.epoching.epo_st.s*1000;             % epochs start latency
    project.epoching.epo_end.ms = project.epoching.epo_end.s*1000;             % epochs end latency

    project.epoching.baseline_mark.baseline_insert_begin_target_marker_delay.ms = project.epoching.baseline_mark.baseline_insert_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted

    % ======================================================================================================
    % POSTPROCESS
    % ======================================================================================================
    for fb=1:length(project.postprocess.ersp.frequency_bands)
        project.postprocess.eeglab.frequency_bands_list{fb,1}=[project.postprocess.ersp.frequency_bands(fb).min,project.postprocess.ersp.frequency_bands(fb).max];
    end
    project.postprocess.eeglab.frequency_bands_names = {project.postprocess.ersp.frequency_bands.name};%  ********* /DERIVED DATA  *****************************************************************

    % ERP
    project.study.erp.tmin_analysis.ms                  = project.study.erp.tmin_analysis.s*1000;
    project.study.erp.tmax_analysis.ms                  = project.study.erp.tmax_analysis.s*1000;
    project.study.erp.ts_analysis.ms                    = project.study.erp.ts_analysis.s*1000;
    project.study.erp.timeout_analysis_interval.ms      = project.study.erp.timeout_analysis_interval.s*1000;

    % ERSP
    project.study.ersp.tmin_analysis.ms                 = project.study.ersp.tmin_analysis.s*1000;
    project.study.ersp.tmax_analysis.ms                 = project.study.ersp.tmax_analysis.s*1000;
    project.study.ersp.ts_analysis.ms                   = project.study.ersp.ts_analysis.s*1000;
    project.study.ersp.timeout_analysis_interval.ms     = project.study.ersp.timeout_analysis_interval.s*1000;

    % ======================================================================================================
    % RESULTS DISPLAY
    % ======================================================================================================
    project.results_display.erp.time_range.ms           = project.results_display.erp.time_range.s*1000;
    project.results_display.ersp.time_range.ms          = project.results_display.ersp.time_range.s*1000;

end