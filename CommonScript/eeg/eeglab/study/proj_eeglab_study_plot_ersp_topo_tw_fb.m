%% [STUDY, EEG] = proj_eeglab_study_plot_ersp_topo_tw_fb(project, analysis_name, mode, varargin)
%
% calculate and display ersp topographic distribution (in a set of frequency bands) 
% for groups of scalp channels considered as regions of interests (ROI) in 
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
% * project.postprocess.ersp.frequency_bands_list;
% * project.postprocess.ersp.frequency_bands_names;    
% * project.stats.ersp.pvalue;
% * project.stats.ersp.num_permutations;
% * project.stats.eeglab.ersp.correction;
% * project.stats.eeglab.ersp.method;  
% * project.results_display.ersp.display_only_significant_topo;
% * project.results_display.ersp.display_only_significant_topo_mode;
% * project.results_display.ersp.set_caxis_topo_tw_fb;
% * project.results_display.ersp.compact_plots_topo;
% * project.results_display.ersp.display_compact_topo_mode;
% * project.stats.ersp.measure;
% * project.postprocess.ersp.design
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
% 'group_time_windows_list','group_time_windows_names','list_select_subjects','show_head','do_plots','compact_display_ylim'
% NOTE for standard modality it is not implemented narrowband because it works on the whole scalp,
% therefore it's not simple to define the subject-based ajustment which is
% strongly based on ROI. Possibly in the future it will added the 
% possibility of the operator to select a ROI (despite the representation has not much sense).
% 
% ====================================================================================================


function [STUDY, EEG] = proj_eeglab_study_plot_ersp_topo_tw_fb(project, analysis_name, mode, varargin)

    if nargin < 1
        help proj_eeglab_study_plot_ersp_topo_tw_fb;
        return;
    end;
                              
    study_path                          = fullfile(project.paths.output_epochs, project.study.filename);
    results_path                        = project.paths.results;
    
    paired_list = cell(length(project.design), 2);
    for ds=1:length(project.design)
        paired_list{ds} = {project.design(ds).factor1_pairing, project.design(ds).factor2_pairing}; 
    end

    %% VARARGIN DEFAULTS
    list_select_subjects                = {};
    design_num_vec                      = [1:length(project.design)];
    
    design_factors_ordered_levels       = {};
    if isfield(project.postprocess,'design_factors_ordered_levels')
        design_factors_ordered_levels       = project.postprocess.design_factors_ordered_levels;
    end
    
    roi_list                            = project.postprocess.ersp.roi_list;
    roi_names                           = project.postprocess.ersp.roi_names;
    
    frequency_bands_list                = project.postprocess.ersp.frequency_bands_list;
    frequency_bands_names               = project.postprocess.ersp.frequency_bands_names;    
    
    study_ls                            = project.stats.ersp.pvalue;
    num_permutations                    = project.stats.ersp.num_permutations;
    correction                          = project.stats.eeglab.ersp.correction;
    stat_method                         = project.stats.eeglab.ersp.method;  
    
    display_only_significant_topo       = project.results_display.ersp.display_only_significant_topo;
    display_only_significant_topo_mode  = project.results_display.ersp.display_only_significant_topo_mode;
    
    set_caxis                           = project.results_display.ersp.set_caxis_topo_tw_fb;

    group_time_windows_list             = arrange_structure(project.postprocess.ersp.design, 'group_time_windows');
    group_time_windows_names            = arrange_structure(project.postprocess.ersp.design, 'group_time_windows_names');
    subject_time_windows_list   = arrange_structure(project.postprocess.ersp.design, 'subject_time_windows');
   
    display_compact_topo                = project.results_display.ersp.compact_plots_topo;
    display_compact_topo_mode           = project.results_display.ersp.display_compact_topo_mode;
    
    ersp_measure                        = project.stats.ersp.measure;
    
    show_head                           = project.results_display.ersp.display_compact_show_head;
    
    do_plots                            = project.results_display.ersp.do_plots;
   compact_display_ylim                 = project.results_display.ersp.compact_display_ylim;
    num_tails                           = project.stats.ersp.num_tails;
    show_text                          = project.results_display.ersp.show_text;
    z_transform                        = project.results_display.ersp.z_transform;
    which_error_measure=project.results_display.ersp.which_error_measure;
do_narrowband=project.stats.ersp.do_narrowband;
    
    for par=1:2:length(varargin)
       switch varargin{par}
           case {'design_num_vec', 'design_factors_ordered_levels', 'analysis_name', 'roi_list', 'roi_names', 'study_ls', 'num_permutations', 'correction', 'stat_method', ...
                   'display_only_significant_topo', 'display_only_significant_topo_mode', 'set_caxis', 'display_compact_topo', 'display_compact_topo_mode', ...
                   'group_time_windows_list','group_time_windows_names','list_select_subjects','show_head','do_plots','compact_display_ylim','num_tails','show_text','z_transform',...
                   'which_error_measure','do_narrowband'}
                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
       end
    end 

    %% representation with both time series (boxplot or errorbar) and topographic location with pairwise statistic comparisons                                                   
    if strcmp(display_compact_topo,'on') 
      [STUDY, EEG] = eeglab_study_plot_ersp_topo_tw_fb_compact(project,study_path, design_num_vec, design_factors_ordered_levels,...
                                                              results_path,analysis_name,...
                                                              roi_list, roi_names,...
                                                              group_time_windows_list,group_time_windows_names,subject_time_windows_list,...
                                                              frequency_bands_list,frequency_bands_names,...
                                                              study_ls,num_permutations,correction,...
                                                              set_caxis,paired_list,stat_method,...
                                                              display_only_significant_topo,display_only_significant_topo_mode,...
                                                              display_compact_topo,display_compact_topo_mode,...
                                                              list_select_subjects,ersp_measure, project.subjects.data,mode,show_head,...
                                                              do_plots,compact_display_ylim,num_tails,show_text,z_transform,which_error_measure,do_narrowband);
      
      
    end
    %% standard EEGLAB representation and statistics: only time topographic representation                                                       
    if strcmp(display_compact_topo,'off') 
     [STUDY, EEG] = eeglab_study_plot_ersp_topo_tw_fb_standard(study_path, design_num_vec, ...
                                                          results_path,analysis_name,...
                                                          group_time_windows_list,group_time_windows_names,...
                                                          frequency_bands_list,frequency_bands_names,...
                                                          study_ls,num_permutations,correction,...
                                                          set_caxis,paired_list,stat_method,...
                                                          display_only_significant_topo,display_only_significant_topo_mode,...
                                                          display_compact_topo,display_compact_topo_mode,...
                                                          list_select_subjects,ersp_measure, project.subjects.data,do_plots,num_tails);

  
    end
    
end
