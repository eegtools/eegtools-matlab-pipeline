% SENSORS DATA PROCESSING
do_sensors_import_averaging                         = 0;
do_sensors_averaging_main_effects                   = 0;
do_sensors_conditions_differences                   = 0;
do_sensors_group_erp_averaging                      = 0;        
do_sensors_common_noise_estimation                  = 0;   ... possible if baseline correction was calculated using all the conditions pre-stimulus
do_sensors_common_data_estimation                   = 0;

% VOLUME CONDUCTOR & SOURCE SPACE
do_bem                                              = 0;
do_check_bem                                        = 0;

% SOURCES CALCULATION
do_sources_calculation                              = 0;
do_sources_tf_calculation                           = 0;
do_sources_scouts_tf_calculation                    = 0;

% SOURCES DIMENSIONALITY REDUCTION & EXPORT
do_sources_unconstrained2flat                       = 0;
do_sources_time_reduction                           = 0;
do_sources_spatial_reduction                        = 0;
do_sources_extract_scouts                           = 0;
do_sources_extract_scouts_oneperiod_values          = 0;
do_sources_export2spm8                              = 0;
do_sources_export2spm8_subjects_peaks               = 0;
do_results_zscore                                   = 0;
     
% GROUP ANALYSIS
do_process_stats_paired_2samples_ttest_old_sources  = 0;
do_process_stats_paired_2samples_ttest_sources      = 0;
do_process_stats_paired_2samples_ttest_ft_sources   = 0;

do_process_stats_baseline_ttest_sources             = 0;            
do_group_analysis_tf                                = 0;
do_group_analysis_scouts_tf                         = 0;

% RESULTS POSTPROCESS & EXPORT
do_group_results_averaging                          = 0;        
do_process_stats_sources                            = 0;            
do_process_stats_scouts_tf                          = 0;            
do_export_scouts_to_file                            = 0;
do_export_scouts_multiple_oneperiod_to_file         = 0;
do_export_scouts_to_file_factors                    = 0;
do_export_scouts_multiple_oneperiod_to_file_factors = 0;