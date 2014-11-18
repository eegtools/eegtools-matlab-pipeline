%% [STUDY, EEG] = eeglab_study_plot_ersp_topo_tw_fb_standard(study_path,...
%                                                            design_num_vec,...
%                                                            results_path,...
%                                                            stat_analysis_suffix,...
%                                                            group_time_windows_list,...
%                                                            group_time_windows_names,...
%                                                            frequency_bands_list,...
%                                                            frequency_bands_names,...
%                                                            study_ls,...
%                                                            num_permutations,...
%                                                            correction,...
%                                                            set_caxis,...
%                                                            paired_list,...
%                                                            stat_method,...
%                                                            display_only_significant_topo,...
%                                                            display_only_significant_topo_mode,...
%                                                            display_compact_topo,...
%                                                            display_compact_topo_mode,...
%                                                            list_select_subjects,...
%                                                            ersp_measure,...
%                                                            subjects_data,...
%                                                            do_plots)
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


function [STUDY, EEG] = eeglab_study_plot_ersp_topo_tw_fb_standard(study_path, design_num_vec, ...
                                                                  results_path,stat_analysis_suffix,...
                                                                  group_time_windows_list,group_time_windows_names,...
                                                                  frequency_bands_list,frequency_bands_names,...
                                                                  study_ls,num_permutations,correction,...
                                                                  set_caxis,paired_list,stat_method,...
                                                                  display_only_significant_topo,display_only_significant_topo_mode,...
                                                                  display_compact_topo,display_compact_topo_mode,...
                                                                  list_select_subjects,ersp_measure, subjects_data,do_plots,num_tails)
    if nargin < 1
       help eeglab_study_plot_ersp_topo_tw_fb_standard;
       return;
    end;

     ersp_topo_tw_fb_roi_avg=[];
     compcond=[];
     compgroup=[];
     roi_name=[];
     roi_mask=[];
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

    for design_num=design_num_vec
    
        plot_dir=fullfile(results_path,stat_analysis_suffix,[STUDY.design(design_num).name,'-ersp_topo_tw_fb_standard','-', display_compact_topo_mode,'-',display_only_significant_topo_mode, '-', datestr(now,30)]);
        mkdir(plot_dir);
        
        % select the study design for the analyses
        STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
        
        % lista dei soggetti suddivisi per fattori
        list_design_subjects   = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);
        individual_fb_bands    = eeglab_generate_subjects_bands_by_factor_levels(STUDY, design_num, subjects_data, frequency_bands_list);  ... {factor1,factor2}{subj}{band}
                
        ersp_topo_stat.list_design_subjects     = list_design_subjects;
        ersp_topo_stat.individual_fb_bands      = individual_fb_bands;
        
        ersp_topo_stat.study_des                = STUDY.design(design_num);
        ersp_topo_stat.study_des.num            = design_num;                
        ersp_topo_stat.group_time_windows_names = group_time_windows_names;
        ersp_topo_stat.group_time_windows_list  = group_time_windows_list;
        ersp_topo_stat.frequency_bands_names    = frequency_bands_names;
        ersp_topo_stat.frequency_bands_list     = frequency_bands_list;
        
        % exctract names of the factores and the names of the corresponding levels for the selected design
        name_f1                                 = STUDY.design(design_num).variable(1).label;
        name_f2                                 = STUDY.design(design_num).variable(2).label;
        
        levels_f1                               = STUDY.design(design_num).variable(1).value;
        levels_f2                               = STUDY.design(design_num).variable(2).value;
        
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
                [STUDY ersp_topo_tw_fb times freqs]=std_erspplot(STUDY,ALLEEG,'channels',{STUDY.changrp.name},'noplot','on');
                
                
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
                        else
                            filtered_individual_fb_bands{nf1,nf2} = individual_fb_bands{nf1,nf2};
                        end
                    end
                end
                
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
                    
                    eeglab_study_ersp_topo_graph(STUDY, design_num, ersp_topo_tw_fb,set_caxis, locs, name_f1, name_f2, levels_f1,levels_f2,time_window_name,time_window, frequency_band_name, ...
                        pcond_corr, pgroup_corr, pinter_corr,study_ls, plot_dir,...
                        display_only_significant_topo,display_only_significant_topo_mode,...
                        display_compact_topo,display_compact_topo_mode,...
                        ersp_topo_tw_fb_roi_avg,...
                        compcond, compgroup,...
                        roi_name,roi_mask,...
                        ersp_measure,z_transform)
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
        
        save(fullfile(plot_dir,'ersp_tf_topo-stat.mat'),'ersp_topo_stat');
    end
end