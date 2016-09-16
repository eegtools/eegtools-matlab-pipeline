%% [STUDY, EEG] = proj_eeglab_study_plot_allch_erp_time(project, analysis_name, mode, varargin)
%
% calculate and display erp time series for groups of scalp channels consdered as regions of interests (allch) in
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
% * project.postprocess.erp.allch_list;
% * project.postprocess.erp.allch_names;
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
% * project.postprocess.erp.design
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
% allch_list
% allch_names
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

function [STUDY, EEG] = proj_eeglab_study_plot_allch_erp_time(project, analysis_name, mode, varargin)

if nargin < 1
    help proj_eeglab_study_plot_allch_erp_curve;
    return;
end;

study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
results_path                = project.paths.results;

paired_list = cell(length(project.design), 2);
for ds=1:length(project.design)
    paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing};
end

% VARARGIN DEFAULTS
list_select_subjects        = {};
design_num_vec              = [1:length(project.design)];

allch_list                    = project.postprocess.erp.allch_list;
allch_names                   = project.postprocess.erp.allch_names;

study_ls                    = project.stats.erp.pvalue;
num_permutations            = project.stats.erp.num_permutations;
correction                  = project.stats.eeglab.erp.correction;
stat_method                 = project.stats.eeglab.erp.method;

filter                      = project.results_display.erp.time_smoothing;
masked_times_max            = project.results_display.erp.masked_times_max;
display_only_significant    = project.results_display.erp.display_only_significant_curve;
display_compact_plots       = project.results_display.erp.compact_plots;
compact_display_h0          = project.results_display.erp.compact_h0;
compact_display_v0          = project.results_display.erp.compact_v0;
compact_display_sem         = project.results_display.erp.compact_sem;
compact_display_stats       = project.results_display.erp.compact_stats;
display_single_subjects     = project.results_display.erp.single_subjects;
compact_display_xlim        = project.results_display.erp.compact_display_xlim;
compact_display_ylim        = project.results_display.erp.compact_display_ylim;


group_time_windows_list     = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
subject_time_windows_list   = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');
group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');

do_plots                    = project.results_display.erp.do_plots;

% ANALYSIS MODALITIES
if strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'off')
    which_method_find_extrema = 'group_noalign';
elseif strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'on')
    which_method_find_extrema = 'group_align';
elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'off')
    which_method_find_extrema = 'individual_noalign';
elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'on')
    which_method_find_extrema = 'individual_align';
elseif strcmp(mode.peak_type, 'off')
    which_method_find_extrema = 'continuous';
end

tw_stat_estimator           = mode.tw_stat_estimator;
time_resolution_mode        = mode.time_resolution_mode;
sel_extrema                 = project.postprocess.erp.sel_extrema;

for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', ...
                'analysis_name', ...
                'allch_list', ...
                'allch_names', ...
                'study_ls', ...
                'num_permutations', ...
                'correction', ...
                'stat_method', ...
                'filter', ...
                'masked_times_max', ...
                'display_only_significant', ...
                'display_compact_plots', ...
                'compact_display_h0', ...
                'compact_display_v0', ...
                'compact_display_sem', ...
                'compact_display_stats', ...
                'display_single_subjects', ...
                'compact_display_xlim', ...
                'compact_display_ylim', ...
                'group_time_windows_list', ...
                'subject_time_windows_list', ...
                'group_time_windows_names', ...
                'sel_extrema', ...
                'list_select_subjects', ...
                'do_plots'}
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

dfcond=[];
dfgroup=[];
dfinter=[];


%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
%=================================================================================================================================================================
[study_path,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

chanlocs = eeg_mergelocs(ALLEEG.chanlocs);
allch         = {chanlocs.labels};


for design_num=design_num_vec
    
    
    
    % select the study design for the analyses
    STUDY                              = std_selectdesign(STUDY, ALLEEG, design_num);
    
    erp_curve_allch_stat.study_des       = STUDY.design(design_num);
    erp_curve_allch_stat.study_des.num   = design_num;
    erp_curve_allch_stat.allch_names       = allch_names;
    
    name_f1                            = STUDY.design(design_num).variable(1).label;
    name_f2                            = STUDY.design(design_num).variable(2).label;
    
    levels_f1                          = STUDY.design(design_num).variable(1).value;
    levels_f2                          = STUDY.design(design_num).variable(2).value;
    
    str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    plot_dir                           = fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-erp_allch-',str]);
    mkdir(plot_dir);
    
    % set representation to time-frequency representation
    STUDY = pop_erpparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','off','method', stat_method);
    
    
    list_design_subjects               = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);
    
    % erp_curve_allch cell array of dimension tlf1 x tlf2 , each cell of
    % dimension times x channels x subjects
    
    [STUDY, erp_curve_allch, times]=std_erpplot(STUDY,ALLEEG,'channels',allch,'noplot','on');
    
    
    
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end
                erp_curve_allch{nf1,nf2}=erp_curve_allch_stat.erp_curve_allch{nf1,nf2}(:,vec_select_subjects);
                list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
            end
        end
    end
    erp_curve_allch_stat.list_design_subjects = list_design_subjects;
    erp_curve_allch_stat.erp_curve_allch       = erp_curve_allch;
    erp_curve_allch_stat.allch                 = allch;
    erp_curve_allch_stat.times                 = times;
    
    STUDY = pop_erpparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','on','method', stat_method);
    % for each allch in the list
    
    
    erp_curve_allch_stat.times= times;
    
    
    
    erp_curve_allch_stat.study_ls             = study_ls;
    erp_curve_allch_stat.num_permutations     = num_permutations;
    erp_curve_allch_stat.correction           = correction;
    erp_curve_allch_stat.list_select_subjects = list_select_subjects;
    
    [pcond_corr, pgroup_corr,  pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
    
    
    if (strcmp(do_plots,'on'))
        
        % possibilità di passare direttamente l'output statistico ma per il
        % plot mi servono comunque dei parametri aggiuntivi? o li posso
        % comunque mettere nella struttura di output dei risultati? forse
        % sì perchè fanno parte dei parametri necessari x riprodurre il
        % plot da zero senza dover far girare tutta la funzione ma solo
        % caricando i parametri dalla struttura esportata
        
        erp_curve_allch_stat.project                                        = project;
        erp_curve_allch_stat.STUDY                                          = STUDY;
        erp_curve_allch_stat.design_num                                     = design_num;       
        erp_curve_allch_stat.name_f1                                        = name_f1;
        erp_curve_allch_stat.name_f2                                        = name_f2;
        erp_curve_allch_stat.levels_f1                                      = levels_f1;
        erp_curve_allch_stat.levels_f2                                      = levels_f2;
        erp_curve_allch_stat.erp_curve                                      = erp_curve_allch;
        erp_curve_allch_stat.times                                          = times;        
        erp_curve_allch_stat.pcond                                          = pcond_corr;
        erp_curve_allch_stat.pgroup                                         = pgroup_corr;
        erp_curve_allch_stat.pinter                                         = pinter_corr;
        erp_curve_allch_stat.study_ls                                       = study_ls ;
        erp_curve_allch_stat.plot_dir                                       = plot_dir;       
        erp_curve_allch_stat.display_compact_plots                          = display_compact_plots;        
        erp_curve_allch_stat.compact_display_xlim                           = compact_display_xlim;
        erp_curve_allch_stat.compact_display_ylim                           = compact_display_ylim;
        
        
        
        eeglab_study_allch_erp_time_graph(erp_curve_allch_stat);
    end
    
    
    
    %% EXPORTING DATA AND RESULTS OF ANALYSIS
   % bisognerebbe esportare delle info sui canali ed i tempi con differenze
   % significative per poter confermare o estendere le roi e/o le time
   % window
    
    %% EXPORTING DATA AND RESULTS OF ANALYSIS
    out_file_name = fullfile(plot_dir,'erp_curve_allch-stat');
    save([out_file_name,'.mat'],'erp_curve_allch_stat');
    
    %     if ~ ( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
    %         [dataexpcols, dataexp] = text_export_erp_struct([out_file_name,'.txt'],erp_curve_allch_stat);
    % %         text_export_erp_resume_struct(erp_curve_allch_stat, [out_file_name '_resume']);
    % %         text_export_erp_resume_struct(erp_curve_allch_stat, [out_file_name '_resume_signif'], 'p_thresh', erp_curve_allch_stat.study_ls);
    %     end
    

end
end
