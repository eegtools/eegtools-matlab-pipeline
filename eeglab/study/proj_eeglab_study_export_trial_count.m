%% [STUDY, EEG] = proj_eeglab_study_export_trial_count(project, analysis_name, mode, varargin)
%
% calculate and display erp time series for groups of scalp channels consdered as regions of interests (ROI) in
% an EEGLAB STUDY with statistical comparisons based on the factors in the selected design.
%
% ====================================================================================================
% REQUIRED INPUT:
%
% ----------------------------------------------------------------------------------------------------
% project; a structure with the following MANDATORY fields:
%
% * project.study.filename; the filename of the study
% * project.paths.output_epochs; the path where the study file will be
%   placed (default: the same foleder of the epoched datasets)
% * project.paths.results; the path were the results will be saved
% * project.design; the experimental design:
%   project.design(design_number) = struct(
%                                         'name', design_name,
%                                         'factor1_name',  factor1_name,
%                                         'factor1_levels', factor1_levels ,
%                                         'factor1_pairing', 'on',
%                                         'factor2_name',  factor2_name,
%                                         'factor2_levels', factor2_levels ,
%                                         'factor2_pairing', 'on'
%                                         )
% * project.postprocess.erp.roi_list;
% * project.postprocess.erp.roi_names;
% * project.stats.erp.pvalue;
% * project.stats.erp.num_permutations;
% * project.stats.eeglab.erp.correction;
% * project.stats.eeglab.erp.method;
% * project.results_display.erp.time_smoothing;
% * project.results_display.erp.masked_times_max;
% * project.results_display.erp.display_only_significant_curve;
% * project.results_display.erp.compact_plots;
% * project.results_display.erp.compact_h0;
% * project.results_display.erp.compact_v0;
% * project.results_display.erp.compact_sem;
% * project.results_display.erp.compact_stats;
% * project.results_display.erp.single_subjects;
% * project.results_display.erp.compact_display_xlim;
% * project.results_display.erp.compact_display_ylim;
% * project.study.export_epochs_count.cond_list
%
% ----------------------------------------------------------------------------------------------------
% analysis_name
%
%
% ----------------------------------------------------------------------------------------------------
% mode
%
%
%
% ====================================================================================================
% OPTIONAL INPUT:
%
% design_num_vec
% analysis_name
% roi_list
% roi_names
% study_ls
% num_permutations
% correction
% stat_method
% filter
% masked_times_max
% display_only_significant
% display_compact_plots
% compact_display_h0
% compact_display_v0
% compact_display_sem
% compact_display_stats
% display_single_subjects
% compact_display_xlim
% compact_display_ylim
% group_time_windows_list
% subject_time_windows_list
% group_time_windows_names
% sel_extrema
% list_select_subjects
% do_plots
% ====================================================================================================

function [STUDY, EEG] = proj_eeglab_study_export_trial_count(project,  varargin)

if nargin < 1
    help proj_eeglab_study_export_trial_count;
    return;
end

study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;


% VARARGIN DEFAULTS
list_select_subjects        = {};
design_num_vec              = [1:length(project.design)];

project.epoching.condition_names

for par=1:2:length(varargin)
    switch varargin{par}
        case {...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end



%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
[study_folder,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_folder);

%% export trial count for a selected list of conditions
% maximum granularity:all conditions with corresponding level
% of all factors defined for alla designs
project.study.export_epochs_count.cond_list = project.epoching.condition_names;
if isfield(project.study,'export_epochs_count')
    if not(isempty(project.study.export_epochs_count.cond_list))
        cond_list = project.study.export_epochs_count.cond_list;
    else
        disp('project.study.export_epochs_count.cond_list not defined: export trial count for all conditions!')
    end
else
    disp('project.study.export_epochs_count not defined: export trial count for all conditions!')
end



tcond = length(cond_list);

file2save_name  = [STUDY.name(1:end-6),'_trial_count_table'  '.txt'];
file2save_path = fullfile(study_folder,file2save_name);


tsub = length(STUDY.subject);
trows = tcond*tsub;

subject          = cell(trows,1);
condition         = cell(trows,1);
trial_count  = cell(trows,1);

nrow = 1;
for ncond = 1:tcond
    current_cond = cond_list{ncond};
    for nsub = 1:tsub
        current_sub = STUDY.subject{nsub};
        current_set = ALLEEG(nsub);
        
        
        all_eve_cond_sub = {current_set.event.condition_catsub};
        
        % extract levels of each factor associated to events
        select_cond_sub = ismember(all_eve_cond_sub,current_cond);
        
        current_event = current_set.event(select_cond_sub);
        all_event_fields = fieldnames(current_event);
        
        sel_factors = not(ismember(all_event_fields,{'type','latency','epoch','urevent','duration','condition_catsub'}));
        
        if isfield(project.study,'export_trial_count')
            
            sel_factors2 = ismember(all_event_fields,project.study.export_trial_count.list_select_factors);
            sel_factors = sel_factors & sel_factors2;
            
        end
        
        factors = all_event_fields(sel_factors);
        tfac = length(factors);
        
        trial_count_cond_sub = sum(select_cond_sub);
        
        subject{nrow}          = current_sub;
        condition{nrow}        = current_cond;
        trial_count{nrow}      = trial_count_cond_sub;
        
        str_factors = [];
        
        for nfac = 1:tfac
            current_factor = factors{nfac};
            str_factors = [str_factors,current_factor,', '];
            current_level = char(unique({current_event.(current_factor)}));
            str = [current_factor, '{nrow,1} = ','''',current_level,''';'];
            eval(str);
        end
        
        nrow = nrow +1;
    end
end

str_out = ['trial_count_table = table(subject, condition, ',str_factors,'trial_count);'];
eval(str_out);
writetable(trial_count_table,file2save_path,"Delimiter","\t");
disp(['exported: ', file2save_path]);


%% export trial count aggregated by design levels for each design and subject
file2save_name  = [STUDY.name(1:end-6),'_trial_count_table_design'  '.txt'];
file2save_path = fullfile(study_folder,file2save_name);
clear subject trial_count;
nrow  = 1;
for nfac = 1:tfac
    current_factor = factors{nfac};
    current_factor_column = trial_count_table.(current_factor);
    current_levels_all = unique(current_factor_column);
    select_levels = not(ismember(current_levels_all,'nolevels'));
    current_levels = current_levels_all(select_levels);
    tlev = length(current_levels);
    for nlev = 1:tlev
        current_level = current_levels{nlev};
        select_level = ismember(current_factor_column, current_level);
        for nsub = 1:tsub
            current_sub = STUDY.subject{nsub};
            select_sub = ismember(trial_count_table.subject,current_sub);
            select_data = select_level & select_sub;
            current_data = trial_count_table.trial_count(select_data);
            current_count = sum([current_data{:}]);
            
            subject{nrow,1}          = current_sub;
            design_cell{nrow,1}      = current_level;
            trial_count{nrow,1}      = current_count;
            
            nrow = nrow +1;
            
            
        end
    end
end
trial_count_table_design = table(design_cell,subject,trial_count);
writetable(trial_count_table_design,file2save_path,"Delimiter","\t");
disp(['exported: ', file2save_path]);



%% export trial count aggregated by design levels for each design:
% grand mean/std among subjects for the mean and total number of trials

file2save_name  = [STUDY.name(1:end-6),'_trial_count_table_global'  '.txt'];
file2save_path = fullfile(study_folder,file2save_name);

design_cells = unique(design_cell);
tdc = length(design_cells);

clear design_cell;
nrow = 1;
for ndc = 1:tdc
    current_design_cell = design_cells{ndc};
    select_design_cell = ismember(trial_count_table_design.design_cell, current_design_cell);
    current_data = trial_count_table_design.trial_count(select_design_cell);
    design_cell{nrow,1} = current_design_cell;
    design_cell_sum{nrow,1} = sum([current_data{:}]);
    design_cell_mean{nrow,1} = mean([current_data{:}]);
    design_cell_std{nrow,1} = std([current_data{:}]);
    nrow = nrow +1;
end

trial_count_table_design_aggregated = table(design_cell,design_cell_sum,design_cell_mean,design_cell_std);

global_sum_mean = mean([trial_count_table_design_aggregated.design_cell_sum{:}]);
global_sum_std = std([trial_count_table_design_aggregated.design_cell_sum{:}]);
global_mean_mean = mean([trial_count_table_design_aggregated.design_cell_mean{:}]);
global_mean_std = std([trial_count_table_design_aggregated.design_cell_mean{:}]);

trial_count_table_global = table(global_sum_mean,global_sum_std,global_mean_mean,global_mean_std);
writetable(trial_count_table_global,file2save_path,"Delimiter","\t");

disp(['exported: ', file2save_path]);


end
