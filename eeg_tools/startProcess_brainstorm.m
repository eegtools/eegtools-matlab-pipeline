%% function result = startProcess(project, action_name, stat_analysis_suffix, design_num_vec, list_select_subjects, varargin)
%
%
% it will contain as much CASE branches as the available processes
% result is an EEG structure in case of subject processing
%
%
function result = startProcess_brainstorm(project, action_name, varargin)

% strpath = path;
% if ~strfind(strpath, project.paths.shadowing_functions)
%     addpath(project.paths.shadowing_functions);      % eeglab shadows the fminsearch function => I add its path in case I previously removed it
% end

% defaults
list_select_subjects        = project.subjects.list;
design_num_vec              = [];
custom_suffix               = '';
custom_input_folder         = '';
stat_analysis_suffix        = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects'   ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end
project.list_select_subjects = list_select_subjects;
result = [];
%     try


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
% chan_eeglab2brainstorm
% chan_eeglab2brainstorm2

% convertire il montaggio da eeglab a branstorm (si presuppone che il
% montaggio sia stato esportato da eeglab con l'apposita funzione dal main
% eeglab)
status = proj_brainstorm_convert_montage_eeglab2brainstorm(project);



switch action_name
    % =====================================================================================================================================================================
    % S U B J E C T    P R O C E S S I N G
    %=====================================================================================================================================================================
    % import EEGLAB epochs into BRAINSTORM and do averaging
    case 'do_subject_sensors_import_averaging'
        % for each epochs set file (subject and condition) perform: import, averaging, channelset,
        proj_brainstorm_subject_importepochs_averaging_new(project, 'list_select_subjects', list_select_subjects);
        db_reload_database(iProtocol);
        
        % do averaging of main effects...average n-conditions epochs and create a new condition
    case 'do_subject_average_conditions'
        proj_brainstorm_subject_average_conditions_new(project, 'list_select_subjects', list_select_subjects);
        
        % do aggregate conditions
    case 'do_subject_aggregate_conditions'
        % allow testing some semi-automatic aritfact removal algorhithms
        proj_brainstorm_subject_aggregate_conditions_new(project, 'list_select_subjects', list_select_subjects);
        
        %         % create subjects differences between two experimental conditions
        %     case 'do_subject_conditions_differences'
        %         proj_brainstorm_conditions_differences_new(project, 'list_select_subjects', list_select_subjects);
        %
        % compute time frequency decomposition for each subject and experimental condition
    case 'do_group_average_cond'
        proj_brainstorm_subject_aggregate_conditions_new(project,'list_select_subjects', list_select_subjects);
        
        
    case 'do_subject_tf_conditions'
        proj_brainstorm_subject_tf_conditions(project, 'list_select_subjects', list_select_subjects);
        
    case 'do_subject_tf_baseline_correction_conditions'
        proj_brainstorm_subject_tf_bc_conditions(project, 'list_select_subjects', list_select_subjects);
        
    case 'do_subject_tf_group_bands_conditions'
        proj_brainstorm_subject_tf_gb_conditions(project, 'list_select_subjects', list_select_subjects);
        
        % common noise estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
    case 'do_subject_noise_estimation'
        proj_brainstorm_subject_noise_estimation_new(project, 'list_select_subjects', list_select_subjects);
        
        % common noise estimation, AGGREGATED CONDITIONS.
    case 'do_subject_noise_estimation_factors'
        proj_brainstorm_subject_noise_estimation_factors_new(project, 'list_select_subjects', list_select_subjects);
        
        % common data estimation, calculated with the basic conditions recordings and then copied to the other ones (main effects).
    case 'do_subject_data_estimation'
        proj_brainstorm_subject_data_estimation_new(project, 'list_select_subjects', list_select_subjects);
        
        % common data estimation, AGGREGATED CONDITIONS.
    case 'do_data_estimation_factors'
        proj_brainstorm_subject_data_estimation_factors_new(project, 'list_select_subjects', list_select_subjects);
        
        % BEM calculation over first subject (and first condition) 'model_type'
    case 'do_subject_bem'
        proj_brainstorm_subject_bem_new(project); % 1: surface, 2: volume
        
        % check if all subjects have BEM file. if not, copy it from first subject
        % to remaining ones. copy to all subjects (assuming all the subjects used the same montage)
    case 'do_subject_check_bem'
        proj_brainstorm_subject_check_bem_new(project);
        
        % backup  BEM file.
    case 'do_subject_backup_bem'
        proj_brainstorm_subject_backup_bem_new(project);
        
        % recover  BEM file.
    case 'do_subject_recover_bem'
        proj_brainstorm_subject_recover_bem_new(project,'list_select_subjects', list_select_subjects);
        
        % sources calculation over full Vertices (usually 15000) surface.
        % perform sources processing over subject/condition/data_average.mat
    case 'do_subject_sources'
        proj_brainstorm_subject_sources_new(project,'list_select_subjects', list_select_subjects);
        
        % sources calculation over full Vertices (usually 15000) surface AGGREGATED CONDITIONS
        % perform sources processing over subject/condition/data_average.mat
    case 'do_subject_sources_factors'
        proj_brainstorm_subject_sources_factors_new(project,'list_select_subjects', list_select_subjects);
        
        % sources time-frequency calculation: four freq bands, temporary over-ride
        % output : [timefreq_morlet_' source_norm band_desc '_zscore.mat']
    case 'do_sources_tf_calculation'
        proj_brainstorm_subject_sources_tf_calculation_new(project,'list_select_subjects', list_select_subjects)
        
        % scouts time-frequency calculation: four freq bands, temporary over-ride
        % output: [timefreq_morlet_' source_norm band_desc '_69scouts_zscore.mat']
    case 'do_sources_scouts_tf_calculation'
        proj_brainstorm_subject_sources_scouts_tf_calculation_new(project,'list_select_subjects', list_select_subjects)
        
        
    case 'do_subject_scout_fc'           
        proj_brainstorm_subject_scout_fc(project,'list_select_subjects', list_select_subjects)
     
        % zscore sempre fare prima della norma (unconstrained) o conversione in abs
        % (constrained)
    case 'do_subject_results_zscore'
        proj_brainstorm_subject_get_from_subjectslist_by_tag_new(project,'list_select_subjects', list_select_subjects)
        
        % time dimensionality reduction: averaging samples within a number of timewindows
    case 'do_subject_tw_reduction'
        proj_brainstorm_subject_tw_reduction_new(project,'list_select_subjects', list_select_subjects)
        
        % time dimensionality reduction: averaging samples within a number of timewindows
    case 'do_subject_tw_reduction_factors'
        proj_brainstorm_subject_tw_reduction_factors_new(project,'list_select_subjects', list_select_subjects)
        
        % spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
    case 'do_subject_sources_spatial_reduction'
        proj_brainstorm_subject_sources_spatial_reduction_new(project,'list_select_subjects', list_select_subjects)
        
        % spatial dimensionality reduction: downsampling to user-generated atlas composed by hundreds of scouts
        % uses : 'process_extract_scout'
    case 'do_subject_sources_extract_scouts'
        proj_brainstorm_subject_sources_extract_scouts_new(project,'list_select_subjects', list_select_subjects)
        
    case 'do_subject_scout_tf'
        proj_brainstorm_subject_scout_tf(project,'list_select_subjects', list_select_subjects)
    
        
        
        % this version accept a struct array of time windows and averages all the values contained within each struct array element
        % it grants just one controlled time value for each struct array element, uses : 'process_extract_values'
    case 'do_subject_sources_scouts_1period'
        proj_brainstorm_subject_sources_scouts_1period_new(project,'list_select_subjects', list_select_subjects)
        
        % project unconstrained 3oriented sources to a scalar value
    case 'do_subject_uncontrained2flat'
        proj_brainstorm_subject_uncontrained2flat_new(project, 'list_select_subjects', list_select_subjects)
        
        % project unconstrained 3oriented sources to a scalar value FACTORS
    case 'subject_uncontrained2flat_factors'
        proj_brainstorm_subject_uncontrained2flat_factors_new(project, 'list_select_subjects', list_select_subjects)
        
        
        % both continuous and tw
        
        % average sources results both continuous and tw (ONLY by CONDITION, NOT byGROUP)
    case 'do_group_average_cond_results'
        proj_brainstorm_group_average_cond_results_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and condition
        % (ATOMIC CELLS, CONDITIONS IN THE PROJECT STRUCTURE, NOT AGGREGATED IN DESIGN FACTORS)both continuous and tw
        % (by CONDITION AND GROUP  )
    case 'do_group_average_cond_results_group'
        proj_brainstorm_group_average_cond_results2_new(project, 'list_select_subjects', list_select_subjects)
        
        % average scalp erp results by group and condition
        % (ATOMIC CELLS, CONDITIONS IN THE PROJECT STRUCTURE, NOT AGGREGATED IN DESIGN FACTORS)both continuous and tw
        % (by CONDITION AND GROUP  )
    case 'do_group_average_cond_scalp_results_group'
        proj_brainstorm_group_average_cond_scalp_results2_new(project, 'list_select_subjects', list_select_subjects)
        
        
        % average sources results based on factor levels (ONLY by FACTORS, NOT byGROUP)
    case 'do_group_average_cond_results_factors'
        proj_brainstorm_group_average_cond_results_factors_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and levels of factors (by FACTORS AND GROUP  )
    case 'do_group_average_cond_results_factors_group'
        proj_brainstorm_group_average_cond_results2_factors_new(project, 'list_select_subjects', list_select_subjects)
        
        % average scalp erp results by group and levels of factors (by FACTORS AND GROUP  )
    case 'do_group_average_cond_scalp_results_factors_group'
        proj_brainstorm_group_average_cond_scalp_results2_factors_new(project, 'list_select_subjects', list_select_subjects)
        
        
        % only continuous
        
        % average sources results both continuous (ONLY by CONDITION, NOT byGROUP)
    case 'do_group_average_cond_results_cont'
        proj_brainstorm_group_average_cond_results_cont_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and condition
        % (ATOMIC CELLS, CONDITIONS IN THE PROJECT STRUCTURE, NOT AGGREGATED IN DESIGN FACTORS)both continuous and tw
        % (by CONDITION AND GROUP  )
    case 'do_group_average_cond_results_group_cond_cont'
        proj_brainstorm_group_average_cond_results2_cont_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results based on factor levels (ONLY by FACTORS, NOT byGROUP)
    case 'do_group_average_cond_results_factors_cont'
        proj_brainstorm_group_average_cond_results_factors_cont_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and levels of factors (by FACTORS AND GROUP  )
    case 'do_group_average_cond_results_factors_group_cont'
        proj_brainstorm_group_average_cond_results2_factors_cont_new(project, 'list_select_subjects', list_select_subjects)
        
        
        % only tw
        
        % average sources results both continuous (ONLY by CONDITION, NOT byGROUP)
    case 'do_group_average_cond_results_tw'
        proj_brainstorm_group_average_cond_results_cont_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and condition
        % (ATOMIC CELLS, CONDITIONS IN THE PROJECT STRUCTURE, NOT AGGREGATED IN DESIGN FACTORS)both continuous and tw
        % (by CONDITION AND GROUP  )
    case 'do_group_average_cond_results_group_cond_tw'
        proj_brainstorm_group_average_cond_results2_tw_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results based on factor levels (ONLY by FACTORS, NOT byGROUP)
    case 'do_group_average_cond_results_factors_tw'
        proj_brainstorm_group_average_cond_results_factors_tw_new(project, 'list_select_subjects', list_select_subjects)
        
        % average sources results by group and levels of factors (by FACTORS AND GROUP  )
    case 'do_group_average_cond_results_factors_group_tw'
        proj_brainstorm_group_average_cond_results2_factors_tw_new(project, 'list_select_subjects', list_select_subjects)
        
        % STATS
        %==================================================================================
        % %  2samples ttest NEW pairwise comparison by group and by condition
    case 'do_group_stats_cond_group_ttest_new'
        proj_brainstorm_group_stats_cond_group_ttest_new(project,'list_select_subjects',list_select_subjects)
        
        % baseline ttest for each condition and group
    case 'group_stats_baseline_ttest_new'
        results = proj_brainstorm_group_stats_baseline_ttest_new(project, 'list_select_subjects', list_select_subjects);
        
end
%     catch err
%         % This "catch" section executes in case of an error in the "try" section
%         err
%         err.message
%         err.stack(1)
%         result = err;
%         throw(err);
%     end

end

