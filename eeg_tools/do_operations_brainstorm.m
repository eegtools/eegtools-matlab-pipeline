%==================================================================================
% START BRAINSTORM & select protocol or create if it does not exist
%==================================================================================
if ~brainstorm('status')
    brainstorm nogui
end
if isempty(bst_get('Protocol', project.brainstorm.db_name))
    iProtocol = proj_brainstorm_protocol_create(project);
else
    iProtocol = brainstorm_protocol_open(project.brainstorm.db_name);
end

%  db_reload_database(iProtocol);
chan_eeglab2brainstorm



%==================================================================================
% import EEGLAB epochs into BRAINSTORM and do averaging
if project.operations.do_sensors_import_averaging
    % for each epochs set file (subject and condition) perform: import, averaging, channelset,    
    proj_brainstorm_subject_importepochs_averaging_new(project, 'list_select_subjects', list_select_subjects);    
    db_reload_database(iProtocol);
end
%==================================================================================
% do averaging of main effects...average n-conditions epochs and create a new condition
if project.operations.do_sensors_averaging_main_effects    
    proj_brainstorm_subject_average_conditions_new(project, 'list_select_subjects', list_select_subjects);
end

%==================================================================================
% do aggregate conditions
if project.operations.do_sensors_aggregate_conditions    
            proj_brainstorm_subject_aggregate_conditions_new(project, 'list_select_subjects', list_select_subjects);    
end



%==================================================================================
% create subjects differences between two experimental conditions
if project.operations.do_sensors_conditions_differences    
            proj_brainstorm_conditions_differences_new(project, 'list_select_subjects', list_select_subjects);     
end
%==================================================================================
% create group averages of erp experimental conditions
if project.operations.do_sensors_group_erp_averaging
    proj_brainstorm_group_average_cond_new(project,'list_select_subjects', list_select_subjects);
end
%==================================================================================
% common noise estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
if project.operations.do_sensors_common_noise_estimation   
        proj_brainstorm_subject_noise_estimation_new(project, 'list_select_subjects', list_select_subjects);   
end

% common noise estimation, AGGREGATED CONDITIONS.
if project.operations.do_sensors_common_noise_estimation_factors    
        proj_brainstorm_subject_noise_estimation_factors_new(project, 'list_select_subjects', list_select_subjects);    
end



%==================================================================================
% common data estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
if project.operations.do_sensors_common_data_estimation
        proj_brainstorm_subject_data_estimation_new(project, 'list_select_subjects', list_select_subjects);    
end


%==================================================================================
% common data estimation, AGGREGATED CONDITIONS.
if project.operations.do_sensors_common_data_estimation_factors
        proj_brainstorm_subject_data_estimation_factors_new(project, 'list_select_subjects', list_select_subjects);    
end



%==================================================================================
% BEM calculation over first subject (and first condition) 'model_type'
if project.operations.do_bem
    proj_brainstorm_subject_bem_new(project); % 1: surface, 2: volume
end
%==================================================================================
% check if all subjects have BEM file. if not, copy it from first subject
% to remaining ones. copy to all subjects (assuming all the subjects used the same montage)
if project.operations.do_check_bem
        proj_brainstorm_subject_bem_new(project,'list_select_subjects', list_select_subjects); 

end


%==================================================================================
% backup  BEM file.
if project.operations.do_bck_bem
    proj_brainstorm_subject_backup_bem_new(project); 
end   


%==================================================================================
% recover  BEM file.
if project.operations.do_recover_bem
       proj_brainstorm_subject_recover_bem_new(project); 
end



%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% S O U R C E S   C A L C U L A T I O N
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% sources calculation over full Vertices (usually 15000) surface
if project.operations.do_sources_calculation
    % perform sources processing over subject/condition/data_average.mat
    proj_brainstorm_subject_sources_new(project,'list_select_subjects', list_select_subjects); 
end



% sources calculation over full Vertices (usually 15000) surface AGGREGATED CONDITIONS
if project.operations.do_sources_calculation_factors
    % perform sources processing over subject/condition/data_average.mat
        proj_brainstorm_subject_sources_factors_new(project,'list_select_subjects', list_select_subjects); 

end


%==================================================================================
% sources time-frequency calculation: four freq bands, temporary over-ride
% output : [timefreq_morlet_' source_norm band_desc '_zscore.mat']
if project.operations.do_sources_tf_calculation
    
  proj_brainstorm_subject_sources_tf_calculation_new(project,'list_select_subjects', list_select_subjects)
end
%==================================================================================
% scouts time-frequency calculation: four freq bands, temporary over-ride
% output: [timefreq_morlet_' source_norm band_desc '_69scouts_zscore.mat']
if project.operations.do_sources_scouts_tf_calculation
     proj_brainstorm_subject_sources_scouts_tf_calculation_new(project,'list_select_subjects', list_select_subjects)
end
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% S O U R C E S   D I M E N S I O N A L I T Y   R E D U C T I O N   &   E X P O R T
%================================================================================================================================================================================
%================================================================================================================================================================================
%==================================================================================
%======================================================================================
% zscore sempre fare prima della norma (unconstrained) o conversione in abs
% (constrained)
if project.operations.do_results_zscore
    
    proj_brainstorm_subject_get_from_subjectslist_by_tag_new(project,'list_select_subjects', list_select_subjects)

end
%==================================================================================
% % % % % % % time dimensionality reduction: averaging samples within a number of timewindows
% % % % % % if project.operations.do_sources_time_reduction
% % % % % %     
% % % % % %     sample_length.ms            = 1000/project.eegdata.fs;
% % % % % %     sample_length.s             = 1/project.eegdata.fs;
% % % % % %     
% % % % % %     if isempty(list_windows_names)
% % % % % %         group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
% % % % % %         list_windows_names          = group_time_windows_names{1}; ... {'P100', '', '', ...etc}
% % % % % %     end
% % % % % % 
% % % % % % condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
% % % % % % list_subjects               = list_select_subjects;
% % % % % % 
% % % % % % window_samples_halfwidth    = project.brainstorm.sources.window_samples_halfwidth;
% % % % % % 
% % % % % % %     subj_latencies              = proj_get_erp_peak_info(project, erp_results_file, 'list_subjects', list_subjects, 'condition_names', condition_names, 'list_windows_names', list_windows_names);
% % % % % % subj_latencies              = (round(subj_latencies/sample_length.ms)*sample_length.ms)/1000;
% % % % % % 
% % % % % % window_limits               = cell(1, length(list_windows_names));
% % % % % % 
% % % % % % for t=1:length(project.brainstorm.postprocess.tag_list)
% % % % % %     tag         = project.brainstorm.postprocess.tag_list{t};
% % % % % %     input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'
% % % % % %         
% % % % % % for cond=1:project.epoching.numcond
% % % % % %     cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
% % % % % %     for s=1:length(cond_files)
% % % % % %         for tw=1:length(list_windows_names)
% % % % % %             window_limits{tw}      = [subj_latencies(cond, tw, s) - window_samples_halfwidth*sample_length.s subj_latencies(cond, tw, s) + window_samples_halfwidth*sample_length.s];
% % % % % %         end
% % % % % %         result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
% % % % % %         brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average',      ['_' num2str(window_samples_halfwidth*2+1) time_red_output_postfix_name ]);
% % % % % %         ...brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average_abs',  ['_' num2str(window_samples_halfwidth*2+1) temp_red_output_postfix_name]);
% % % % % %             brainstorm_subject_results_tw_reduction(result_file, window_limits, 'all',          ['_' num2str(window_samples_halfwidth*2+1) time_red_output_postfix_name]);
% % % % % %     end
% % % % % % end
% % % % % % end
% % % % % % end


% time dimensionality reduction: averaging samples within a number of timewindows
if project.operations.do_sources_time_reduction
        proj_brainstorm_subject_tw_reduction_new(project,'list_select_subjects', list_select_subjects)
end


%==================================================================================
% % % % % % % time dimensionality reduction: averaging samples within a number of timewindows


% time dimensionality reduction: averaging samples within a number of timewindows
if project.operations.do_sources_time_reduction_factors
   proj_brainstorm_subject_tw_reduction_factors_new(project,'list_select_subjects', list_select_subjects)
    
end


%==================================================================================
% spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
if project.operations.do_sources_spatial_reduction
    proj_brainstorm_subject_sources_spatial_reduction_new(project,'list_select_subjects', list_select_subjects)
end
%==================================================================================
% spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
% uses : 'process_extract_scout'
if project.operations.do_sources_extract_scouts
    proj_brainstorm_subject_sources_extract_scouts_new(project,'list_select_subjects', list_select_subjects)
end

%==================================================================================
% this version accept a struct array of time windows and averages all the values contained within each struct array element
% it grants just one controlled time value for each struct array element, uses : 'process_extract_values'
if project.operations.do_sources_extract_scouts_oneperiod_values
        proj_brainstorm_subject_sources_scouts_1period_new(project,'list_select_subjects', list_select_subjects)
end

%======================================================================================
% project unconstrained 3oriented sources to a scalar value
if project.operations.do_sources_unconstrained2flat
proj_brainstorm_subject_uncontrained2flat_new(project, 'list_select_subjects', list_select_subjects)    
end


% project unconstrained 3oriented sources to a scalar value
if project.operations.do_sources_unconstrained2flat_factors
   proj_brainstorm_subject_uncontrained2flat_factors_new(project, 'list_select_subjects', list_select_subjects)
end




%==================================================================================
if project.operations.do_sources_export2spm8
    % export sources results over subject/condition
    
    project.brainstorm.postprocess.tag_list={'wmne | fixed | surf', 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
    project.brainstorm.postprocess.tag_list={'wmne | fixed | surf'}; ..., 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
        %name_cond={'cwalker'};project.subjects.list={'alessandra_finisguerra'};time_windows_names_short={{'N200'}};time_windows_sec={{[0.200 0.230]}};time_windows_list={{[200 230]}};
    
    name_cond = project.epoching.condition_names;
    cond_length = length(name_cond);
    
    group_time_windows_list     = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
    subject_time_windows_list   = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');
    group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
    
    
    group_time_windows_list = {}; group_time_windows_names = {};
    group_time_windows_list{1}{1}   = [-0.4 -0.04];
    group_time_windows_names{1}{1}  = 'BL';
    
    sample_length.ms               = 1000/project.eegdata.fs;
    
    for tw=1:length(group_time_windows_list{1})
        group_time_windows_list{1}{tw} = (round(group_time_windows_list{1}{tw}/sample_length.ms)*sample_length.ms)/1000;
    end
    
    spmsources_path = fullfile(project.paths.spmsources, '4mm', project.analysis_name);
    
    for t=1:length(project.brainstorm.postprocess.tag_list)
        tag=project.brainstorm.postprocess.tag_list{t};
        file_tag = strrep(tag, ' | ', '_');
        file_tag = strrep(file_tag, '.', '');
        
        input_file = 'data_average.mat';
        for cond=1:project.epoching.numcond
            cond_files = brainstorm_results_get_from_subjectslist_by_tag('', list_select_subjects, name_cond{cond}, input_file, tag);
            for s=1:length(cond_files)
                for tw=1:length(group_time_windows_list{1})
                    output_tag = [list_select_subjects{s} '_' project.analysis_name '_' name_cond{cond} '_' file_tag '_' group_time_windows_names{1}{tw}];
                    brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, group_time_windows_list{1}{tw},  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200')
                end
            end
        end
        
        for mcond=1:length(name_maineffects)
            cond_files=brainstorm_results_get_from_subjectslist_by_tag('', list_select_subjects, name_maineffects{mcond}, input_file, tag);
            for s=1:length(project.subjects.list)
                for tw=1:length(group_time_windows_list{1})
                    output_tag=[project.subjects.list{s} '_' analysis_name '_' name_maineffects{mcond} '_' file_tag '_' group_time_windows_names{1}{tw}];
                    brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, group_time_windows_list{1}{tw},  output_tag, 'voldownsample', 2); ... 'alessandra_finisguerra_centered_N200')
                end
            end
        end
    end
end
%==================================================================================
if project.operations.do_sources_export2spm8_subjects_peaks
    % export sources results over subject/condition
    
    peak_subfolder  = 'peak_20ms';
    results_file    = '/data/projects/PAP/moving_scrambled_walker/results/OCICA_250c/erp_topo_allconditions-20140714T114521/all-erp_topo_tw-lDorsal-individual_align_20140714T121922/erp_compact.mat';
    
    spmsources_path             = fullfile(project.paths.spmsources, '4mm', project.analysis_name, peak_subfolder, '');
    sample_length.ms            = 1000/project.eegdata.fs;
    group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
    list_windows_names          = group_time_windows_names{1}; ... {'P100'}
        condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    list_subjects               = []; ...{'alessandra_finisguerra', 'alessia','antonio2', 'augusta2', 'claudio2'}; ...project.subjects.list;
        
window_samples_halfwidth        = 3;

subj_latencies  = proj_get_erp_peak_info(project, results_file, 'list_subjects', list_subjects, 'condition_names', condition_names, 'list_windows_names', list_windows_names);
subj_latencies  = (round(subj_latencies/sample_length.ms)*sample_length.ms)/1000;

for t=1:length(project.brainstorm.postprocess.tag_list)
    tag         = project.brainstorm.postprocess.tag_list{t};
    file_tag    = strrep(tag, ' | ', '_');
    file_tag    = strrep(file_tag, '.', '');
    input_file  = 'data_average.mat';
    
    for cond=1:project.epoching.numcond
        cond_files = brainstorm_results_get_from_subjectslist_by_tag('', subjects_list, condition_names{cond}, input_file, tag);
        for s=1:length(cond_files)
            for tw=1:length(list_windows_names)
                output_tag     = [subjects_list{s} '_' project.analysis_name '_' condition_names{cond} '_' file_tag '_' list_windows_names{tw}];
                window_limits  = [subj_latencies(cond, tw, s)-window_samples_halfwidth*sample_length.ms subj_latencies(cond, tw, s)+window_samples_halfwidth*sample_length.ms];
                
                brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, window_limits,  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200'
            end
        end
    end
end
end
%======================================================================================================================================================================================================================================================
%======================================================================================================================================================================================================================================================
%======================================================================================================================================================================================================================================================
%    G R O U P   A N A L Y S I S
%======================================================================================================================================================================================================================================================
%======================================================================================================================================================================================================================================================
%======================================================================================================================================================================================================================================================
%==================================================================================


%% both continuous and tw

% average sources results
if project.operations.do_group_results_averaging        
    proj_brainstorm_group_average_cond_results_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and condition
if project.operations.do_group_results_averaging2
     proj_brainstorm_group_average_cond_results2_new(project, 'list_select_subjects', list_select_subjects)
end




% average sources results based on factor levels
if project.operations.do_group_results_averaging_factors
    proj_brainstorm_group_average_cond_results_factors_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and levels of factors
if project.operations.do_group_results_averaging2_factors
     proj_brainstorm_group_average_cond_results2_factors_new(project, 'list_select_subjects', list_select_subjects)

end



%% only continuous
% average sources results
if project.operations.do_group_results_averaging_continuous        
    proj_brainstorm_group_average_cond_results_cont_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and condition
if project.operations.do_group_results_averaging2_continuous
     proj_brainstorm_group_average_cond_results2_cont_new(project, 'list_select_subjects', list_select_subjects)
end




% average sources results based on factor levels
if project.operations.do_group_results_averaging_factors_continuous
    proj_brainstorm_group_average_cond_results_factors_cont_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and levels of factors
if project.operations.do_group_results_averaging2_factors_continuous
     proj_brainstorm_group_average_cond_results2_factors_cont_new(project, 'list_select_subjects', list_select_subjects)

end

%% only tw
% average sources results
if project.operations.do_group_results_averaging_tw        
    proj_brainstorm_group_average_cond_results_tw_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and condition
if project.operations.do_group_results_averaging2_tw
     proj_brainstorm_group_average_cond_results2_tw_new(project, 'list_select_subjects', list_select_subjects)
end




% average sources results based on factor levels
if project.operations.do_group_results_averaging_factors_tw
    proj_brainstorm_group_average_cond_results_factors_tw_new(project, 'list_select_subjects', list_select_subjects)   
end



% average sources results by group and levels of factors
if project.operations.do_group_results_averaging2_factors_tw
     proj_brainstorm_group_average_cond_results2_factors_tw_new(project, 'list_select_subjects', list_select_subjects)
end









% STATS
%==================================================================================
%==================================================================================

% %  2samples ttest NEW pairwise comparison by group and by condition
if project.operations.do_brainstorm_group_stats_cond_group_ttest    
    proj_brainstorm_group_stats_cond_group_ttest_new(project,'list_select_subjects',list_select_subjects,'vec_select_groups',vec_select_groups)    
end


% paired 2samples ttest process_ft_sourcestatistics DRAFT!
results=cell(1,tot_num_contrasts);
if project.operations.do_process_stats_paired_2samples_ttest_ft_sources
    for pwc=1:length(pairwise_comparisons)
        results{pwc} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, ...
            pairwise_comparisons{pwc}{1}, ...
            pairwise_comparisons{pwc}{2}, ...
            group_comparison_data_type, ...
            group_comparison_analysis_type, ...
            list_select_subjects, ...
            'comment', group_comparison_comment , 'abs_type', group_comparison_abs_type, 'timewindow', group_comparison_interval, ...
            'randomizations', group_comparison_perm, 'correctiontype', group_comparison_corr , 'pvalue', group_comparison_pvalue ...
            );
    end
end
%==================================================================================
% % baseline ttest
% results=cell(1,tot_num_contrasts);
% if project.operations.do_process_stats_baseline_ttest_sources
%     for bc=1:length(baseline_comparisons)                ...protocol_name, cond,  analysis_type, prestim, poststim, avg_func, subjects_list, varargin
%             results{bc} = brainstorm_group_stats_baseline_ttest(project.brainstorm.db_name, ...
%             baseline_comparisons{bc}, ...
%             group_comparison_analysis_type, ...
%             baseline, poststim, 2 , ...
%             list_select_subjects, ...
%             'comment', group_comparison_comment ...
%             );
%     end
% end


% baseline ttest for each condition and group
if project.operations.do_process_stats_baseline_ttest_sources
    results = proj_brainstorm_group_stats_baseline_ttest_new(project, 'list_select_subjects', list_select_subjects);
end


%==================================================================================
% TF all sources
results_scouts_tf=cell(1,tot_num_contrasts);
if project.operations.do_group_analysis_tf
    file_input='timefreq_morlet_wmne_s3000_teta_mu_beta1_beta2_zscore';
    for pwc=1:length(pairwise_comparisons)
        results{pwc} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, pairwise_comparisons{pwc}{1}, pairwise_comparisons{pwc}{2}, group_comparison_analysis_type, 1, project.subjects.list);
    end
end
%==================================================================================
% TF 69 scouts
results_scouts_tf=cell(1,tot_num_contrasts);
if project.operations.do_group_analysis_scouts_tf
    file_input='timefreq_morlet_wmne_teta_mu_beta1_beta2_69scouts_zscore';
    results_scouts_tf{1} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','cscrambled', file_input ,1,project.subjects.list);
end
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% PARSE & EXPORT RESULTS
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================

%================================================================================================================================================================================
% parse sources results
if project.operations.do_process_stats_sources
    all_group_results   = bst_get('Study', -2); ... bst_get('Study', '@inter/brainstormstudy.mat');
        num_stats           = length(all_group_results.Stat);
    for res=1:num_stats
        filename         = all_group_results.Stat(res).FileName;
        if strfind(filename, process_result_string)
            disp(['@@@@@@@@@@@@@@@@' filename]);
            brainstorm_process_stats_sources(project.brainstorm.db_name, filename, StatThreshOptions);
        end
    end
end



% parse sources results
if project.operations.do_process_stats_sources2
    all_group_results   = bst_get('Study', -2); ... bst_get('Study', '@inter/brainstormstudy.mat');
        num_stats           = length(all_group_results.Stat);
    for res=1:num_stats
        filename         = all_group_results.Stat(res).FileName;
        if strfind(filename, process_result_string)
            disp(['@@@@@@@@@@@@@@@@' filename]);
            brainstorm_process_stats_sources2(project.brainstorm.db_name, filename, StatThreshOptions);
        end
    end
end


%==================================================================================
% parse scouts TF results
if project.operations.do_process_stats_scouts_tf
    process_result_string='130614';
    all_group_results = bst_get('Study', -2); ... bst_get('Study', '@inter/brainstormstudy.mat');
        num_stats=length(all_group_results.Stat);
    for res=1:num_stats
        filename=all_group_results.Stat(res).FileName;
        if findstr(filename, process_result_string)
            disp(['@@@@@@@@@@@@@@@@' filename]);
            brainstorm_process_stats_scout_time_freq(project.brainstorm.db_name, filename, StatThreshOptions, [-400:4:350]);
        end
    end
end
%==================================================================================
if project.operations.do_export_scouts_to_file
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    list_subjects               = project.subjects.list;
    
    brainstorm_subject_scouts_export(project.brainstorm.db_name, list_subjects, condition_names, export_scout_name);
end
%==================================================================================
if project.operations.do_export_scouts_multiple_oneperiod_to_file
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    list_subjects               = project.subjects.list;
    
    for per=1:length(project.brainstorm.postprocess.group_time_windows)
        final_export_scout_name_inputfile = [export_scout_name_inputfile '_' project.brainstorm.postprocess.group_time_windows(per).name];
        
        brainstorm_subject_scouts_export(project.brainstorm.db_name, list_subjects, condition_names, final_export_scout_name_inputfile, ...
            'append', 1, 'output_file_name', ['scout_export_' export_scout_name_outputfile '.dat'], ...
            'period_labels', {project.brainstorm.postprocess.group_time_windows(per).name}, ...
            'subjects_data', project.subjects.conditions_behavioral_data);
    end
end
%==================================================================================
if project.operations.do_export_scouts_to_file_factors
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    associated_factors          = project.study.associated_factors;
    list_subjects               = project.subjects.list;
    
    brainstorm_subject_scouts_export_2factors(project.brainstorm.db_name, list_subjects, condition_names, associated_factors, factors_names, final_export_scout_name_inputfile);
end
%================================================================================================================================================================================
if project.operations.do_export_scouts_multiple_oneperiod_to_file_factors
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    associated_factors          = project.study.associated_factors;
    list_subjects               = project.subjects.list;
    
    for per=1:length(project.brainstorm.postprocess.group_time_windows)
        final_export_scout_name_inputfile = [export_scout_name_inputfile '_' project.brainstorm.postprocess.group_time_windows(per).name];
        brainstorm_subject_scouts_export_2factors(project.brainstorm.db_name, list_subjects, condition_names, associated_factors, factors_names, final_export_scout_name_inputfile, ...
            'append', 1, 'output_file_name', ['scout_export_' export_scout_name_outputfile '.dat'], ...
            'period_labels', {project.brainstorm.postprocess.group_time_windows(per).name}, ...
            'subjects_data', project.subjects.conditions_behavioral_data);
    end
end
%==================================================================================


    db_reload_database(iProtocol);
