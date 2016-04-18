function project = eegtools_project_derive_parameters(project)

%% cla il futuro al futuro

%     % ======================================================================================================
%     % EPOCHING
%     % ======================================================================================================
%     project.epoching.bc_st.ms   = project.epoching.bc_st.s*1000;            % baseline correction start latency
%     project.epoching.bc_end.ms  = project.epoching.bc_end.s*1000;           % baseline correction end latency
%     project.epoching.epo_st.ms  = project.epoching.epo_st.s*1000;             % epochs start latency
%     project.epoching.epo_end.ms = project.epoching.epo_end.s*1000;             % epochs end latency
% 
%     ...project.epoching.baseline_mark.baseline_begin_target_marker_delay.ms = project.epoching.baseline_mark.baseline_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted
% 
%     % ======================================================================================================
%     % POSTPROCESS
%     % ======================================================================================================
%     for fb=1:length(project.ersp.postprocess.frequency_bands)
%         project.ersp.postprocess.frequency_bands_list{fb,1}=[project.ersp.postprocess.frequency_bands(fb).min,project.ersp.postprocess.frequency_bands(fb).max];
%     end
%     project.ersp.postprocess.frequency_bands_names = {project.ersp.postprocess.frequency_bands.name};
% 
%     % ERP
%     project.erp.study_params.tmin_analysis.ms                  = project.erp.study_params.tmin_analysis.s*1000;
%     project.erp.study_params.tmax_analysis.ms                  = project.erp.study_params.tmax_analysis.s*1000;
%     project.erp.study_params.ts_analysis.ms                    = project.erp.study_params.ts_analysis.s*1000;
%     project.erp.study_params.timeout_analysis_interval.ms      = project.erp.study_params.timeout_analysis_interval.s*1000;
% 
%     % ERSP
%     project.ersp.study_params.tmin_analysis.ms                 = project.ersp.study_params.tmin_analysis.s*1000;
%     project.ersp.study_params.tmax_analysis.ms                 = project.ersp.study_params.tmax_analysis.s*1000;
%     project.ersp.study_params.ts_analysis.ms                   = project.ersp.study_params.ts_analysis.s*1000;
%     project.ersp.study_params.timeout_analysis_interval.ms     = project.ersp.study_params.timeout_analysis_interval.s*1000;
% 
%     % ======================================================================================================
%     % RESULTS DISPLAY
%     % ======================================================================================================
%     project.erp.results_display.time_range.ms           = project.erp.results_display.time_range.s*1000;
%     project.ersp.results_display.time_range.ms          = project.ersp.results_display.time_range.s*1000;

%% cla il presente al presente
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% DERIVED TIMES from seconds to milliseconds
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================

% ======================================================================================================
% EPOCHING
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.epoching.bc_st.ms   = project.epoching.bc_st.s*1000;            % baseline correction start latency
project.epoching.bc_end.ms  = project.epoching.bc_end.s*1000;           % baseline correction end latency
project.epoching.epo_st.ms  = project.epoching.epo_st.s*1000;             % epochs start latency
project.epoching.epo_end.ms = project.epoching.epo_end.s*1000;             % epochs end latency

project.epoching.baseline_mark.baseline_begin_target_marker_delay.ms = project.epoching.baseline_mark.baseline_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted

%  ********* /DERIVED DATA *****************************************************************


% ======================================================================================================
% POSTPROCESS
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
for fb=1:length(project.postprocess.ersp.frequency_bands)
    project.postprocess.eeglab.frequency_bands_list{fb,1}=[project.postprocess.ersp.frequency_bands(fb).min,project.postprocess.ersp.frequency_bands(fb).max];
end
project.postprocess.eeglab.frequency_bands_names = {project.postprocess.ersp.frequency_bands.name};%  ********* /DERIVED DATA  *****************************************************************


% ERP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.study.erp.tmin_analysis.ms                  = project.study.erp.tmin_analysis.s*1000;
project.study.erp.tmax_analysis.ms                  = project.study.erp.tmax_analysis.s*1000;
project.study.erp.ts_analysis.ms                    = project.study.erp.ts_analysis.s*1000;
project.study.erp.timeout_analysis_interval.ms      = project.study.erp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ERSP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.study.ersp.tmin_analysis.ms                 = project.study.ersp.tmin_analysis.s*1000;
project.study.ersp.tmax_analysis.ms                 = project.study.ersp.tmax_analysis.s*1000;
project.study.ersp.ts_analysis.ms                   = project.study.ersp.ts_analysis.s*1000;
project.study.ersp.timeout_analysis_interval.ms     = project.study.ersp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ======================================================================================================
% RESULTS DISPLAY
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.results_display.erp.time_range.ms           = project.results_display.erp.time_range.s*1000;
project.results_display.ersp.time_range.ms          = project.results_display.ersp.time_range.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


end