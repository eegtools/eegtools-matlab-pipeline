%% [output] = eeglab_study_plot_ersp_topo_tw_fb_standard(input)
% calculate and display ersp topographic distribution (in a set of frequency bands)
% for groups of scalp channels considered as regions of interests (ROI) in
% an EEGLAB STUDY with statistical comparisons based on the factors in the selected design.
% Use a standard EEGLAB representation and statistics: only time topographic representation
%
%
%NOTE it is not implemented narrowband because it works on the whole scalp,
% therefore it's not simple to define the subject-based ajustment which is
% strongly based on ROI. Possibly in the future it will added the
% possibility of the operator to select a ROI (despite the representation has not much sense).
%
% study_path                                                                 = input.study_path;
% design_num_vec                                                             = input.design_num_vec;
% results_path                                                               = input.results_path;
% stat_analysis_suffix                                                       = input.stat_analysis_suffix;
% group_time_windows_list                                                    = input.group_time_windows_list;
% group_time_windows_names                                                   = input.group_time_windows_names;
% frequency_bands_list                                                       = input.frequency_bands_list;
% frequency_bands_names                                                      = input.frequency_bands_names;
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
% ersp_measure                                                               = input.ersp_measure;
% subjects_data                                                              = input.subjects_data;
% do_plots                                                                   = input.do_plots;
% num_tails                                                                  = input.num_tails;
%
% output.STUDY                                                               = STUDY;
% output.EEG                                                                 = EEG;
%


function [output] = eeglab_study_plot_ersp_topo_tw_fb_standard(input)
if nargin < 1
    help eeglab_study_plot_ersp_topo_tw_fb_standard;
    return;
end;


study_path                                                                 = input.study_path;
design_num_vec                                                             = input.design_num_vec;
results_path                                                               = input.results_path;
stat_analysis_suffix                                                       = input.stat_analysis_suffix;
group_time_windows_list                                                    = input.group_time_windows_list;
group_time_windows_names                                                   = input.group_time_windows_names;
frequency_bands_list                                                       = input.frequency_bands_list;
frequency_bands_names                                                      = input.frequency_bands_names;
study_ls                                                                   = input.study_ls;
num_permutations                                                           = input.num_permutations;
correction                                                                 = input.correction;
set_caxis                                                                  = input.set_caxis;
paired_list                                                                = input.paired_list;
stat_method                                                                = input.stat_method;
display_only_significant_topo                                              = input.display_only_significant_topo;
display_only_significant_topo_mode                                         = input.display_only_significant_topo_mode;
display_compact_topo                                                       = input.display_compact_topo;
display_compact_topo_mode                                                  = input.display_compact_topo_mode;
list_select_subjects                                                       = input.list_select_subjects;
ersp_measure                                                               = input.ersp_measure;
subjects_data                                                              = input.subjects_data;
do_plots                                                                   = input.do_plots;
num_tails                                                                  = input.num_tails;
roi_list                                                                   = input.roi_list;
roi_names                                                                  = input.roi_names;
project                                                                    = input.project;


ersp_topo_tw_fb_roi_avg=[];
compcond=[];
compgroup=[];


%      display_compact='off';
z_transform='off';

[study_path,study_name_noext,study_ext] = fileparts(study_path);

% start EEGLab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

% load the study and working with the study structure
[STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

% channels locations
locs = eeg_mergelocs(ALLEEG.chanlocs);

r1         = unique([roi_list{:}]);
r2         = {locs.labels};
% roi_list   = [roi_list;{r1};{r2}];
% roi_names  = [roi_names, 'all_rois','all_chan'];

roi_list = {r2};%[{r1};{r2}];
roi_names  = {'all_chan'};


for design_num=design_num_vec
    
    for roi_num=1:length(roi_list)
        roi_ch = roi_list{roi_num};
        if length(roi_ch) >1
            roi_name=roi_names{roi_num};
            roi_mask=ismember({locs.labels},roi_ch);
            
            str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
            
            plot_dir=fullfile(results_path,stat_analysis_suffix,[STUDY.design(design_num).name,'-',roi_names{roi_num},'-ersp_topo_tw_fb_standard','-', display_compact_topo_mode,'-',display_only_significant_topo_mode, '-', str]);
            mkdir(plot_dir);
            
            % select the study design for the analyses
            STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
            
            % lista dei soggetti suddivisi per fattori
            individual_fb_bands    = eeglab_generate_subjects_bands_by_factor_levels(STUDY, design_num, subjects_data, frequency_bands_list);  ... {factor1,factor2}{subj}{band}
                
        
        ersp_topo_stat.individual_fb_bands      = individual_fb_bands;
        
        ersp_topo_stat.study_des                = STUDY.design(design_num);
        ersp_topo_stat.study_des.num            = design_num;
        ersp_topo_stat.group_time_windows_names = group_time_windows_names;
        ersp_topo_stat.group_time_windows_list  = group_time_windows_list;
        ersp_topo_stat.frequency_bands_names    = frequency_bands_names;
        ersp_topo_stat.frequency_bands_list     = frequency_bands_list;
        
        % exctract names of the factores and the names of the corresponding levels for the selected design
       
        
        name_f1                                 = STUDY.design(design_num).variable(1).label;        
        levels_f1                               = STUDY.design(design_num).variable(1).value;
        name_f2 = [];
        levels_f2 = [];
        if (length(STUDY.design(design_num).variable) > 1)
            name_f2                                 = STUDY.design(design_num).variable(2).label;
            levels_f2                               = STUDY.design(design_num).variable(2).value;

        end
        
        tlf1                                    = length(levels_f1);
        tlf2                                    = length(levels_f2);
        
        titles                                  = eeglab_study_set_subplot_titles(STUDY,design_num);
        
        
        % plot topo map of each band in frequency_bands_list in each time window in design_group_time_windows_list
        STUDY = pop_statparams(STUDY, 'condstats','on', 'groupstats','on', 'alpha',study_ls,'naccu',num_permutations,'method', stat_method,...
            'mcorrect',correction,'paired',paired_list{design_num});
        
        group_time_windows_list_design=group_time_windows_list{design_num};
        group_time_windows_names_design=group_time_windows_names{design_num};
        
        for nband=1:length(frequency_bands_list)
            
            frequency_band_name=frequency_bands_names{nband};
            
            
            for nwin=1:length(group_time_windows_list_design)
                % set parameters for a topographic represntation
                STUDY = pop_erspparams(STUDY, 'topotime',group_time_windows_list_design{nwin} ,'topofreq', frequency_bands_list{nband});
                
                time_window_name=group_time_windows_names_design{nwin};
                time_window=group_time_windows_list_design{nwin};
                
                STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');
                % calculate ersp in the channels corresponding to the selected roi
                [STUDY ersp_topo_tw_fb times freqs]=std_erspplot(STUDY,ALLEEG,'channels',roi_ch,'noplot','on');
                
                list_design_subjects   = eeglab_generate_subjects_list_by_factor_levels(project,STUDY, design_num);

               
                
                % select subjects
                for nf1=1:length(levels_f1)
                    for nf2=1:length(levels_f2)
                        if ~isempty(list_select_subjects)
                            vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                            if ~sum(vec_select_subjects)
                                disp('Error: the selected subjects are not represented in the selected design')
                                return;
                            end
                            ersp_topo_tw_fb{nf1,nf2}=ersp_topo_tw_fb{nf1,nf2}(:,:,vec_select_subjects);
                            filtered_individual_fb_bands{nf1,nf2} = {individual_fb_bands{nf1,nf2}{vec_select_subjects}};
                            list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
                        else
                            filtered_individual_fb_bands{nf1,nf2} = individual_fb_bands{nf1,nf2};
                        end
                    end
                end
                ersp_topo_stat.list_design_subjects     = list_design_subjects;
                
                if strcmp(ersp_measure, 'Pfu')
                    for nf1=1:length(levels_f1)
                        for nf2=1:length(levels_f2)
                            ersp_topo_tw_fb{nf1,nf2}=(10.^(ersp_topo_tw_fb{nf1,nf2}/10)-1)*100;
                        end
                    end
                end
                
                
                % calculate statistics
                [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_topo_tw_fb,num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,...
                    'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});
                for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}) ; end;
                for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
                for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end
                
                
                [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                
                if (strcmp(do_plots,'on'))
                    
                    input_graph.STUDY                                              = STUDY;
                    input_graph.design_num                                         = design_num;
                    input_graph.ersp_topo_tw_fb                                    = ersp_topo_tw_fb;
                    input_graph.set_caxis                                          = set_caxis;
                    input_graph.chanlocs                                           = locs;
                    input_graph.name_f1                                            = name_f1;
                    input_graph.name_f2                                            = name_f2;
                    input_graph.levels_f1                                          = levels_f1;
                    input_graph.levels_f2                                          = levels_f2;
                    input_graph.time_window_name                                   = time_window_name;
                    input_graph.time_window                                        = time_window;
                    input_graph.frequency_band_name                                = frequency_band_name;
                    input_graph.pcond                                              = pcond_corr;
                    input_graph.pgroup                                             = pgroup_corr;
                    input_graph.pinter                                             = pinter_corr;
                    input_graph.study_ls                                           = study_ls;
                    input_graph.plot_dir                                           = plot_dir;
                    input_graph.display_only_significant                           = display_only_significant_topo;
                    input_graph.display_only_significant_mode                      = display_only_significant_topo_mode;
                    input_graph.display_compact                                    = display_compact_topo;
                    input_graph.display_compact_mode                               = display_compact_topo_mode;
                    input_graph.ersp_topo_tw_fb_roi_avg                            = ersp_topo_tw_fb_roi_avg;
                    input_graph.compcond                                           = compcond;
                    input_graph.compgroup                                          = compgroup;
                    input_graph.roi_name                                           = roi_name;
                    input_graph.roi_mask                                           = roi_mask;
                    input_graph.ersp_measure                                       = ersp_measure;
                    input_graph.z_transform                                        = z_transform;
                    input_graph.show_head                                          = [];
                    input_graph.show_text                                          = [];
                    input_graph.compact_display_ylim                               = [];
                    input_graph.which_error_measure                                = [];
                    
                    
                    eeglab_study_ersp_topo_graph(input_graph);
                end
                
                
                
                
                ersp_topo_stat.datatw(nwin).databand(nband).time_window_name=time_window_name;
                ersp_topo_stat.datatw(nwin).databand(nband).time_window=time_window;
                
                ersp_topo_stat.datatw(nwin).databand(nband).frequency_band_name=frequency_band_name;
                ersp_topo_stat.datatw(nwin).databand(nband).frequency_band=frequency_bands_list{nband};
                ersp_topo_stat.datatw(nwin).databand(nband).ersp_topo=ersp_topo_tw_fb;
                
                ersp_topo_stat.datatw(nwin).databand(nband).pcond=pcond;
                ersp_topo_stat.datatw(nwin).databand(nband).pgroup=pgroup;
                ersp_topo_stat.datatw(nwin).databand(nband).pinter=pinter;
                
            end
        end
        
        save(fullfile(plot_dir,'ersp_tf_topo-stat.mat'),'ersp_topo_stat','project');
        output.STUDY = STUDY;
        output.EEG   = EEG;
        end
    end
end
end
