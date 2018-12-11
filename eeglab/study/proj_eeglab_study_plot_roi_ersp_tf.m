%% [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_tf(project, analysis_name, ersp_tf_resolution_mode, varargin)
%
% calculate and display ersp time frequency distribution for groups of scalp channels consdered as regions of interests (ROI) in
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
% * project.postprocess.ersp.roi_list;
% * project.postprocess.ersp.roi_names;
% * project.stats.ersp.pvalue;
% * project.stats.ersp.num_permutations;
% * project.stats.eeglab.ersp.correction;
% * project.stats.eeglab.ersp.method;
% * project.results_display.ersp.stat_time_windows_list;
% * project.results_display.ersp.display_only_significant_tf;
% * project.results_display.ersp.display_only_significant_tf_mode;
% * project.results_display.ersp.set_caxis_tf;
% * project.stats.ersp.decimation_factor_times_tf;
% * project.stats.ersp.decimation_factor_freqs_tf;
% * project.results_display.ersp.time_range.ms;
% * project.results_display.ersp.frequency_range;
% * project.postprocess.ersp.frequency_bands_list;
% * project.postprocess.ersp.frequency_bands_names;
% * project.results_display.ersp.freq_scale;
% * project.stats.ersp.tf_resolution_mode;
% * project.stats.ersp.measure;
% * project.postprocess.ersp.design;
% * project.results_display.ersp.do_plots;
% * project.results_display.ersp.display_pmode;
%
% ----------------------------------------------------------------------------------------------------
% analysis_name
%
%
% ----------------------------------------------------------------------------------------------------
% ersp_tf_resolution_mode
%
%
%
% ====================================================================================================
% OPTIONAL INPUT:
%
% list_select_subjects
% design_num_vec
% roi_list
% roi_names
% study_ls
% num_permutations
% correction
% stat_method
%stat_time_windows_list
% display_only_significant
% display_only_significant_mode
% set_caxis
% decimation_factor_times
% decimation_factor_freqs
% timerange
% freqrange
% frequency_bands_list
% frequency_bands_names
% freq_scale
% ersp_tf_resolution_mode
% ersp_measure
% group_time_windows_list
% group_time_windows_names
% display_pmode
%
% ====================================================================================================



function [STUDY, EEG] = proj_eeglab_study_plot_roi_ersp_tf(project, analysis_name, varargin)

if nargin < 1
    help proj_eeglab_study_plot_roi_ersp_tf;
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

roi_list                    = project.postprocess.ersp.roi_list;
roi_names                   = project.postprocess.ersp.roi_names;

study_ls                    = project.stats.ersp.pvalue;
num_permutations            = project.stats.ersp.num_permutations;
correction                  = project.stats.eeglab.ersp.correction;
stat_method                 = project.stats.eeglab.ersp.method;

stat_time_windows_list      = project.results_display.ersp.stat_time_windows_list;
display_only_significant    = project.results_display.ersp.display_only_significant_tf;
display_only_significant_mode = project.results_display.ersp.display_only_significant_tf_mode;
set_caxis                   = project.results_display.ersp.set_caxis_tf;

decimation_factor_times     = project.stats.ersp.decimation_factor_times_tf;
decimation_factor_freqs     = project.stats.ersp.decimation_factor_freqs_tf;

timerange                   = project.results_display.ersp.time_range.ms;
freqrange                   = project.results_display.ersp.frequency_range;

frequency_bands_list        = project.postprocess.ersp.frequency_bands_list;
frequency_bands_names       = project.postprocess.ersp.frequency_bands_names;

freq_scale                  = project.results_display.ersp.freq_scale;
ersp_tf_resolution_mode     = project.stats.ersp.tf_resolution_mode;
ersp_measure                = project.stats.ersp.measure;

group_time_windows_list     = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
group_time_windows_names    = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');

do_plots                    = project.results_display.ersp.do_plots;
num_tails                   = project.stats.ersp.num_tails;
display_pmode               = project.results_display.ersp.display_pmode;

display_compact_plots       = project.results_display.ersp.compact_plots;


if isfield(project.stats.eeglab.ersp,'stat_freq_bands_list')
    stat_freq_bands_list        = project.stats.eeglab.ersp.stat_freq_bands_list;
else
    stat_freq_bands_list        = [];
end

if isfield(project.stats.eeglab.ersp,'mask_coef')
    mask_coef                   = project.stats.eeglab.ersp.mask_coef;    
else
    mask_coef = [];
end


if not(isfield(project.stats.ersp,'alignt0'))
    project.stats.ersp.alignt0 = 0;
end

alignt0                       = project.stats.ersp.alignt0;

if not(isfield(project.stats.ersp,'split_base'))
    project.stats.ersp.split_base = 0;
end

split_base                    = project.stats.ersp.split_base;

for par=1:2:length(varargin)
    switch varargin{par}
        case {'list_select_subjects', 'design_num_vec', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', 'stat_time_windows_list', ...
                'display_only_significant', 'display_only_significant_mode', 'set_caxis', 'decimation_factor_times', 'decimation_factor_freqs', ...
                'timerange','freqrange','frequency_bands_list','frequency_bands_names','freq_scale', 'ersp_tf_resolution_mode', 'ersp_measure', ...
                'group_time_windows_list','group_time_windows_names','do_plots','num_tails','stat_freq_bands_list','mask_coef','display_pmode'}
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end


%% =================================================================================================================================================================
[study_path,study_name_noext,study_ext] = fileparts(study_path);

%% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

for design_num=design_num_vec
    
    str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    plot_dir=fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-ersp_tf_roi','-',ersp_tf_resolution_mode,'-',str]);
    mkdir(plot_dir);
    
    %% subjects list divided by factor levels
    list_design_subjects = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
    
    %% set representation to time-frequency representation
    STUDY = pop_erspparams(STUDY, 'topotime',[] ,'topofreq', [],'timerange',timerange,'freqrange',freqrange);
    
    %% select the study design for the analyses
    STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
    
    ersp_tf_stat.study_des      = STUDY.design(design_num);
    ersp_tf_stat.study_des.num  = design_num;
    ersp_tf_stat.roi_names      = roi_names;
    
    %% exctract names of the factores and the names of the corresponding levels for the selected design
    name_f1                     = STUDY.design(design_num).variable(1).label;
    name_f2                     = STUDY.design(design_num).variable(2).label;
    
    levels_f1                   = STUDY.design(design_num).variable(1).value;
    levels_f2                   = STUDY.design(design_num).variable(2).value;
    
    switch ersp_tf_resolution_mode
        
        %         if isempty(group_time_windows_list) && isempty(frequency_bands_list)
        
        %% time frequency representation with raw time and frequency resolution%
        case 'continuous' % if decimation_factor_times == 1 &&  decimation_factor_freqs == 1
            for nroi = 1:length(roi_list)
                
                roi_channels=roi_list{nroi};
                roi_name=roi_names{nroi};
                
                input_calc.STUDY                         = STUDY;
                input_calc.ALLEEG                        = ALLEEG;
                input_calc.channels_list                 = roi_channels;
                input_calc.levels_f1                     = levels_f1;
                input_calc.levels_f2                     = levels_f2;
                input_calc.num_permutations              = num_permutations;
                input_calc.stat_time_windows_list        = stat_time_windows_list;
                input_calc.paired                        = paired_list{design_num};
                input_calc.stat_method                   = stat_method;
                input_calc.list_select_subjects          = list_select_subjects;
                input_calc.list_design_subjects          = list_design_subjects;
                input_calc.ersp_measure                  = ersp_measure;
                input_calc.num_tails                     = num_tails;
                input_calc.stat_freq_bands_list          = stat_freq_bands_list;
                input_calc.mask_coef                     = mask_coef;
                input_calc.alignt0                       = alignt0;
                input_calc.split_base                    = split_base;
                input_calc.design_num                    = design_num;
                

                
                
                [output_calc] = eeglab_study_roi_ersp_tf_simple(input_calc);
                
                ersp_tf  = output_calc.ersp_tf;
                times    = output_calc.times;
                freqs    = output_calc.freqs;
                pcond    = output_calc.pcond;
                pgroup   = output_calc.pgroup;
                pinter   = output_calc.pinter;
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                         = STUDY;
                    input_graph.design_num                    = design_num;
                    input_graph.roi_name                      = roi_name;
                    input_graph.name_f1                       = name_f1;
                    input_graph.name_f2                       = name_f2;
                    input_graph.levels_f1                     = levels_f1;
                    input_graph.levels_f2                     = levels_f2;
                    input_graph.ersp_tf                       = ersp_tf;
                    input_graph.times                         = times;
                    input_graph.freqs                         = freqs;
                    input_graph.pcond_corr                    = pcond_corr;
                    input_graph.pgroup_corr                   = pgroup_corr;
                    input_graph.pinter_corr                   = pinter_corr;
                    input_graph.set_caxis                     = set_caxis;
                    input_graph.study_ls                      = study_ls;
                    input_graph.plot_dir                      = plot_dir;
                    input_graph.freq_scale                    = freq_scale;
                    input_graph.display_only_significant      = display_only_significant;
                    input_graph.display_only_significant_mode = display_only_significant_mode;
                    input_graph.ersp_measure                  = ersp_measure;
                    input_graph.group_time_windows_list       = group_time_windows_list;
                    input_graph.frequency_bands_list          = frequency_bands_list;
                    input_graph.display_pmode                 = display_pmode;
                    input_graph.display_compact_plots         = display_compact_plots;
                    
                    eeglab_study_roi_ersp_tf_graph(input_graph)
                end
                
                
                
                
                ersp_tf_stat.data(nroi).roi_name=roi_name;
                ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                ersp_tf_stat.data(nroi).pcond=pcond;
                ersp_tf_stat.data(nroi).pgroup=pgroup;
                ersp_tf_stat.data(nroi).pinter=pinter;
            end
            
            %% time frequency representation with lowered time resolution and raw frequency resolution
        case 'decimate_times'  % if decimation_factor_times > 1 &&  decimation_factor_freqs == 1
            for nroi = 1:length(roi_names)
                
                roi_channels=roi_list{nroi};
                roi_name=roi_names{nroi};
                
                input_calc.STUDY                         = STUDY;
                input_calc.ALLEEG                        = ALLEEG;
                input_calc.channels_list                 = roi_channels;
                input_calc.levels_f1                     = levels_f1;
                input_calc.levels_f2                     = levels_f2;
                input_calc.num_permutations              = num_permutations;
                input_calc.stat_time_windows_list        = stat_time_windows_list;
                input_calc.paired                        = paired_list{design_num};
                input_calc.stat_method                   = stat_method;
                input_calc.decimation_factor_times       = decimation_factor_times;
                input_calc.list_select_subjects          = list_select_subjects;
                input_calc.list_design_subjects          = list_design_subjects;
                input_calc.ersp_measure                  = ersp_measure;
                input_calc.num_tails                     = num_tails;
                input_calc.stat_freq_bands_list          = stat_freq_bands_list;
                input_calc.mask_coef                     = mask_coef;
                
                
                [output_calc] = eeglab_study_roi_ersp_tf_decimate_times(input_calc);
                
                ersp_tf = output_calc.ersp_tf;
                times   = output_calc.times;
                freqs   = output_calc.freqs;
                pcond   = output_calc.pcond;
                pgroup  = output_calc.pgroup;
                pinter  = output_calc.pinter;
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                         = STUDY;
                    input_graph.design_num                    = design_num;
                    input_graph.roi_name                      = roi_name;
                    input_graph.name_f1                       = name_f1;
                    input_graph.name_f2                       = name_f2;
                    input_graph.levels_f1                     = levels_f1;
                    input_graph.levels_f2                     = levels_f2;
                    input_graph.ersp_tf                       = ersp_tf;
                    input_graph.times                         = times;
                    input_graph.freqs                         = freqs;
                    input_graph.pcond_corr                    = pcond_corr;
                    input_graph.pgroup_corr                   = pgroup_corr;
                    input_graph.pinter_corr                   = pinter_corr;
                    input_graph.set_caxis                     = set_caxis;
                    input_graph.study_ls                      = study_ls;
                    input_graph.plot_dir                      = plot_dir;
                    input_graph.freq_scale                    = freq_scale;
                    input_graph.display_only_significant      = display_only_significant;
                    input_graph.display_only_significant_mode = display_only_significant_mode;
                    input_graph.ersp_measure                  = ersp_measure;
                    input_graph.group_time_windows_list       = group_time_windows_list;
                    input_graph.frequency_bands_list          = frequency_bands_list;
                    input_graph.display_pmode                 = display_pmode;
                    
                    eeglab_study_roi_ersp_tf_graph(input_graph)
                end
                
                ersp_tf_stat.data(nroi).roi_name=roi_name;
                ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                ersp_tf_stat.data(nroi).pcond=pcond;
                ersp_tf_stat.data(nroi).pgroup=pgroup;
                ersp_tf_stat.data(nroi).pinter=pinter;
            end
            
            %% time frequency representation with raw time resolution and lowered frequency resolution
            
        case 'decimate_freqs' % if decimation_factor_times == 1 &&  decimation_factor_freqs > 1
            for nroi = 1:length(roi_names)
                
                roi_channels=roi_list{nroi};
                roi_name=roi_names{nroi};
                
                input_calc.STUDY                            = STUDY;
                input_calc.ALLEEG                           = ALLEEG;
                input_calc.channels_list                     = roi_channels;
                input_calc.levels_f1                        = levels_f1;
                input_calc.levels_f2                        = levels_f2;
                input_calc.num_permutations                 = num_permutations;
                input_calc.stat_time_windows_list           = stat_time_windows_list;
                input_calc.paired                           = paired_list{design_num};
                input_calc.stat_method                      = stat_method;
                input_calc.decimation_factor_freqs          = decimation_factor_freqs;
                input_calc.list_select_subjects             = list_select_subjects;
                input_calc.list_design_subjects             = list_design_subjects;
                input_calc.ersp_measure                     = ersp_measure;
                input_calc.num_tails                        = num_tails;
                input_calc.stat_freq_bands_list             = stat_freq_bands_list;
                input_calc.mask_coef                        = mask_coef;
                
                [output_calc] = eeglab_study_roi_ersp_tf_decimate_freqs(input_calc);
                
                ersp_tf = output_calc.ersp_tf;
                times   = output_calc.times;
                freqs   = output_calc.freqs;
                pcond   = output_calc.pcond;
                pgroup  = output_calc.pgroup;
                pinter  = output_calc.pinter;
                
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                         = STUDY;
                    input_graph.design_num                    = design_num;
                    input_graph.roi_name                      = roi_name;
                    input_graph.name_f1                       = name_f1;
                    input_graph.name_f2                       = name_f2;
                    input_graph.levels_f1                     = levels_f1;
                    input_graph.levels_f2                     = levels_f2;
                    input_graph.ersp_tf                       = ersp_tf;
                    input_graph.times                         = times;
                    input_graph.freqs                         = freqs;
                    input_graph.pcond_corr                    = pcond_corr;
                    input_graph.pgroup_corr                   = pgroup_corr;
                    input_graph.pinter_corr                   = pinter_corr;
                    input_graph.set_caxis                     = set_caxis;
                    input_graph.study_ls                      = study_ls;
                    input_graph.plot_dir                      = plot_dir;
                    input_graph.freq_scale                    = freq_scale;
                    input_graph.display_only_significant      = display_only_significant;
                    input_graph.display_only_significant_mode = display_only_significant_mode;
                    input_graph.ersp_measure                  = ersp_measure;
                    input_graph.group_time_windows_list       = group_time_windows_list;
                    input_graph.frequency_bands_list          = frequency_bands_list;
                    input_graph.display_pmode                 = display_pmode;
                    
                    eeglab_study_roi_ersp_tf_graph(input_graph)
                end                
                
                ersp_tf_stat.data(nroi).roi_name=roi_name;
                ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                ersp_tf_stat.data(nroi).pcond=pcond;
                ersp_tf_stat.data(nroi).pgroup=pgroup;
                ersp_tf_stat.data(nroi).pinter=pinter;
            end
            
            %% time frequency representation with lowered time resolution and lowered frequency resolution
        case 'decimate_times_freqs' %if decimation_factor_times > 1 &&  decimation_factor_freqs > 1
            for nroi = 1:length(roi_names)
                
                roi_channels=roi_list{nroi};
                roi_name=roi_names{nroi};
                
                input_calc.STUDY                   = STUDY;
                input_calc.ALLEEG                  = ALLEEG;
                input_calc.channels_list           = roi_channels;
                input_calc.levels_f1               = levels_f1;
                input_calc.levels_f2               = levels_f2;
                input_calc.num_permutations        = num_permutations;
                input_calc.stat_time_windows_list  = stat_time_windows_list;
                input_calc.paired                  = paired_list{design_num};
                input_calc.stat_method             = stat_method;
                input_calc.decimation_factor_times = decimation_factor_times;
                input_calc.decimation_factor_freqs = decimation_factor_freqs;
                input_calc.list_select_subjects    = list_select_subjects;
                input_calc.list_design_subjects    = list_design_subjects;
                input_calc.ersp_measure            = ersp_measure;
                input_calc.num_tails               = num_tails;
                input_calc.stat_freq_bands_list    = stat_freq_bands_list;
                input_calc.mask_coef               = mask_coef;
                
                [output_calc] = eeglab_study_roi_ersp_tf_decimate_tf(input_calc);
                
                ersp_tf = output_calc.ersp_tf;
                times   = output_calc.times;
                freqs   = output_calc.freqs;
                pcond   = output_calc.pcond;
                pgroup  = output_calc.pgroup;
                pinter  = output_calc.pinter;
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                 if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                         = STUDY;
                    input_graph.design_num                    = design_num;
                    input_graph.roi_name                      = roi_name;
                    input_graph.name_f1                       = name_f1;
                    input_graph.name_f2                       = name_f2;
                    input_graph.levels_f1                     = levels_f1;
                    input_graph.levels_f2                     = levels_f2;
                    input_graph.ersp_tf                       = ersp_tf;
                    input_graph.times                         = times;
                    input_graph.freqs                         = freqs;
                    input_graph.pcond_corr                    = pcond_corr;
                    input_graph.pgroup_corr                   = pgroup_corr;
                    input_graph.pinter_corr                   = pinter_corr;
                    input_graph.set_caxis                     = set_caxis;
                    input_graph.study_ls                      = study_ls;
                    input_graph.plot_dir                      = plot_dir;
                    input_graph.freq_scale                    = freq_scale;
                    input_graph.display_only_significant      = display_only_significant;
                    input_graph.display_only_significant_mode = display_only_significant_mode;
                    input_graph.ersp_measure                  = ersp_measure;
                    input_graph.group_time_windows_list       = group_time_windows_list;
                    input_graph.frequency_bands_list          = frequency_bands_list;
                    input_graph.display_pmode                 = display_pmode;
                    
                    eeglab_study_roi_ersp_tf_graph(input_graph)
                 end
                
                ersp_tf_stat.data(nroi).roi_name=roi_name;
                ersp_tf_stat.data(nroi).roi_channels=roi_channels;
                ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                ersp_tf_stat.data(nroi).pcond=pcond;
                ersp_tf_stat.data(nroi).pgroup=pgroup;
                ersp_tf_stat.data(nroi).pinter=pinter;
            end
            
            %% time frequency representation with free grouping in time (using time
            % windows) and in frequency (using frequency bands).  both
            % time windows can frequency bands can overlap (are automatically
            % sorted)
        case 'tw_fb' % if ~isempty(group_time_windows_list) && ~isempty(frequency_bands_list) && decimation_factor_times == 1 &&  decimation_factor_freqs == 1
            
            for nroi = 1:length(roi_names)
                
                roi_channels=roi_list{nroi};
                roi_name=roi_names{nroi};
                
                input_calc.STUDY 			= STUDY;
                input_calc.ALLEEG 			= ALLEEG;
                input_calc.channels_list 		= roi_channels;
                input_calc.levels_f1 		= levels_f1;
                input_calc.levels_f2 		= levels_f2;
                input_calc.time_windows_list 	= group_time_windows_list{design_num};
                input_calc.frequency_bands_list = frequency_bands_list;
                input_calc.num_permutations 	= num_permutations;
                input_calc.paired 			= paired_list{design_num};
                input_calc.stat_method 		= stat_method;
                input_calc.list_select_subjects = list_select_subjects;
                input_calc.list_design_subjects = list_design_subjects;
                input_calc.ersp_measure 		= ersp_measure;
                input_calc.num_tails 		= num_tails;
                
                [output_calc]= eeglab_study_roi_ersp_tf_tw_fb(input_calc);
                
                
                ersp_tf = output_calc.ersp_tf;
                times   = output_calc.times;
                freqs   = output_calc.freqs;
                pcond   = output_calc.pcond;
                pgroup  = output_calc.pgroup;
                pinter  = output_calc.pinter;
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                
                if (strcmp(do_plots,'on'))
                
                    input_graph.STUDY                              = STUDY; 
                    input_graph.design_num                         = design_num; 
                    input_graph.roi_name                           = roi_name; 
                    input_graph.name_f1                            = name_f1; 
                    input_graph.name_f2                            = name_f2; 
                    input_graph.levels_f1                          = levels_f1;
                    input_graph.levels_f2                          = levels_f2; 
                    input_graph.ersp_tf                            = ersp_tf; 
                    input_graph.times                              = times; 
                    input_graph.freqs                              = freqs; 
                    input_graph.pcond_corr                         = pcond_corr; 
                    input_graph.pgroup_corr                        = pgroup_corr; 
                    input_graph.pinter_corr                        = pinter_corr;
                    input_graph.set_caxis                          = set_caxis;
                    input_graph.study_ls                           = study_ls; 
                    input_graph.time_windows_names                 = group_time_windows_names{design_num}; 
                    input_graph.frequency_bands_names              = frequency_bands_names;
                    input_graph.plot_dir                           = plot_dir;
                    input_graph.freq_scale                         = freq_scale;
                    input_graph.display_only_significant           = display_only_significant;
                    input_graph.display_only_significant_mode      = display_only_significant_mode;
                    input_graph.ersp_measure                       = ersp_measure;
                    input_graph.display_pmode                      = display_pmode;
                    
                    eeglab_study_roi_ersp_tf_tw_fb_graph(input_graph)
                end
                
                
                ersp_tf_stat.data(nroi).roiname=roi_names{nroi};
                ersp_tf_stat.data(nroi).ersp_tf=ersp_tf;
                ersp_tf_stat.data(nroi).pcond=pcond;
                ersp_tf_stat.data(nroi).pgroup=pgroup;
                ersp_tf_stat.data(nroi).pinter=pinter;
            end
            
        otherwise
            disp(['variable ersp_tf_resolution_mode (' ersp_tf_resolution_mode ') was not properly defined']);
            return
    end
    
    ersp_tf_stat.times=times;
    ersp_tf_stat.freqs=freqs;
    ersp_tf_stat.selected_time_windows_list=group_time_windows_list;
    ersp_tf_stat.selected_frequency_bands_list=frequency_bands_list;
    ersp_tf_stat.selected_time_windows_names=group_time_windows_names;
    ersp_tf_stat.list_design_subjects = output_calc.list_design_subjects;
    
    save(fullfile(plot_dir,'ersp_tf-stat.mat'),'ersp_tf_stat','project');
    
end
end
