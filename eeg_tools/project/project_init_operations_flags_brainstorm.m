function project = project_init_operations_flags_brainstorm(project)

    % SENSORS DATA PROCESSING
    project.operations.do_sensors_import_averaging                         = 0;
    project.operations.do_sensors_averaging_main_effects                   = 0;
    project.operations.do_sensors_conditions_differences                   = 0;
    project.operations.do_sensors_group_erp_averaging                      = 0;        
    project.operations.do_sensors_common_noise_estimation                  = 0;   ... possible if baseline correction was calculated using all the conditions pre-stimulus
    project.operations.do_sensors_common_data_estimation                   = 0;

    % VOLUME CONDUCTOR & SOURCE SPACE
    project.operations.do_bem                                              = 0;
    project.operations.do_check_bem                                        = 0;

    % SOURCES CALCULATION
    project.operations.do_sources_calculation                              = 0;
    project.operations.do_sources_tf_calculation                           = 0;
    project.operations.do_sources_scouts_tf_calculation                    = 0;

    % SOURCES DIMENSIONALITY REDUCTION & EXPORT
    project.operations.do_sources_unconstrained2flat                       = 0;
    project.operations.do_sources_time_reduction                           = 0;
    project.operations.do_sources_spatial_reduction                        = 0;
    project.operations.do_sources_extract_scouts                           = 0;
    project.operations.do_sources_extract_scouts_oneperiod_values          = 0;
    project.operations.do_sources_export2spm8                              = 0;
    project.operations.do_sources_export2spm8_subjects_peaks               = 0;
    project.operations.do_results_zscore                                   = 0;

    % GROUP ANALYSIS
    project.operations.do_process_stats_paired_2samples_ttest_old_sources  = 0;
    project.operations.do_process_stats_paired_2samples_ttest_sources      = 0;
    project.operations.do_process_stats_paired_2samples_ttest_ft_sources   = 0;

    project.operations.do_process_stats_baseline_ttest_sources             = 0;            
    project.operations.do_group_analysis_tf                                = 0;
    project.operations.do_group_analysis_scouts_tf                         = 0;

    % RESULTS POSTPROCESS & EXPORT
    project.operations.do_group_results_averaging                          = 0;        
    project.operations.do_process_stats_sources                            = 0;            
    project.operations.do_process_stats_scouts_tf                          = 0;            
    project.operations.do_export_scouts_to_file                            = 0;
    project.operations.do_export_scouts_multiple_oneperiod_to_file         = 0;
    project.operations.do_export_scouts_to_file_factors                    = 0;
    project.operations.do_export_scouts_multiple_oneperiod_to_file_factors = 0;
end