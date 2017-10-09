%% [output] = eeglab_study_plot_erp_headplot_tw_compact(input)
%
%
% calculate and display erp topographic distribution for groups of scalp channels
% consdered as regions of interests (ROI) in an EEGLAB STUDY with statistical
% comparisons based on the factors in the selected design.
% Use a representation with both time series (boxplot or errorbar) and
% topographic location with pairwise statistic comparisons
%
% project                                                                    = input.project;
% study_path                                                                 = input.study_path;
% design_num_vec                                                             = input.design_num_vec;
% design_factors_ordered_levels                                              = input.design_factors_ordered_levels;
% results_path                                                               = input.results_path;
% analysis_name                                                              = input.analysis_name;
% roi_list                                                                   = input.roi_list;
% roi_names                                                                  = input.roi_names;
% group_time_windows_list                                                    = input.group_time_windows_list;
% group_time_windows_names                                                   = input.group_time_windows_names;
% subject_time_windows_list                                                  = input.subject_time_windows_list;
% study_ls                                                                   = input.study_ls;
% num_permutations                                                           = input.num_permutations;
% correction                                                                 = input.correction;
% set_caxis                                                                  = input.set_caxis;
% paired_list                                                                = input.paired_list;
% stat_method                                                                = input.stat_method;
% display_only_significant_topo                                              = input.display_only_significant_topo;
% display_only_significant_topo_mode                                         = input.display_only_significant_topo_mode;
% display_compact_topo                                                       = input.display_compact_topo;
% display_compact_topo_mode                                                  = input.display_compact_topo_mode;
% list_select_subjects                                                       = input.list_select_subjects;
% mode                                                                       = input.mode;
% show_head                                                                  = input.show_head;
% do_plots                                                                   = input.do_plots;
% compact_display_ylim                                                       = input.compact_display_ylim;
% num_tails                                                                  = input.num_tails;
% show_text                                                                  = input.show_text;
% compact_display_h0                                                         = input.compact_display_h0;
% compact_display_v0                                                         = input.compact_display_v0;
% compact_display_sem                                                        = input.compact_display_sem;
% compact_display_stats                                                      = input.compact_display_stats;
% compact_display_xlim                                                       = input.compact_display_xlim;
% display_single_subjects                                                    = input.display_single_subjects;
% z_transform                                                                = input.z_transform;



function [output] = eeglab_study_plot_erp_headplot_tw_compact(input)

if nargin < 1
    help eeglab_study_plot_erp_headplot_tw_compact;
    return;
end;

project                                                                    = input.project;
study_path                                                                 = input.study_path;
design_num_vec                                                             = input.design_num_vec;
results_path                                                               = input.results_path;
analysis_name                                                              = input.analysis_name;
group_time_windows_list                                                    = input.group_time_windows_list;
group_time_windows_names                                                   = input.group_time_windows_names;
set_caxis                                                                  = input.set_caxis;
list_select_subjects                                                       = input.list_select_subjects;
do_plots                                                                   = input.do_plots;
z_transform                                                                = input.z_transform;
view_list                                                                  = input.view_list;



[study_path,study_name_noext,study_ext] = fileparts(study_path);

%% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

%%channels locations
locs = eeg_mergelocs(ALLEEG.chanlocs);
locs_labels={locs.labels};


file_spline = fullfile(STUDY.filepath, 'spline_file_montage.spl');


for design_num=design_num_vec
    
    str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
    plot_dir=fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-erp_headplot_tw','_',str]);
    mkdir(plot_dir);
    
    
    erp_headplot.study_des               = STUDY.design(design_num);
    
    
    name_f1                                    = STUDY.design(design_num).variable(1).label;
    name_f2                                    = STUDY.design(design_num).variable(2).label;
    
    levels_f1                                  = STUDY.design(design_num).variable(1).value;
    levels_f2                                  = STUDY.design(design_num).variable(2).value;
    
    erp_headplot.study_des                    = STUDY.design(design_num);
    erp_headplot.study_des.num                = design_num;
    erp_headplot.group_time_windows_names     = group_time_windows_names;
    erp_headplot.group_time_windows_list      = group_time_windows_list;
    
    group_time_windows_list_design             = group_time_windows_list{design_num};
    group_time_windows_names_design            = group_time_windows_names{design_num};
    
    list_design_subjects                       = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);
    
    erp_headplot.list_design_subjects    = list_design_subjects;
    
    
    
    % select the study design for the analyses
    STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
    
    
    for nwin=1:length(group_time_windows_list_design)
        
        % lista dei soggetti che partecipano di quel design
        list_design_subjects            = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);
        
        STUDY = pop_erpparams(STUDY, 'topotime',group_time_windows_list_design{nwin});
        
        time_window=group_time_windows_list_design{nwin};
        time_window_name=group_time_windows_names_design{nwin};
        
        STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');
        
        % calculate erp in the channels corresponding to the selected roi
        [STUDY, erp_headplot_tw, ~]=std_erpplot_corr(STUDY,ALLEEG,'channels',locs_labels,'noplot','on');
        
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                if ~isempty(list_select_subjects)
                    vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                    if ~sum(vec_select_subjects)
                        dis('Error: the selected subjects are not represented in the selected design')
                        return;
                    end
                    erp_headplot_tw{nf1,nf2}=erp_headplot_tw{nf1,nf2}(:,:,vec_select_subjects);
                    list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
                    
                end
            end
        end
        
        if (strcmp(do_plots,'on'))
            
            
            
            
            
          
            
            input_graph.erp_headplot_tw                                = erp_headplot_tw;
            input_graph.set_caxis                                      = set_caxis;
            input_graph.name_f1                                        = name_f1;
            input_graph.name_f2                                        = name_f2;
            input_graph.levels_f1                                      = levels_f1;
            input_graph.levels_f2                                      = levels_f2;
            input_graph.time_window_name                               = time_window_name;
            input_graph.plot_dir                                       = plot_dir;
            input_graph.z_transform                                    = z_transform;
            %             input_graph.file_spline                                    = file_spline; % '/home/campus/behaviourPlatform/VisuoHaptic/ABBI_EEG/ABBI_EEG_st/af_AS_mc_s-s1-1sc-1tc.spl'
            %             input_graph.view                                           = view; %[0 45]
            
            
            input_graph.file_spline                                    =  file_spline;%'/home/campus/behaviourPlatform/VisuoHaptic/ABBI_EEG/ABBI_EEG_st/af_AS_mc_s-s1-1sc-1tc.spl';
            input_graph.view_list                                      =  view_list;
            
            eeglab_study_erp_headplot_graph(input_graph);
            
            erp_headplot.tw(nwin).data = erp_headplot_tw;
            
        end
    end
    
    
    %% EXPORTING DATA AND RESULTS OF ANALYSIS
    out_file_name=fullfile(plot_dir,'erp_headplot')
    save([out_file_name,'.mat'],'erp_headplot','erp_headplot','project');
    
    
    output.STUDY =  STUDY;
    output.EEG   =  EEG;
end
end