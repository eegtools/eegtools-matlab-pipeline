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
%==================================================================================
% import EEGLAB epochs into BRAINSTORM and do averaging
if do_sensors_import_averaging
    % for each epochs set file (subject and condition) perform: import, averaging, channelset, 
    for subj=1:project.subjects.numsubj 
        subj_name = project.subjects.list{subj};    
        proj_brainstorm_subject_importepochs_averaging(project, subj_name);
    end
    db_reload_database(iProtocol);
end
%==================================================================================
% do averaging of main effects...average n-conditions epochs and create a new condition
if do_sensors_averaging_main_effects
    for subj=1:project.subjects.numsubj 
        subj_name = project.subjects.list{subj};  
        for f=1:length(project.study.factors)
            proj_brainstorm_subject_average_conditions(project, subj_name, project.study.factors(f).level, project.study.factors(f).file_match{:});
        end
    end
end    
%==================================================================================
% create subjects differences between two experimental conditions
if do_sensors_conditions_differences
    for subj=1:project.subjects.numsubj 
        subj_name = project.subjects.list{subj};     
        for pwc=1:length(pairwise_comparisons)
            brainstorm_conditions_differences(project, subj_name, pairwise_comparisons{pwc}{1}, pairwise_comparisons{pwc}{2});
        end
    end
end
%==================================================================================
% create group averages of erp experimental conditions
if do_sensors_group_erp_averaging
    proj_brainstorm_group_average_cond(project);
end
%==================================================================================
% common noise estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
if do_sensors_common_noise_estimation
    for subj=1:project.subjects.numsubj 
        subj_name=project.subjects.list{subj};  
        proj_brainstorm_subject_noise_estimation(project, subj_name);
    end    
end
%==================================================================================
% common data estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
if do_sensors_common_data_estimation
    for subj=1:project.subjects.numsubj 
        subj_name=project.subjects.list{subj};  
        proj_brainstorm_subject_data_estimation(project, subj_name);
    end    
end
%==================================================================================
% BEM calculation over first subject (and first condition) and copy to all subjects (assuming all the subjects used the same montage)
if do_bem
    ProtocolSubjects    = bst_get('ProtocolSubjects');
    subj1_name          = ProtocolSubjects.Subject(1).Name;
    
    proj_brainstorm_subject_bem(project, subj1_name,'model_type', project.brainstorm.conductorvolume.type); % 1: surface, 2: volume
end
%==================================================================================
% check if all subjects have BEM file. if not, copy it from first subject to remaining ones
if do_check_bem
    ProtocolSubjects    = bst_get('ProtocolSubjects');
    subj1_name          = ProtocolSubjects.Subject(1).Name;
    src_file            = fullfile(project.paths.brainstorm_data, subj1_name,'@default_study', project.brainstorm.conductorvolume.bem_file_name);

    for subj=2:project.subjects.numsubj
        dest_file = fullfile(project.paths.brainstorm_data, project.subjects.list{subj},'@default_study', project.brainstorm.conductorvolume.bem_file_name);
        if ~file_exist(dest_file)
            copyfile(src_file, dest_file);
        end
    end
    db_reload_database(iProtocol);
end
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% S O U R C E S   C A L C U L A T I O N 
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% sources calculation over full Vertices (usually 15000) surface
if do_sources_calculation
    % perform sources processing over subject/condition/data_average.mat
    sources_results = cell(project.subjects.numsubj, tot_num_contrasts);
    
    for subj=1:project.subjects.numsubj 
        % 4 conditions
        for cond=1:project.epoching.numcond
            cond_name                       = project.epoching.condition_names{cond};
            for sources_params=1:length(do_sources_params)
                sources_results{subj, cond}     = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], do_sources_params{sources_params}{:});
            end
        end
    end
end
%==================================================================================
% sources time-frequency calculation: four freq bands, temporary over-ride
% output : [timefreq_morlet_' source_norm band_desc '_zscore.mat']
if do_sources_tf_calculation
    
    sources_norm=[sources_norm '_s3000'];    
        
    if ~do_sources
        % reconstruct output source relative paths.
        src_name=['results_' sources_norm];
        if (strcmp(source_orient, 'loose'))
            dest_name=[src_name '_loose'];
        end 
        sources_results=cell(project.subjects.numsubj, tot_num_contrasts);
        for subj=1:project.subjects.numsubj 
            for cond=1:length(name_cond)
                sources_tf_results{subj,cond} = fullfile(project.subjects.list{subj}, name_cond{cond}, [src_name '.mat']);
            end
            for mcond=1:length(name_maineffects)
                totcond=mcond+length(name_cond);
                sources_tf_results{subj,totcond} = fullfile(project.subjects.list{subj}, name_maineffects{mcond}, [src_name '.mat']);
            end
        end
    end
end
%==================================================================================
% scouts time-frequency calculation: four freq bands, temporary over-ride
% output: [timefreq_morlet_' source_norm band_desc '_69scouts_zscore.mat']
if do_sources_scouts_tf_calculation
    name_cond={'cwalker','cscrambled'};
    name_maineffects={};
    % sources_norm=[sources_norm '_s500'];

    if ~do_sources
        % reconstruct output source relative paths.
        src_name=['results_' sources_norm];
        if (strcmp(source_orient, 'loose'))
            dest_name=[src_name '_loose'];
        end 
        sources_results=cell(project.subjects.numsubj,tot_num_contrasts);
        for subj=1:project.subjects.numsubj 
            for cond=1:project.epoching.numcond
                sources_results{subj,cond} = fullfile(project.subjects.list{subj}, name_cond{cond}, [src_name '.mat']);
            end
            for mcond=1:length(name_maineffects)
                totcond = mcond + project.epoching.numcond;
                sources_results{subj,totcond} = fullfile(project.subjects.list{subj}, name_maineffects{mcond}, [src_name '.mat']);
            end
        end
    end
end
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
% S O U R C E S   D I M E N S I O N A L I T Y   R E D U C T I O N   &   E X P O R T
%================================================================================================================================================================================
%================================================================================================================================================================================
%==================================================================================
% project unconstrained 3oriented sources to a scalar value
if do_sources_unconstrained2flat
    list_subjects               = project.subjects.list;
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);    
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
        
        for cond=1:project.epoching.numcond
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_result_uncontrained2flat(project.brainstorm.db_name, result_file, source_flatting_method);
           end
        end
   end
end
%==================================================================================
% time dimensionality reduction: averaging samples within a number of timewindows
if do_sources_time_reduction

    sample_length.ms            = 1000/project.eegdata.fs;
    sample_length.s             = 1/project.eegdata.fs;
    
    if isempty(list_windows_names)
        group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
        list_windows_names          = group_time_windows_names{1}; ... {'P100', '', '', ...etc}
    end

    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    list_subjects               = project.subjects.list;
    
    window_samples_halfwidth    = project.brainstorm.sources.window_samples_halfwidth;
    
    subj_latencies              = proj_get_erp_peak_info(project, erp_results_file, 'list_subjects', list_subjects, 'condition_names', condition_names, 'list_windows_names', list_windows_names);
    subj_latencies              = (round(subj_latencies/sample_length.ms)*sample_length.ms)/1000;

    window_limits               = cell(1, length(list_windows_names));

    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'
        
        for cond=1:project.epoching.numcond
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                for tw=1:length(list_windows_names)
                     window_limits{tw}      = [subj_latencies(cond, tw, s) - window_samples_halfwidth*sample_length.s subj_latencies(cond, tw, s) + window_samples_halfwidth*sample_length.s];
                end               
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average',      ['_' num2str(window_samples_halfwidth*2+1) time_red_output_postfix_name ]);
                ...brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average_abs',  ['_' num2str(window_samples_halfwidth*2+1) temp_red_output_postfix_name]);
                brainstorm_subject_results_tw_reduction(result_file, window_limits, 'all',          ['_' num2str(window_samples_halfwidth*2+1) time_red_output_postfix_name]);
           end
        end
    end
end
%==================================================================================
% spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
if do_sources_spatial_reduction
    list_subjects               = project.subjects.list;
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);    
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
        
        for cond=1:project.epoching.numcond
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_results_downsample(project.brainstorm.db_name, result_file, downsample_atlasname);
           end
        end
   end
end
%==================================================================================
% spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
% uses : 'process_extract_scout'
if do_sources_extract_scouts
    list_subjects               = project.subjects.list;
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
        
        for cond=1:cond_length
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_result_extract_scouts(project.brainstorm.db_name, result_file, scouts_name, scout_time_limits);
           end
        end
    end
end
%==================================================================================
% this version accept one time windows and averages all the values contained
% it grants just one controlled time value, uses : 'process_extract_values'
if do_sources_extract_scouts_oneperiod_values
    list_subjects               = project.subjects.list;
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
        
        for cond=1:cond_length
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_result_extract_scouts_oneperiod_values(project.brainstorm.db_name, result_file, scouts_name, scout_time_limits);
           end
        end
    end
end
%======================================================================================
% zscore normalization on sources results-300.8
if do_results_zscore
    
    list_subjects               = project.subjects.list;
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
        input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
        
        for cond=1:cond_length
           cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
           for s=1:length(cond_files)
                result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                brainstorm_result_zscore(project.brainstorm.db_name, result_file, baseline, 'source_abs', group_comparison_abs_type);
           end
        end
    end    
end
%==================================================================================
if do_sources_export2spm8
    % export sources results over subject/condition

    postprocess_sources_tag_list={'wmne | fixed | surf', 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
    postprocess_sources_tag_list={'wmne | fixed | surf'}; ..., 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
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
    
    for t=1:length(postprocess_sources_tag_list)
        tag=postprocess_sources_tag_list{t};
        file_tag = strrep(tag, ' | ', '_');
        file_tag = strrep(file_tag, '.', '');
        
        input_file = 'data_average.mat';
        for cond=1:project.epoching.numcond
           cond_files = brainstorm_results_get_from_subjectslist_by_tag('', project.subjects.list, name_cond{cond}, input_file, tag);
           for s=1:length(cond_files)
                for tw=1:length(group_time_windows_list{1})
                     output_tag = [project.subjects.list{s} '_' project.analysis_name '_' name_cond{cond} '_' file_tag '_' group_time_windows_names{1}{tw}];
                     brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, group_time_windows_list{1}{tw},  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200')
                end
           end
        end

        for mcond=1:length(name_maineffects)
            cond_files=brainstorm_results_get_from_subjectslist_by_tag('', project.subjects.list, name_maineffects{mcond}, input_file, tag);
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
if do_sources_export2spm8_subjects_peaks
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
    
    for t=1:length(postprocess_sources_tag_list)
        tag         = postprocess_sources_tag_list{t};
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
% STATS
%==================================================================================
%==================================================================================
% paired 2samples ttest DEPRECATED
results=cell(1,tot_num_contrasts);
if do_process_stats_paired_2samples_ttest_old_sources
    for pwc=1:length(pairwise_comparisons)
        results{pwc} = brainstorm_group_stats_2cond_pairedttest_deprecated(project.brainstorm.db_name, ...
                                                                pairwise_comparisons{pwc}{1}, ...
                                                                pairwise_comparisons{pwc}{2}, ...
                                                                group_comparison_data_type, ...
                                                                group_comparison_analysis_type, ...
                                                                group_pairedtest_abs_type, ...
                                                                project.subjects.list, ...
                                                                'comment', group_comparison_comment , 'abs_type', group_comparison_abs_type ...
                                                                );
    end
end

% paired 2samples ttest NEW
results=cell(1,tot_num_contrasts);
if do_process_stats_paired_2samples_ttest_sources
    for pwc=1:length(pairwise_comparisons)
        results{pwc} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, ...
                                                                pairwise_comparisons{pwc}{1}, ...
                                                                pairwise_comparisons{pwc}{2}, ...
                                                                group_comparison_data_type, ...
                                                                group_comparison_analysis_type, ...
                                                                project.subjects.list, ...
                                                                'comment', group_comparison_comment , 'abs_type', group_comparison_abs_type, 'timewindow', group_comparison_interval ...
                                                                );
    end
end

% paired 2samples ttest process_ft_sourcestatistics
results=cell(1,tot_num_contrasts);
if do_process_stats_paired_2samples_ttest_ft_sources
    for pwc=1:length(pairwise_comparisons)
        results{pwc} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, ...
                                                                pairwise_comparisons{pwc}{1}, ...
                                                                pairwise_comparisons{pwc}{2}, ...
                                                                group_comparison_data_type, ...
                                                                group_comparison_analysis_type, ...
                                                                project.subjects.list, ...
                                                                'comment', group_comparison_comment , 'abs_type', group_comparison_abs_type, 'timewindow', group_comparison_interval, ...
                                                                'randomizations', group_comparison_perm, 'correctiontype', group_comparison_corr , 'pvalue', group_comparison_pvalue ...
                                                                );
    end
end
%==================================================================================
% baseline ttest
results=cell(1,tot_num_contrasts);
if do_process_stats_baseline_ttest_sources
    for bc=1:length(baseline_comparisons)                ...protocol_name, cond,  analysis_type, prestim, poststim, avg_func, subjects_list, varargin
        results{bc} = brainstorm_group_stats_baseline_ttest(project.brainstorm.db_name, ...
                                                            baseline_comparisons{bc}, ...
                                                            group_comparison_analysis_type, ...
                                                            baseline, poststim, 2 , ... 
                                                            project.subjects.list, ...
                                                            'comment', group_comparison_comment ...
                                                            );
    end
end
%==================================================================================
% TF all sources
results_scouts_tf=cell(1,tot_num_contrasts);
if do_group_analysis_tf
    file_input='timefreq_morlet_wmne_s3000_teta_mu_beta1_beta2_zscore';
    for pwc=1:length(pairwise_comparisons)
     results{pwc} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, pairwise_comparisons{pwc}{1}, pairwise_comparisons{pwc}{2}, group_comparison_analysis_type, 1, project.subjects.list);
    end    
end
%==================================================================================
% TF 69 scouts
results_scouts_tf=cell(1,tot_num_contrasts);
if do_group_analysis_scouts_tf
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
% average sources results
if do_group_results_averaging
    brainstorm_group_average_cond_results(project.brainstorm.db_name, project.subjects.list, project.epoching.condition_names, group_comparison_analysis_type); 
end
%================================================================================================================================================================================
% parse sources results
if do_process_stats_sources
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
%==================================================================================
% parse scouts TF results
if do_process_stats_scouts_tf
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
if do_export_scouts_to_file
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    list_subjects               = project.subjects.list;    
    brainstorm_subject_scouts_export(project.brainstorm.db_name, list_subjects, condition_names, export_scout_name);
end
%==================================================================================
if do_export_scouts_to_file_factors
    condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
    associated_factors          = project.study.associated_factors;
    list_subjects               = project.subjects.list;    
    brainstorm_subject_scouts_export_2factors(project.brainstorm.db_name, list_subjects, condition_names, associated_factors, factors_names, export_scout_name);
end
%================================================================================================================================================================================

%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================
%================================================================================================================================================================================





% %==================================================================================
% % START BRAINSTORM & select protocol or create if it does not exist
% %==================================================================================
% if ~brainstorm('status')
%     brainstorm nogui
% end
% if isempty(bst_get('Protocol', project.brainstorm.db_name)) 
%     iProtocol = proj_brainstorm_protocol_create(project);
% else
%     iProtocol = brainstorm_protocol_open(project.brainstorm.db_name);
% end
% %==================================================================================
% % import EEGLAB epochs into BRAINSTORM and do averaging
% if do_brainstorm_import_averaging
%     % for each epochs set file (subject and condition) perform: import, averaging, channelset, 
%     for subj=1:project.subjects.numsubj 
%         subj_name=project.subjects.list{subj};    
%         proj_brainstorm_subject_importepochs_averaging(project, subj_name);
%     end
%     db_reload_database(iProtocol);
% end
% %==================================================================================
% % do averaging of main effects...average n-conditions epochs and create a new condition
% if do_brainstorm_averaging_main_effects
%     for subj=1:project.subjects.numsubj 
%         subj_name=project.subjects.list{subj};  
%         proj_brainstorm_subject_average_conditions(project, subj_name, 'walker', 'cwalker','twalker');
%         proj_brainstorm_subject_average_conditions(project, subj_name, 'scrambled', 'cscrambled','tscrambled');
%         proj_brainstorm_subject_average_conditions(project, subj_name, 'centered', 'cwalker','cscrambled');
%         proj_brainstorm_subject_average_conditions(project, subj_name, 'translating', 'twalker','tscrambled');
%     end
% end    
% %==================================================================================
% % common noise estimation, calculated with the 4 basic conditions recordings and then copied to the other ones (main effects).
% if do_common_noise_estimation
%     for subj=1:project.subjects.numsubj 
%         subj_name=project.subjects.list{subj};  
%         proj_brainstorm_subject_noise_estimation(project, subj_name);
%     end    
% end
% %==================================================================================
% % BEM calculation over first subject (and first condition) and copy to all subjects
% if do_bem
%     ProtocolSubjects    = bst_get('ProtocolSubjects');
%     subj1_name          = ProtocolSubjects.Subject(1).Name;
%     
%     proj_brainstorm_subject_bem(project, subj1_name,'model_type', project.brainstorm.conductorvolume.type); % 1: surface, 2: volume
% end
% %==================================================================================
% % check if all subjects have BEM file. if not, copy it from first subject to remaining ones
% if do_check_bem
%     ProtocolSubjects    = bst_get('ProtocolSubjects');
%     subj1_name          = ProtocolSubjects.Subject(1).Name;
%     src_file            = fullfile(project.paths.brainstorm_data, subj1_name,'@default_study', project.brainstorm.conductorvolume.bem_file_name);
% 
%     for subj=2:project.subjects.numsubj
%         dest_file = fullfile(project.paths.brainstorm_data, project.subjects.list{subj},'@default_study', project.brainstorm.conductorvolume.bem_file_name);
%         if ~file_exist(dest_file)
%             copyfile(src_file, dest_file);
%         end
%     end
%     db_reload_database(iProtocol);
% end
% %==================================================================================
% % sources calculation over full Vertices (15000) surface
% if do_sources
%     % perform sources processing over subject/condition/data_average.mat
%     sources_results = cell(project.subjects.numsubj, tot_num_contrasts);
%     
%     for subj=1:project.subjects.numsubj 
%         % 4 conditions
%         for cond=1:project.epoching.numcond
%             cond_name = project.epoching.condition_names{cond};
%             
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',     'orient',    'free', 'tag', 'vol', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name);
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',     'orient',   'fixed', 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',     'loose',        0.2, 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',  'orient',    'free', 'tag', 'vol', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name);
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',  'orient',   'fixed', 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, cond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',  'loose',        0.2, 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%         end
%         % main effects
%         for mcond=1:length(name_maineffects)
%             totcond     = mcond + project.epoching.numcond;
%             cond_name   = name_maineffects{mcond};
%             
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',      'orient',    'free', 'tag', 'vol', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name);
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',      'orient',   'fixed', 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'wmne',      'loose',        0.2, 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',   'orient',    'free', 'tag', 'vol', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name);
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',   'orient',   'fixed', 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%             ...sources_results{subj, totcond} = brainstorm_subject_sources(project.brainstorm.db_name, project.subjects.list{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], 'norm', 'sloreta',   'loose',        0.2, 'tag', 'surf', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name);
%         end        
%     end
% end
% %==================================================================================
% % time dimensionality reduction: averaging samples within a number of timewindows
% if do_time_reduction
% 
%     postprocess_sources_tag_list        = {'wmne | fixed | surf'}; ..., 'sloreta | fixed | surf'};
%     results_file    = '/data/projects/PAP/moving_scrambled_walker/results/OCICA_250c/erp_topo_allconditions-20140724T154935/all-erp_topo_tw-individual_align_20140724T154944/erp_compact.mat';
%     
%     sample_length.ms            = 1000/project.eegdata.fs;
%     sample_length.s             = 1/project.eegdata.fs;
%     group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
%     list_windows_names          = group_time_windows_names{1}; ... {'P100', '', '', ...etc}
%     condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
%     list_subjects               = project.subjects.list;  ...{'alessandra_finisguerra', 'alessia','antonio2', 'augusta2', 'claudio2'}; ...project.subjects.list;
%     
%     window_samples_halfwidth    = 4;
%     
%     subj_latencies              = proj_get_erp_peak_info(project, results_file, 'list_subjects', list_subjects, 'condition_names', condition_names, 'list_windows_names', list_windows_names);
%     subj_latencies              = (round(subj_latencies/sample_length.ms)*sample_length.ms)/1000;
% 
%     window_limits               = cell(1, length(list_windows_names));
% 
%     
%     for t=1:length(postprocess_sources_tag_list)
%         tag         = postprocess_sources_tag_list{t};
%         file_tag    = strrep(tag, ' | ', '_');
%         file_tag    = strrep(file_tag, '.', '');
%         input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'
%         
%         for cond=1:project.epoching.numcond
%            cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
%            for s=1:length(cond_files)
%                 for tw=1:length(list_windows_names)
%                      window_limits{tw}      = [subj_latencies(cond, tw, s)-window_samples_halfwidth*sample_length.s subj_latencies(cond, tw, s)+window_samples_halfwidth*sample_length.s];
%                 end               
%                 result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
%                 brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average', ['_' num2str(window_samples_halfwidth*2+1) '_samples']);
%                 brainstorm_subject_results_tw_reduction(result_file, window_limits, 'all', ['_' num2str(window_samples_halfwidth*2+1) '_samples']);
%            end
%         end
% 
%         for mcond=1:length(name_maineffects)
%            cond_files=brainstorm_results_get_from_subjectslist_by_tag(list_subjects, name_maineffects{mcond}, input_file, tag);
%            for s=1:length(cond_files)
%                 for tw=1:length(list_windows_names)
%                      window_limits{tw}      = [subj_latencies(cond, tw, s)-window_samples_halfwidth*sample_length.s subj_latencies(cond, tw, s)+window_samples_halfwidth*sample_length.s];
%                 end               
%                 result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
%                 brainstorm_subject_results_tw_reduction(result_file, window_limits, 'average', ['_' num2str(window_samples_halfwidth*2+1) '_samples']);
%                 brainstorm_subject_results_tw_reduction(result_file, window_limits, 'all', ['_' num2str(window_samples_halfwidth*2+1) '_samples']);
%            end
%         end
%     end
%  
% end
% %==================================================================================
% % spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
% if do_spatial_reduction
%     
%     postprocess_sources_tag_list        = {'wmne | fixed | surf'}; ..., 'sloreta | fixed | surf'};
%     
%     for t=1:length(postprocess_sources_tag_list)
%         tag         = postprocess_sources_tag_list{t};
%         file_tag    = strrep(tag, ' | ', '_');
%         file_tag    = strrep(file_tag, '.', '');
%         input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'        
%         
%         for cond=1:project.epoching.numcond
%            cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, condition_names{cond}, input_file, tag);
%            for s=1:length(cond_files)
%                 result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
%                 brainstorm_results_downsample(project.brainstorm.db_name, result_file, downsample_atlasname);
%            end
%         end
% 
%         for mcond=1:length(name_maineffects)
%            cond_files=brainstorm_results_get_from_subjectslist_by_tag(list_subjects, name_maineffects{mcond}, input_file, tag);
%            for s=1:length(cond_files)
%                 result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
%                 brainstorm_results_downsample(project.brainstorm.db_name, result_file, downsample_atlasname);
%            end
%         end
%     end
%     
% %     if ~do_sources
% %         % reconstruct output source relative paths.
% %         src_name=['results_' sources_norm];
% %         if (strcmp(source_orient, 'loose'))
% %             dest_name=[src_name '_loose'];
% %         end 
% %         sources_results = cell(project.subjects.numsubj, tot_num_contrasts);
% %         for subj=1:project.subjects.numsubj 
% %             for cond=1:project.epoching.numcond
% %                 sources_results{subj,cond}      = fullfile(project.subjects.list{subj}, project.epoching.condition_names{cond}, [src_name '.mat']);
% %             end
% %             for mcond=1:length(name_maineffects)
% %                 totcond                         = mcond + length(name_cond);
% %                 sources_results{subj,totcond}   = fullfile(project.subjects.list{subj}, name_maineffects{mcond}, [src_name '.mat']);
% %             end
% %         end
% %     end
% %     
% %     % call brainstorm_downsample_result
% %     for subj=1:project.subjects.numsubj 
% %         % 4 basic conditions
% %         for cond=1:project.epoching.numcond
% %             brainstorm_results_downsample(project.brainstorm.db_name, sources_results{subj,cond}, downsample_atlasname);
% %         end
% %         % main effects
% %         for mcond=1:length(name_maineffects)
% %             totcond = mcond + length(name_cond);
% %             brainstorm_results_downsample(project.brainstorm.db_name, sources_results{subj,totcond}, downsample_atlasname);
% %         end        
% %     end    
% end
% %==================================================================================
% % sources time-frequency calculation: four freq bands, temporary over-ride
% % output : [timefreq_morlet_' source_norm band_desc '_zscore.mat']
% if do_sources_tf
%     
%     sources_norm=[sources_norm '_s3000'];    
%         
%     if ~do_sources
%         % reconstruct output source relative paths.
%         src_name=['results_' sources_norm];
%         if (strcmp(source_orient, 'loose'))
%             dest_name=[src_name '_loose'];
%         end 
%         sources_results=cell(project.subjects.numsubj, tot_num_contrasts);
%         for subj=1:project.subjects.numsubj 
%             for cond=1:length(name_cond)
%                 sources_tf_results{subj,cond} = fullfile(project.subjects.list{subj}, name_cond{cond}, [src_name '.mat']);
%             end
%             for mcond=1:length(name_maineffects)
%                 totcond=mcond+length(name_cond);
%                 sources_tf_results{subj,totcond} = fullfile(project.subjects.list{subj}, name_maineffects{mcond}, [src_name '.mat']);
%             end
%         end
%     end
%     
%     % call brainstorm_sources_tf
%     for subj=1:project.subjects.numsubj 
%         % 4 basic conditions
%         for cond=1:project.epoching.numcond
%             brainstorm_subject_sources_tf_timewnd_freqbands(project.brainstorm.db_name, sources_tf_results{subj,cond},brainstorm_analysis_times, brainstorm_analysis_bands, zscore_overwriting, project_settings);
%         end
%         % main effects
%         for mcond=1:length(name_maineffects)
%             totcond = mcond + project.epoching.numcond;
%             brainstorm_subject_sources_tf_timewnd_freqbands(project.brainstorm.db_name, sources_tf_results{subj,totcond},brainstorm_analysis_times, brainstorm_analysis_bands, zscore_overwriting, project_settings);
%         end        
%     end    
% end
% %==================================================================================
% % scouts time-frequency calculation: four freq bands, temporary over-ride
% % output: [timefreq_morlet_' source_norm band_desc '_69scouts_zscore.mat']
% if do_sources_scouts_tf
%     name_cond={'cwalker','cscrambled'};
%     name_maineffects={};
%     % sources_norm=[sources_norm '_s500'];
% 
%     if ~do_sources
%         % reconstruct output source relative paths.
%         src_name=['results_' sources_norm];
%         if (strcmp(source_orient, 'loose'))
%             dest_name=[src_name '_loose'];
%         end 
%         sources_results=cell(project.subjects.numsubj,tot_num_contrasts);
%         for subj=1:project.subjects.numsubj 
%             for cond=1:project.epoching.numcond
%                 sources_results{subj,cond} = fullfile(project.subjects.list{subj}, name_cond{cond}, [src_name '.mat']);
%             end
%             for mcond=1:length(name_maineffects)
%                 totcond = mcond + project.epoching.numcond;
%                 sources_results{subj,totcond} = fullfile(project.subjects.list{subj}, name_maineffects{mcond}, [src_name '.mat']);
%             end
%         end
%     end
%     
%     % call brainstorm_sources_tf
%     for subj=1:project.subjects.numsubj 
%         % 4 basic conditions
%         for cond=1:project.epoching.numcond
%             brainstorm_subject_sources_scouts_tf_moving_scrambled_walker(project.brainstorm.db_name, sources_results{subj,cond},brainstorm_analysis_times, brainstorm_analysis_bands, zscore_overwriting, project_settings);
%         end
%         % main effects
%         for mcond=1:length(name_maineffects)
%             totcond = mcond + length(name_cond);
%             brainstorm_subject_sources_scouts_tf_moving_scrambled_walker(project.brainstorm.db_name, sources_results{subj,totcond},brainstorm_analysis_times, brainstorm_analysis_bands, zscore_overwriting, project_settings);
%         end        
%     end    
% end
% %==================================================================================
% if do_sources_export2spm8
%     % export sources results over subject/condition
% 
%     postprocess_sources_tag_list={'wmne | fixed | surf', 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
%     postprocess_sources_tag_list={'wmne | fixed | surf'}; ..., 'wmne | free | vol', 'wmne | loose | 0.2 | surf', 'sloreta | fixed | surf', 'sloreta | free | vol', 'sloreta | loose | 0.2 | surf'};
%     %name_cond={'cwalker'};project.subjects.list={'alessandra_finisguerra'};time_windows_names_short={{'N200'}};time_windows_sec={{[0.200 0.230]}};time_windows_list={{[200 230]}};
%     
%     name_cond = project.epoching.condition_names;
%     cond_length = length(name_cond);
%     
%     group_time_windows_list     = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
%     subject_time_windows_list   = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');
%     group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
%     
%     
%     group_time_windows_list = {}; group_time_windows_names = {};
%     group_time_windows_list{1}{1}   = [-0.4 -0.04];
%     group_time_windows_names{1}{1}  = 'BL';
%     
%     sample_length.ms               = 1000/project.eegdata.fs;
%  
%     for tw=1:length(group_time_windows_list{1})
%         group_time_windows_list{1}{tw} = (round(group_time_windows_list{1}{tw}/sample_length.ms)*sample_length.ms)/1000;
%     end
%     
%     spmsources_path = fullfile(project.paths.spmsources, '4mm', project.analysis_name);
%     
%     for t=1:length(postprocess_sources_tag_list)
%         tag=postprocess_sources_tag_list{t};
%         file_tag = strrep(tag, ' | ', '_');
%         file_tag = strrep(file_tag, '.', '');
%         
%         input_file = 'data_average.mat';
%         for cond=1:project.epoching.numcond
%            cond_files = brainstorm_results_get_from_subjectslist_by_tag('', project.subjects.list, name_cond{cond}, input_file, tag);
%            for s=1:length(cond_files)
%                 for tw=1:length(group_time_windows_list{1})
%                      output_tag = [project.subjects.list{s} '_' project.analysis_name '_' name_cond{cond} '_' file_tag '_' group_time_windows_names{1}{tw}];
%                      brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, group_time_windows_list{1}{tw},  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200')
%                 end
%            end
%         end
% 
%         for mcond=1:length(name_maineffects)
%             cond_files=brainstorm_results_get_from_subjectslist_by_tag('', project.subjects.list, name_maineffects{mcond}, input_file, tag);
%             for s=1:length(project.subjects.list)
%                 for tw=1:length(group_time_windows_list{1})
%                     output_tag=[project.subjects.list{s} '_' analysis_name '_' name_maineffects{mcond} '_' file_tag '_' group_time_windows_names{1}{tw}];
%                     brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, group_time_windows_list{1}{tw},  output_tag, 'voldownsample', 2); ... 'alessandra_finisguerra_centered_N200')
%                 end
%             end
%         end
%     end
% end
% %==================================================================================
% if do_sources_export2spm8_subjects_peaks
%     % export sources results over subject/condition
% 
%     postprocess_sources_tag_list        = {'wmne | fixed | surf'}; 
%     peak_subfolder  = 'peak_20ms';
%     results_file    = '/data/projects/PAP/moving_scrambled_walker/results/OCICA_250c/erp_topo_allconditions-20140714T114521/all-erp_topo_tw-lDorsal-individual_align_20140714T121922/erp_compact.mat';
%     
%     
%     spmsources_path             = fullfile(project.paths.spmsources, '4mm', project.analysis_name, peak_subfolder, '');
%     sample_length.ms               = 1000/project.eegdata.fs;
%     group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
%     list_windows_names          = group_time_windows_names{1}; ... {'P100'}
%     condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
%     list_subjects               = []; ...{'alessandra_finisguerra', 'alessia','antonio2', 'augusta2', 'claudio2'}; ...project.subjects.list;
%     
%     window_samples_halfwidth        = 3;
%     
%     subj_latencies  = proj_get_erp_peak_info(project, results_file, 'list_subjects', list_subjects, 'condition_names', condition_names, 'list_windows_names', list_windows_names);
%     subj_latencies  = (round(subj_latencies/sample_length.ms)*sample_length.ms)/1000;
%     
%     for t=1:length(postprocess_sources_tag_list)
%         tag         = postprocess_sources_tag_list{t};
%         file_tag    = strrep(tag, ' | ', '_');
%         file_tag    = strrep(file_tag, '.', '');
%         input_file  = 'data_average.mat';
%         
%         for cond=1:project.epoching.numcond
%            cond_files = brainstorm_results_get_from_subjectslist_by_tag('', subjects_list, condition_names{cond}, input_file, tag);
%            for s=1:length(cond_files)
%                 for tw=1:length(list_windows_names)
%                      output_tag     = [subjects_list{s} '_' project.analysis_name '_' condition_names{cond} '_' file_tag '_' list_windows_names{tw}];
%                      window_limits  = [subj_latencies(cond, tw, s)-window_samples_halfwidth*sample_length.ms subj_latencies(cond, tw, s)+window_samples_halfwidth*sample_length.ms];
% 
%                      brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, window_limits,  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200'
%                 end
%            end
%         end
% 
%         for mcond=1:length(name_maineffects)
%             cond_files=brainstorm_results_get_from_subjectslist_by_tag('', project.subjects.list, name_maineffects{mcond}, input_file, tag);
%             for s=1:length(project.subjects.list)
%                 for tw=1:length(group_time_windows_list{1})
%                      output_tag     = [subjects_list{s} '_' project.analysis_name '_' name_maineffects{mcond} '_' file_tag '_' list_windows_names{tw}];
%                      window_limits  = [subj_latencies(cond, tw, s)-window_samples_halfwidth*sample_length.ms subj_latencies(cond, tw, s)+window_samples_halfwidth*sample_length.ms];
% 
%                      brainstorm_subject_sources_export2spm_volume(project.brainstorm.db_name, cond_files{s}, spmsources_path, window_limits,  output_tag, 'voldownsample', project.brainstorm.export.spm_vol_downsampling); ... 'alessandra_finisguerra_centered_N200'
%                 end
%             end
%         end
%     end
% end
% %==================================================================================
% 
% %==================================================================================
% %==================================================================================
% %==================================================================================
% %==================================================================================
% % GROUP ANALYSIS
% %==================================================================================
% %==================================================================================
% %==================================================================================
% %==================================================================================
% % GROUP AVERAGING
% %==================================================================================
% if do_group_averaging
%     proj_brainstorm_group_average_cond(project);
% end
% %==================================================================================
% %==================================================================================
% % STATS
% %==================================================================================
% %==================================================================================
% % all sources
% results=cell(1,tot_num_contrasts);
% if do_group_analysis
%      results{1} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker', 'cscrambled'  , input_results_tag, 1, project.subjects.list);
%      results{2} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'twalker','tscrambled'   , input_results_tag, 1, project.subjects.list);
%      results{3} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','twalker'      , input_results_tag, 1, project.subjects.list);
%      results{4} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cscrambled','tscrambled', input_results_tag, 1, project.subjects.list);
%      results{5} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'walker','scrambled'     , input_results_tag, 1, project.subjects.list);
%      results{6} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'centered','translating' , input_results_tag, 1, project.subjects.list);
% end
% %==================================================================================
% % atlas
% results_atlas=cell(1,tot_num_contrasts);
% if do_group_analysis_atlas
%      results_atlas{1} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','cscrambled'     ,['results_' sources_norm '_' downsample_atlasname] ,1,project.subjects.list);
%      results_atlas{2} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'twalker','tscrambled'     ,['results_' sources_norm '_' downsample_atlasname],1,project.subjects.list);
%      results_atlas{3} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','twalker'        ,['results_' sources_norm '_' downsample_atlasname],1,project.subjects.list);
%      results_atlas{4} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cscrambled','tscrambled'  ,['results_' sources_norm '_' downsample_atlasname],1,project.subjects.list);
%      results_atlas{5} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'walker','scrambled'       ,['results_' sources_norm '_' downsample_atlasname],1,project.subjects.list);
%      results_atlas{6} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'centered','translating'   ,['results_' sources_norm '_' downsample_atlasname],1,project.subjects.list);
% end
% %==================================================================================
% % TF all sources
% results_scouts_tf=cell(1,tot_num_contrasts);
% if do_group_analysis_tf
%     file_input='timefreq_morlet_wmne_s3000_teta_mu_beta1_beta2_zscore';
% %     results_scouts_tf{1} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker'   ,'cscrambled'   ,file_input,1,project.subjects.list);
% %     results_scouts_tf{2} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'twalker'   ,'tscrambled'   ,file_input,1,project.subjects.list);
% %     results_scouts_tf{3} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker'   ,'twalker'      ,file_input,1,project.subjects.list);
% %     results_scouts_tf{4} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cscrambled','tscrambled'   ,file_input,1,project.subjects.list);
% %     results_scouts_tf{5} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'walker'    ,'scrambled'    ,file_input,1,project.subjects.list);
% %     results_scouts_tf{6} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'centered'  ,'translating'  ,file_input,1,project.subjects.list);
% end
% %==================================================================================
% % TF 69 scouts
% results_scouts_tf=cell(1,tot_num_contrasts);
% if do_group_analysis_scouts_tf
%     file_input='timefreq_morlet_wmne_teta_mu_beta1_beta2_69scouts_zscore';
%     results_scouts_tf{1} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','cscrambled', file_input ,1,project.subjects.list);
% %     results_scouts_tf{2} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'twalker','tscrambled',file_input,1,project.subjects.list);
% %     results_scouts_tf{3} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cwalker','twalker',file_input,1,project.subjects.list);
% %     results_scouts_tf{4} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'cscrambled','tscrambled',file_input,1,project.subjects.list);
% %     results_scouts_tf{5} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'walker','scrambled',file_input,1,project.subjects.list);
% %     results_scouts_tf{6} = brainstorm_group_stats_2cond_pairedttest(project.brainstorm.db_name, 'centered','translating',file_input,1,project.subjects.list);
% end
% %==================================================================================
% %==================================================================================
% % PARSE RESULTS
% %==================================================================================
% %==================================================================================
% % parse sources results
% if do_process_stats_sources
%     all_group_results = bst_get('Study', -2); ... bst_get('Study', '@inter/brainstormstudy.mat');
%     num_stats=length(all_group_results.Stat);
%     for res=1:num_stats
%        filename=all_group_results.Stat(res).FileName;
%        if findstr(filename, process_result_string)
%            disp(['@@@@@@@@@@@@@@@@' filename]);
%            brainstorm_process_result(project.brainstorm.db_name, filename, StatThreshOptions);
%        end
%     end
% end
% %==================================================================================
% %==================================================================================
% % parse scouts TF results
% if do_process_stats_scouts_tf
%     process_result_string='130614';
%     all_group_results = bst_get('Study', -2); ... bst_get('Study', '@inter/brainstormstudy.mat');
%     num_stats=length(all_group_results.Stat);
%     for res=1:num_stats
%        filename=all_group_results.Stat(res).FileName;
%        if findstr(filename, process_result_string)
%            disp(['@@@@@@@@@@@@@@@@' filename]);
%            brainstorm_process_stats_scout_time_freq(project.brainstorm.db_name, filename, StatThreshOptions, [-400:4:350]);
%        end
%     end
% end
