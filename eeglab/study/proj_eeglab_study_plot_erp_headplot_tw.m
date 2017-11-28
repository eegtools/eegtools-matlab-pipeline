%% [STUDY, EEG] = proj_eeglab_study_plot_erp_topo_tw(project, analysis_name, mode, varargin)
%
% calculate and display erp topographic distribution for groups of scalp channels
% consdered as regions of interests (ROI) in an EEGLAB STUDY
% with statistical comparisons based on the factors in the selected design.
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
% * project.results_display.erp.display_only_significant_topo;
% * project.results_display.erp.display_only_significant_topo_mode;
% * project.results_display.erp.set_caxis_topo_tw;
% * project.results_display.erp.compact_plots_topo;
% * project.results_display.erp.display_compact_topo_mode;
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
% 'design_num_vec', 'design_factors_ordered_levels', 'analysis_name', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', ...
% 'display_only_significant_topo', 'display_only_significant_topo_mode', 'set_caxis', 'display_compact_topo', 'display_compact_topo_mode', ...
% 'group_time_windows_list','group_time_windows_names','list_select_subjects','show_head','do_plots','compact_display_ylim','num_tails'
% ====================================================================================================

function [STUDY, EEG] = proj_eeglab_study_plot_erp_headplot_tw(project, analysis_name,  varargin)

if nargin < 1
    help proj_eeglab_study_plot_erp_topo_tw;
    return;
end;


study_path                      = fullfile(project.paths.output_epochs, project.study.filename);
results_path                    = project.paths.results;

paired_list = cell(length(project.design), 2);
for ds=1:length(project.design)
    paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing};
end

%% VARARGIN DEFAULTS
list_select_subjects                = {};
design_num_vec                      = [1:length(project.design)];

design_factors_ordered_levels       = [];

% roi_list                            = project.postprocess.erp.roi_list;
% roi_names                           = project.postprocess.erp.roi_names;

% study_ls                            = project.stats.erp.pvalue;
% num_permutations                    = project.stats.erp.num_permutations;
% correction                          = project.stats.eeglab.erp.correction;
% stat_method                         = project.stats.eeglab.erp.method;
% 
% display_only_significant_topo       = project.results_display.erp.display_only_significant_topo;
% display_only_significant_topo_mode  = project.results_display.erp.display_only_significant_topo_mode;

set_caxis                           = project.results_display.erp.set_caxis_topo_tw;

group_time_windows_list             = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
group_time_windows_names            = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
subject_time_windows_list           = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');


% display_compact_topo                = project.results_display.erp.compact_plots_topo;
% display_compact_topo_mode           = project.results_display.erp.display_compact_topo_mode;
% show_head                           = project.results_display.erp.display_compact_show_head;
do_plots                            = project.results_display.erp.do_plots;
% compact_display_ylim                = project.results_display.erp.compact_display_ylim;
% num_tails                           = project.stats.erp.num_tails;
% show_text                           = project.results_display.erp.show_text;
z_transform                         = project.results_display.erp.z_transform;


%               'view'       - Camera viewpoint in deg. [azimuth elevation]
%                    'back'|'b'=[  0 30]; 'front'|'f'=[180 30] 
%                    'left'|'l'=[-90 30]; 'right'|'r'=[ 90 30];
%                    'frontleft'|'bl','backright'|'br', etc.,
%                    'top'=[0 90],  Can rotate with mouse {default [143 18]}

view_list                          =   [0   30; 
                                        180 30;
                                        -90 30;
                                         90 30;
                                         0  90
                                     ];
if isfield(project.results_display.erp, 'headplot')
    view_list = project.results_display.erp.headplot.view_list;
end
                                 
                                 
% compact_display_h0=project.results_display.erp.compact_h0;
% compact_display_v0=project.results_display.erp.compact_v0;
% compact_display_sem=project.results_display.erp.compact_sem;
% compact_display_stats=project.results_display.erp.compact_stats;
% 
% compact_display_xlim=project.results_display.erp.compact_display_xlim;
% 
% display_single_subjects=project.results_display.erp.single_subjects;


% nb lascio questi varargin in previsione di eventuali estensioni del codice, e.g. plottare solo valori significativamente diversi da zero facendo statistica su mappa scalpo
for par=1:2:length(varargin)
    switch varargin{par}
        case {'design_num_vec', ... 
                'design_factors_ordered_levels', ...
                'analysis_name', ...
                'roi_list', ...
                'roi_names', ...
                'study_ls', ...
                'num_permutations', ...
                'correction', ...
                'stat_method', ...
                'display_only_significant_topo', ...
                'display_only_significant_topo_mode', ...
                'set_caxis', 'display_compact_topo', ...
                'display_compact_topo_mode', ...
                'group_time_windows_list',...
                'group_time_windows_names', ...
                'subject_time_windows_list', ...
                'list_select_subjects', ...
                'show_head', ...
                'do_plots', ...
                'compact_display_ylim', ...
                'num_tails', ...
                'show_text'}
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end





    
    
    input_headplot.project                                                         = project;
    input_headplot.study_path                                                      = study_path;
    input_headplot.design_num_vec                                                  = design_num_vec;
    input_headplot.design_factors_ordered_levels                                   = design_factors_ordered_levels;
    input_headplot.results_path                                                    = results_path;
    input_headplot.analysis_name                                                   = analysis_name;
    input_headplot.group_time_windows_list                                         = group_time_windows_list;
    input_headplot.group_time_windows_names                                        = group_time_windows_names;
    input_headplot.list_select_subjects                                            = list_select_subjects;
    input_headplot.do_plots                                                        = do_plots;
    input_headplot.z_transform                                                     = z_transform;
    input_headplot.set_caxis                                                       = set_caxis;
    input_headplot.view_list                                                       = view_list;

    
    [output_topo] = eeglab_study_plot_erp_headplot_tw_compact(input_headplot);
    STUDY         = output_topo.STUDY;
    EEG           = output_topo.EEG;
    





end
