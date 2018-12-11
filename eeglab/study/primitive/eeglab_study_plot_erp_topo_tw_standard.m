%% [output] = eeglab_study_plot_erp_topo_tw_standard(input)
%
% calculate and display erp topographic distribution
% for groups of scalp channels considered as regions of interests (ROI) in
% an EEGLAB STUDY with statistical comparisons based on the factors in the selected design.
% Use a standard EEGLAB representation and statistics: only time topographic representation
%
% study_path                                                                 = input.study_path;
% design_num_vec                                                             = input.design_num_vec;
% results_path                                                               = input.results_path;
% analysis_name                                                       = input.analysis_name;
% group_time_windows_list                                                    = input.group_time_windows_list;
% group_time_windows_names                                                   = input.group_time_windows_names;
% study_ls                                                                   = input.study_ls;
% num_permutations                                                           = input.num_permutations;
% correction                                                                 = input.correction;
% set_caxis                                                                  = input.set_caxis;
% paired_list                                                                = input.paired_list;
% stat_method                                                                = input.stat_method;
% display_only_significant                                                   = input.display_only_significant;
% display_only_significant_mode                                              = input.display_only_significant_mode;
% display_compact_topo                                                       = input.display_compact_topo;
% display_compact_mode_topo                                                  = input.display_compact_mode_topo;
% list_select_subjects                                                       = input.list_select_subjects;
% do_plots                                                                   = input.do_plots;
% num_tails                                                                  = input.num_tails;
%
% output.STUDY                                                               = STUDY;
% output.EEG                                                                 = EEG;
%
function [output] = eeglab_study_plot_erp_topo_tw_standard(input)


if nargin < 1
    help eeglab_study_plot_erp_topo_tw_standard;
    return;
end;


study_path                                                                 = input.study_path;
design_num_vec                                                             = input.design_num_vec;
results_path                                                               = input.results_path;
analysis_name                                                              = input.analysis_name;
group_time_windows_list                                                    = input.group_time_windows_list;
group_time_windows_names                                                   = input.group_time_windows_names;
study_ls                                                                   = input.study_ls;
num_permutations                                                           = input.num_permutations;
correction                                                                 = input.correction;
set_caxis                                                                  = input.set_caxis;
paired_list                                                                = input.paired_list;
stat_method                                                                = input.stat_method;
display_only_significant                                                   = input.display_only_significant;
display_only_significant_mode                                              = input.display_only_significant_mode;
display_compact_topo                                                       = input.display_compact_topo;
display_compact_mode_topo                                                  = input.display_compact_mode_topo;
list_select_subjects                                                       = input.list_select_subjects;
do_plots                                                                   = input.do_plots;
num_tails                                                                  = input.num_tails;
roi_list                                                                   = input.roi_list;
roi_names                                                                  = input.roi_names;
z_transform                                                                = input.z_transform;                                                   
project                                                                    = input.project;

erp_topo_tw_roi_avg=[];
compcond=[];
compgroup=[];
% roi_name=[];
% roi_mask=[];

[study_path,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);


% channels locations
chanlocs = eeg_mergelocs(ALLEEG.chanlocs);

% r1         = unique([roi_list{:}]);
r2         = {chanlocs.labels};
% roi_list   = [roi_list;{r1};{r2}];
% roi_names  = [roi_names, 'all_rois','all_chan'];

% roi_list = [{r1};{r2}];
% roi_names  = {'all_rois','all_chan'};


roi_list = {r2};
roi_names  = {'all_chan'};



for design_num=design_num_vec
    
    for roi_num=1:length(roi_list)
        roi_ch = roi_list{roi_num};
        if length(roi_ch) >1
            roi_name=roi_names{roi_num};
            roi_mask=ismember({chanlocs.labels},roi_ch);
            str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
            plot_dir=fullfile(results_path,analysis_name,[STUDY.design(design_num).name,'-',roi_names{roi_num},'-erp_topo_tw','-',str]);
            mkdir(plot_dir);
            
            % select the study design for the analyses
            STUDY                           = std_selectdesign(STUDY, ALLEEG, design_num);
            
            
            erp_topo_tw_stat.study_des      = STUDY.design(design_num);
            erp_topo_tw_stat.study_des.num  = design_num;
            erp_topo_tw_stat.chanlocs       = chanlocs;
            
            name_f1                         = STUDY.design(design_num).variable(1).label;
            name_f2                         = STUDY.design(design_num).variable(2).label;
            
            levels_f1                       = STUDY.design(design_num).variable(1).value;
            levels_f2                       = STUDY.design(design_num).variable(2).value;
            
            tlf1                            = length(levels_f1);
            tlf2                            = length(levels_f2);
            
            titles                          = eeglab_study_set_subplot_titles(STUDY,design_num);
            
            erp_topo_tw_stat.selected_time_windows_names = group_time_windows_names;
            
            % plot topo map of each band in frequency_bands_list in each time window in design_selected_time_windows_list
            STUDY = pop_statparams(STUDY, 'condstats','on', 'groupstats','on', 'alpha',study_ls,'naccu',num_permutations,'method', stat_method,...
                'mcorrect',correction,'paired',paired_list{design_num});
            
            group_time_windows_list_design=group_time_windows_list{design_num};
            group_time_windows_names_design=group_time_windows_names{design_num};
            
            for nwin=1:length(group_time_windows_list_design)
                
                 % lista dei soggetti che partecipano di quel design
            list_design_subjects            = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);
           
                % set parameters for a topographic represntation
                STUDY = pop_erpparams(STUDY, 'topotime',group_time_windows_list_design{nwin});
                
                time_window=group_time_windows_list_design{nwin};
                time_window_name=group_time_windows_names_design{nwin};
                
                STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');
                
                % calculate erp in the channels corresponding to the selected roi
                [STUDY erp_topo_tw times]=std_erpplot_corr(STUDY,ALLEEG,'channels',roi_ch,'noplot','on');
                
                for nf1=1:length(levels_f1)
                    for nf2=1:length(levels_f2)
                        if ~isempty(list_select_subjects)
                            vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                            if ~sum(vec_select_subjects)
                                dis('Error: the selected subjects are not represented in the selected design')
                                return;
                            end
                            erp_topo_tw{nf1,nf2}=erp_topo_tw{nf1,nf2}(:,:,vec_select_subjects);
                            list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
                            
                        end
                    end
                end
                
                
                
                % calculate statistics
                [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(erp_topo_tw, num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,...
                    'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});
                for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}) ; end;
                for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
                for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end
                
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                                              = STUDY;
                    input_graph.design_num                                         = design_num;
                    input_graph.erp_topo                                           = erp_topo_tw;
                    input_graph.set_caxis                                          = set_caxis;
                    input_graph.chanlocs                                           = chanlocs;
                    input_graph.name_f1                                            = name_f1;
                    input_graph.name_f2                                            = name_f2;
                    input_graph.levels_f1                                          = levels_f1;
                    input_graph.levels_f2                                          = levels_f2;
                    input_graph.time_window_name                                   = time_window_name;
                    input_graph.time_window                                        = time_window;
                    input_graph.pcond                                              = pcond;
                    input_graph.pgroup                                             = pgroup;
                    input_graph.pinter                                             = pinter;
                    input_graph.study_ls                                           = study_ls;
                    input_graph.plot_dir                                           = plot_dir;
                    input_graph.display_only_significant                           = display_only_significant;
                    input_graph.display_only_significant_mode                      = display_only_significant_mode;
                    input_graph.display_compact                                    = display_compact_topo;
                    input_graph.display_compact_mode                               = display_compact_mode_topo;
                    input_graph.erp_topo_tw_roi_avg                                = erp_topo_tw_roi_avg;
                    input_graph.compcond                                           = compcond;
                    input_graph.compgroup                                          = compgroup;
                    input_graph.roi_name                                           = roi_name;
                    input_graph.roi_mask                                           = roi_mask;
                    input_graph.show_head                                          = [];
                    input_graph.compact_display_ylim                               = [];
                    input_graph.show_text                                          = [];
                    input_graph.z_transform                                        = z_transform;
                    
                    eeglab_study_erp_topo_graph(input_graph);
                end
                
                erp_topo_tw_stat.datatw(nwin).time_window_name= time_window_name;
                erp_topo_tw_stat.datatw(nwin).time_window= time_window;
                erp_topo_tw_stat.datatw(nwin).erp_topo=erp_topo_tw;
                
                erp_topo_tw_stat.datatw(nwin).pcond=pcond;
                erp_topo_tw_stat.datatw(nwin).pgroup=pgroup;
                erp_topo_tw_stat.datatw(nwin).pinter=pinter;
                
                erp_topo_tw_stat.datatw(nwin).pcond_corr=pcond_corr;
                erp_topo_tw_stat.datatw(nwin).pgroup_corr=pgroup_corr;
                erp_topo_tw_stat.datatw(nwin).pinter_corr=pinter_corr;
                
            end
            save(fullfile(plot_dir,'erp_topo_tw-stat.mat'),'erp_topo_tw_stat','project');
            output.STUDY = STUDY;
            output.EEG   = EEG;
        end
    end
end
end
