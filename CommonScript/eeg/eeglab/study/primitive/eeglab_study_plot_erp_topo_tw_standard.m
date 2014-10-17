% [STUDY, EEG] = eeglab_study_plot_erp_topo_tw_standard(study_path, ...
%                                                       design_num_vec,...
%                                                       results_path,
%                                                       stat_analysis_suffix,...
%                                                       group_time_windows_list,
%                                                       group_time_windows_names,...
%                                                       study_ls,
%                                                       num_permutations,
%                                                       correction,...
%                                                       set_caxis,...
%                                                       paired_list,
%                                                       stat_method,...
%                                                       display_only_significant,...
%                                                       display_only_significant_mode,...
%                                                       display_compact_topo,
%                                                       display_compact_mode_topo,...    
%                                                       list_select_subjects,...
%                                                       do_plots)
% calculate and display erp topographic distribution 
% for groups of scalp channels considered as regions of interests (ROI) in 
% an EEGLAB STUDY with statistical comparisons based on the factors in the selected design.
% Use a standard EEGLAB representation and statistics: only time topographic representation       


function [STUDY, EEG] = eeglab_study_plot_erp_topo_tw_standard(study_path, design_num_vec,...
                                                          results_path,stat_analysis_suffix,...
                                                          group_time_windows_list,group_time_windows_names,...
                                                          study_ls,num_permutations,correction,...
                                                          set_caxis,...
                                                          paired_list,stat_method,...
                                                          display_only_significant,display_only_significant_mode,...
                                                          display_compact_topo,display_compact_mode_topo,...    
                                                          list_select_subjects,do_plots, num_tails)
                   
  
    if nargin < 1
       help eeglab_study_plot_erp_topo_tw_standard;
            return;
    end;
             

     erp_topo_tw_roi_avg=[];
     compcond=[];
     compgroup=[];
     roi_name=[];
     roi_mask=[];

    [study_path,study_name_noext,study_ext] = fileparts(study_path);    

    % start EEGLab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    % load the study and working with the study structure 
    [STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);

    
    % channels locations    
    chanlocs = eeg_mergelocs(ALLEEG.chanlocs);
    
    
     for design_num=design_num_vec
    
            plot_dir=fullfile(results_path,stat_analysis_suffix,[STUDY.design(design_num).name,'-erp_topo_tw','-',datestr(now,30)]);
            mkdir(plot_dir);            
            
            % select the study design for the analyses
            STUDY                           = std_selectdesign(STUDY, ALLEEG, design_num);    
            
            % lista dei soggetti che partecipano di quel design
            list_design_subjects            = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);  

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

                % set parameters for a topographic represntation    
                 STUDY = pop_erpparams(STUDY, 'topotime',group_time_windows_list_design{nwin});

                 time_window=group_time_windows_list_design{nwin};
                 time_window_name=group_time_windows_names_design{nwin};

                 STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');

                 % calculate erp in the channels corresponding to the selected roi	
                 [STUDY erp_topo_tw times]=std_erpplot(STUDY,ALLEEG,'channels',{STUDY.changrp.name},'noplot','on');
                 
                for nf1=1:length(levels_f1)
                    for nf2=1:length(levels_f2)
                        if ~isempty(list_select_subjects)
                            vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                            if ~sum(vec_select_subjects)
                                dis('Error: the selected subjects are not represented in the selected design')
                                return;
                            end                        
                            erp_topo_tw{nf1,nf2}=erp_topo_tw{nf1,nf2}(:,:,vec_select_subjects);
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
                    eeglab_study_erp_topo_graph(STUDY, design_num,erp_topo_tw,set_caxis, chanlocs, name_f1, name_f2, levels_f1,levels_f2,...
                                                     time_window_name,time_window, ...                                                
                                                     pcond, pgroup, pinter,study_ls,...
                                                     plot_dir,display_only_significant,display_only_significant_mode,...
                                                     display_compact_topo,display_compact_mode_topo,...
                                                     erp_topo_tw_roi_avg,...
                                                     compcond, compgroup,...
                                                     roi_name, roi_mask...
                                                     );
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
            save(fullfile(plot_dir,'erp_topo_tw-stat.mat'),'erp_topo_tw_stat');

     
     end
end