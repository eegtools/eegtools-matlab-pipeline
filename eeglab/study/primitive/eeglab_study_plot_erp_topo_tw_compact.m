%% [STUDY, EEG] = eeglab_study_plot_erp_topo_tw_compact(project,study_path, 
%                                                       design_num_vec,... 
%                                                       design_factors_ordered_levels,...
%                                                       results_path,stat_analysis_suffix,...
%                                                       roi_list, roi_names,...                                                             
%                                                       group_time_windows_list,...
%                                                       group_time_windows_names,...                                                              
%                                                       study_ls,...
%                                                       num_permutations,...
%                                                       correction,...
%                                                       set_caxis,...
%                                                       paired_list,stat_method,...
%                                                       display_only_significant_topo,...
%                                                       display_only_significant_topo_mode,...
%                                                       display_compact_topo,...
%                                                       display_compact_topo_mode,...
%                                                       list_select_subjects,
%                                                       mode
%                                                       show_head
%                                                       do_plots,
%                                                       num_tails
%                                                       ,
%                                                       show_text)
%
% 
% calculate and display erp topographic distribution for groups of scalp channels 
% consdered as regions of interests (ROI) in an EEGLAB STUDY with statistical 
% comparisons based on the factors in the selected design. 
% Use a representation with both time series (boxplot or errorbar) and 
% topographic location with pairwise statistic comparisons 


function [STUDY, EEG] = eeglab_study_plot_erp_topo_tw_compact(project,study_path, design_num_vec, design_factors_ordered_levels,...
                                                              results_path,stat_analysis_suffix,...
                                                              roi_list, roi_names,...
                                                              group_time_windows_list,group_time_windows_names,subject_time_windows_list,...                                                              
                                                              study_ls,num_permutations,correction,...
                                                              set_caxis,paired_list,stat_method,...
                                                              display_only_significant_topo,display_only_significant_topo_mode,...
                                                              display_compact_topo,display_compact_topo_mode,...
                                                              list_select_subjects,mode,show_head,do_plots,compact_display_ylim, num_tails,show_text)
                                                          
    if nargin < 1
       help eeglab_study_plot_erp_topo_tw_compact;
            return;
    end;
    
    pcond=[];
    pgroup=[];
    pinter=[];
    
    

    [study_path,study_name_noext,study_ext] = fileparts(study_path);    

    %% start EEGLab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    %% load the study and working with the study structure 
    [STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);
    
    %%channels locations    
    locs = eeg_mergelocs(ALLEEG.chanlocs);
    locs_labels={locs.labels};

%     group_time_windows_list     = arrange_structure(project.postprocess.erp.design, 'group_time_windows');
%     subject_time_windows_list   = arrange_structure(project.postprocess.erp.design, 'subject_time_windows');
%     group_time_windows_names    = arrange_structure(project.postprocess.erp.design, 'group_time_windows_names');
    
        %% ANALYSIS MODALITIES
    if strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'off')
        which_method_find_extrema = 'group_noalign';
    elseif strcmp(mode.peak_type, 'group') && strcmp(mode.align, 'on')
        which_method_find_extrema = 'group_align';
    elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'off')
        which_method_find_extrema = 'individual_noalign';
    elseif strcmp(mode.peak_type, 'individual') && strcmp(mode.align, 'on')  
        which_method_find_extrema = 'individual_align';
    elseif strcmp(mode.peak_type, 'off') 
       display('Error: missing method for dealing with extrema: adopting individual_align')
        which_method_find_extrema = 'individual_align';
    end
    
    tw_stat_estimator           = mode.tw_stat_estimator;       ... mean, extremum
    time_resolution_mode        = mode.time_resolution_mode;    ... continous, tw
    sel_extrema                 = project.postprocess.ersp.sel_extrema;
    
    
    erp_curve_roi_stat.roi_list = roi_list;
    erp_curve_roi_stat.roi_names= roi_names;
    
    erp_topo_stat.roi_list      = roi_list;
    erp_topo_stat.roi_names     = roi_names;
    
    
    for design_num=design_num_vec        
        
          
         plot_dir=fullfile(results_path,stat_analysis_suffix,[STUDY.design(design_num).name,'-erp_topo_tw','-',which_method_find_extrema,'_',datestr(now,30)]);
                mkdir(plot_dir);
         
         
         erp_curve_roi_stat.study_des               = STUDY.design(design_num);
         

         name_f1                                    = STUDY.design(design_num).variable(1).label;
         name_f2                                    = STUDY.design(design_num).variable(2).label;

         levels_f1                                  = STUDY.design(design_num).variable(1).value;
         levels_f2                                  = STUDY.design(design_num).variable(2).value;
         
         erp_topo_stat.study_des                    = STUDY.design(design_num);
         erp_topo_stat.study_des.num                = design_num;
         erp_topo_stat.group_time_windows_names     = group_time_windows_names;
         erp_topo_stat.group_time_windows_list      = group_time_windows_list;    

         group_time_windows_list_design             = group_time_windows_list{design_num};
         group_time_windows_names_design            = group_time_windows_names{design_num};                      
            
         list_design_subjects                       = eeglab_generate_subjects_list_by_factor_levels(STUDY, design_num);       
         erp_topo_stat.list_design_subjects         = list_design_subjects;  
         erp_curve_roi_stat.list_design_subjects    = list_design_subjects;      
                
                
                
                
                
                
                
                
           
                
     %% DOING CLASSICAL ANALYSIS/STATISTICS AND ALLOWING COMPATIBILITY FOR EXPORTING DATA
            
              

         
         
         % set representation to time-frequency representation
         STUDY = pop_erpparams(STUDY, 'topotime',[] ,'plotgroups','apart' ,'plotconditions','apart','averagechan','on','method', stat_method);
                    
        
         % for each roi in the list     
         for nroi = 1:length(roi_list)
            roi_channels=roi_list{nroi};
            roi_name=roi_names{nroi};
            STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');
            
            [STUDY, erp_curve_roi, times]=std_erpplot(STUDY,ALLEEG,'channels',roi_list{nroi},'noplot','on');       

            for nf1=1:length(levels_f1)
                for nf2=1:length(levels_f2)
                    if ~isempty(list_select_subjects)
                        vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                        if ~sum(vec_select_subjects)
                            dis('Error: the selected subjects are not represented in the selected design')
                            return;
                        end                        
                        erp_curve_roi{nf1,nf2}=erp_curve_roi{nf1,nf2}(:,vec_select_subjects);
                    end
                end
            end

          
                group_time_windows_list_design  = group_time_windows_list{design_num};
                group_time_windows_names_design = group_time_windows_names{design_num};
                
                 erp_curve_roi_stat.group_time_windows_list_design = group_time_windows_list_design;
                 erp_curve_roi_stat.group_time_windows_names_design = group_time_windows_names_design; 
                
                
                which_extrema_design            = project.postprocess.erp.design(design_num).which_extrema_curve;
                which_extrema_design_roi        = which_extrema_design{nroi};
                
                if ~eeglab_check_tw_compliancy(group_time_windows_list_design, times);
                    return;
                end
                
                if isempty(which_extrema_design_roi)
                    disp(['which_extrema_design_roi of design num:' num2str(design_num) ' and roi ' roi_name ' is empty']);
                    return;
                end
                
                switch which_method_find_extrema
                    case 'group_noalign'
                        erp_curve_roi_stat.dataroi(nroi).datatw = ...
                            eeglab_study_plot_find_extrema_avg(erp_curve_roi,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi,sel_extrema);                
                    case 'group_align'
                        
                        disp('ERROR: still not implemented!!! adopting individual_align ');
                          subject_time_windows_list_design=subject_time_windows_list{design_num};
                        erp_curve_roi_stat.dataroi(nroi).datatw = ...
                            eeglab_study_plot_find_extrema_single(erp_curve_roi,levels_f1,levels_f2,group_time_windows_list_design,subject_time_windows_list_design,times,which_extrema_design_roi,...
                            sel_extrema);
                      
                    case 'individual_noalign'
                        erp_curve_roi_stat.dataroi(nroi).datatw = ...
                            eeglab_study_plot_find_extrema_gru(erp_curve_roi,levels_f1,levels_f2,group_time_windows_list_design,times,which_extrema_design_roi,sel_extrema);  
                    case 'individual_align'
                        subject_time_windows_list_design=subject_time_windows_list{design_num};
                        erp_curve_roi_stat.dataroi(nroi).datatw = ...
                            eeglab_study_plot_find_extrema_single(erp_curve_roi,levels_f1,levels_f2,group_time_windows_list_design,subject_time_windows_list_design,times,which_extrema_design_roi,...
                            sel_extrema);
                end            
           
        
            % M2 viene salvata dentro erp_curve_roi, bisogna creare una nuova struttura con gli estremi ele loro latenze, possibile salvare i dati in forma più grezza 
            % (per ogni soggetto, i valori nella sottofinestra, non processati, se volessimo calcolare altre misure, tipo varianza, stdev, mediana, che comunque potremmo già calcolarci e salvarci anche qui). 

            % calculate statistics        

            %  pcond        - [cell] condition pvalues or mask (0 or 1) if an alpha value
            %                 is selected. One element per group.
            %  pgroup       - [cell] group pvalues or mask (0 or 1). One element per 
            %                 condition.
            %  pinter       - [cell] three elements, condition pvalues (group pooled),
            %                 group pvalues (condition pooled) and interaction pvalues.
            %  statcond     - [cell] condition statistic values (F or T).
            %  statgroup    - [cell] group pvalues or mask (0 or 1). One element per 
            %                 condition.
            %  statinter    - [cell] three elements, condition statistics (group pooled),
            %                 group statistics (condition pooled) and interaction F statistics.

            times_plot=times;
        
           
                if strcmp(which_method_find_extrema,'group_align')
                   tw_stat_estimator = 'tw_mean'; % nel caso del pattern medio, forzo la media (NON vado a stimare gli estremi dei singoli soggetti come faccio negli altri 2 metodi)
                end
                
                switch tw_stat_estimator
                         case 'tw_mean'
                            erp_curve_roi=erp_curve_roi_stat.dataroi(nroi).datatw.curve;
                         case 'tw_extremum'                            
                            erp_curve_roi=erp_curve_roi_stat.dataroi(nroi).datatw.extr;
                end
                
                times_plot=1:length(group_time_windows_list_design);                  
                
                [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(erp_curve_roi,num_tails,'groupstats','on','condstats','on','mcorrect','none',...
                'threshold',NaN,'naccu',num_permutations,'method', stat_method,'paired',paired_list{design_num});          
        
                for ind = 1:length(pcond),  pcond{ind}    =  abs(pcond{ind}) ; end;
                for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
                for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end

                 [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);
                     
                 if (strcmp(do_plots,'on'))
                
                        eeglab_study_roi_erp_curve_tw_graph(STUDY, design_num, roi_name, name_f1, name_f2, levels_f1,levels_f2, ...
                            erp_curve_roi, times_plot,group_time_windows_names{design_num}, pcond_corr, pgroup_corr, pinter_corr,study_ls,plot_dir,display_only_significant_topo,...
                            display_compact_topo, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,display_single_subjects,compact_display_xlim,compact_display_ylim);

                     
                 end
         
            erp_curve_roi_stat.dataroi(nroi).roi_channels   = roi_channels;
            erp_curve_roi_stat.dataroi(nroi).roi_name       = roi_name;
            erp_curve_roi_stat.dataroi(nroi).erp_curve_roi  = erp_curve_roi;              
            
            erp_curve_roi_stat.dataroi(nroi).pcond          = pcond;
            erp_curve_roi_stat.dataroi(nroi).pgroup         = pgroup;
            erp_curve_roi_stat.dataroi(nroi).pinter         = pinter; 
            
            erp_curve_roi_stat.dataroi(nroi).statscond      = statscond;
            erp_curve_roi_stat.dataroi(nroi).statsgroup     = statsgroup;
            erp_curve_roi_stat.dataroi(nroi).statsinter     = statsinter;
            
            erp_curve_roi_stat.dataroi(nroi).pcond          = pcond_corr;
            erp_curve_roi_stat.dataroi(nroi).pgroup         = pgroup_corr;
            erp_curve_roi_stat.dataroi(nroi).pinter         = pinter_corr;    
            
         end
         
         erp_curve_roi_stat.times=times_plot;
         
         if strcmp(time_resolution_mode,'tw')              
             erp_curve_roi_stat.group_time_windows_list                 = group_time_windows_list_design;
             erp_curve_roi_stat.group_time_windows_names                = group_time_windows_names_design;
             erp_curve_roi_stat.which_extrema_design                    = which_extrema_design; 
             erp_curve_roi_stat.sel_extrema                             = sel_extrema;

             if strcmp(mode.peak_type,'individual')
                erp_curve_roi_stat.subject_time_windows_list            = subject_time_windows_list;
             end
         end  
         
        erp_curve_roi_stat.study_ls             = study_ls;
        erp_curve_roi_stat.num_permutations     = num_permutations;
        erp_curve_roi_stat.correction           = correction;  
        
        
        
        
        erp_curve_roi_stat.list_select_subjects = list_select_subjects;
    
          
        erp_compact.erp_topo_stat=erp_topo_stat;
        erp_compact.erp_curve_roi_stat=erp_curve_roi_stat;
                
                
                
        
         %% DOING MULTIPLE COMPARISONS ANALYSIS      
         erp_topo_stat.study_ls             = study_ls;
         erp_topo_stat.num_permutations     = num_permutations;
         erp_topo_stat.correction           = correction;  
            
             
        
            %% for each roi in the list           
            for nroi = 1:length(roi_names)
                roi_channels=roi_list{nroi}; 
                roi_name=roi_names{nroi};
% 
%                 plot_dir=fullfile(results_path,stat_analysis_suffix,[STUDY.design(design_num).name,'-erp_topo_tw','-',roi_name,'-',which_method_find_extrema,'_',datestr(now,30)]);
%                 mkdir(plot_dir);

                %% select the study design for the analyses
                STUDY = std_selectdesign(STUDY, ALLEEG, design_num);
    
                %% exctract names of the factores and the names of the corresponding levels for the selected design 
                name_f1=STUDY.design(design_num).variable(1).label;
                name_f2=STUDY.design(design_num).variable(2).label;

                levels_f1=STUDY.design(design_num).variable(1).value;
                levels_f2=STUDY.design(design_num).variable(2).value;

                tlf1=length(levels_f1);
                tlf2=length(levels_f2);

                %% plot topo map of each band in frequency_bands_list in each time window in design_group_time_windows_list 
                STUDY = pop_statparams(STUDY, 'condstats','on', 'groupstats','on', 'alpha',study_ls,'naccu',num_permutations,'method', stat_method,...
                                       'mcorrect',correction,'paired',paired_list{design_num});

              
                    
                for nwin=1:length(group_time_windows_list_design)
                    %% set parameters for a topographic represntation  
                    time_window_name    = group_time_windows_names_design{nwin}; 
                    time_window         = group_time_windows_list_design{nwin}; 

                    STUDY = pop_erpparams(STUDY, 'topotime', group_time_windows_list_design{nwin} );                   

                    STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');

                    %% calculate erp in the channels corresponding to the selected roi	
                    [STUDY,erp_topo_tw times freqs]=std_erpplot_corr(STUDY,ALLEEG,'channels',roi_channels,'noplot','on');
                    
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
                    
                    roi_mask =ones(1,length(locs_labels));


                      erp_topo_tw_roi_avg=[]; 
                      erp_topo_tw_sub_avg=[];
%                        for nf1=1:length(levels_f1)
%                             for nf2=1:length(levels_f2)
%                                 roi_mask = ismember(locs_labels,roi_channels);
%                                 if length(size(erp_topo_tw{nf1,nf2}))>2
%                                     erp_topo_tw_roi_avg{nf1,nf2}=squeeze(mean(erp_topo_tw{nf1,nf2},2))';
%                                     erp_topo_tw_sub_avg{nf1,nf2}=squeeze(mean(erp_topo_tw{nf1,nf2}(:,:,:),3))';
%                                 else
%                                     erp_topo_tw_roi_avg{nf1,nf2}=erp_topo_tw{nf1,nf2};
%                                     erp_topo_tw_sub_avg{nf1,nf2}=erp_topo_tw{nf1,nf2};
%                                 end
%                             end
%                        end   


  roi_mask = ismember(locs_labels,roi_channels);

                   
                       for nf1=1:length(levels_f1)
                           for nf2=1:length(levels_f2)                             
                              erp_topo_tw_roi_avg{nf1,nf2}=ersp_curve_roi_fb_stat.dataroi(nroi).databand(nband).ersp_curve_roi_fb{nf1,nf2};
                           end
                       end   


                    if ~ isempty(design_factors_ordered_levels)
                       if ~ isempty(design_factors_ordered_levels{design_num}{1})
                            levels_f1=STUDY.design(design_num).variable(1).value;            
                           [match_lev reorder_lev]=ismember(design_factors_ordered_levels{design_num}{1},levels_f1); 
                           levels_f1=levels_f1(reorder_lev);
                          erp_topo_tw_roi_avg=erp_topo_tw_roi_avg(reorder_lev,:);
%                           erp_topo_tw_sub_avg=erp_topo_tw_sub_avg(reorder_lev,:);
                       end

                       if ~ isempty(design_factors_ordered_levels{design_num}{2})
                           levels_f2=STUDY.design(design_num).variable(2).value;
                           [match_lev reorder_lev]=ismember(design_factors_ordered_levels{design_num}{2},levels_f2); 
                           levels_f2=levels_f2(reorder_lev);
                          erp_topo_tw_roi_avg=erp_topo_tw_roi_avg{:,reorder_lev};
%                           erp_topo_tw_sub_avg=erp_topo_tw_sub_avg{:,reorder_lev};
                       end
                    end

                    [stats.anova.stats_anova, stats.anova.stats.df_anova , stats.anova.p_anova]=statcond_corr(erp_topo_tw_roi_avg, num_tails, 'method', stat_method, 'naccu', num_permutations);


                    %% calculate statistics for each pairwise comparison
                    % of each factor
                   [stats.post_hoc.statscond, stats.post_hoc.statsgroup, stats.post_hoc.dfcond, stats.post_hoc.dfgroup, stats.post_hoc.pcond, ...
                       stats.post_hoc.pgroup, stats.post_hoc.compcond, stats.post_hoc.compgroup]= ...
                        pairwise_compairsons_stats(erp_topo_tw_roi_avg, stat_method, num_permutations, num_tails);
                    
                    
                    [stats.pcond_corr, stats.pgroup_corr,  stats.pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction);     

                    if (strcmp(do_plots,'on'))                

                        eeglab_study_erp_topo_graph(STUDY, design_num,erp_topo_tw,set_caxis, locs, name_f1, name_f2, levels_f1,levels_f2,...
                                                     time_window_name,time_window, ...                                                
                                                     stats.post_hoc.pcond_corr, stats.post_hoc.pgroup_corr, stats.pinter_corr,study_ls,...
                                                     plot_dir,display_only_significant_topo,display_only_significant_topo_mode,...
                                                     display_compact_topo,display_compact_topo_mode,...
                                                     erp_topo_tw_roi_avg,...
                                                     stats.post_hoc.compcond, stats.post_hoc.compgroup,...
                                                     roi_name, roi_mask,show_head, compact_display_ylim,show_text...
                                                     );

                    end

                   erp_topo_stat.dataroi(nroi).datatw(nwin).time_window_name    = time_window_name;
                   erp_topo_stat.dataroi(nroi).datatw(nwin).time_window         = time_window;

                   
                   erp_topo_stat.dataroi(nroi).datatw(nwin).erp_topo            = erp_topo_tw;

                   erp_topo_stat.dataroi(nroi).datatw(nwin).stats               = stats;
                   erp_topo_stat.dataroi(nroi).datatw(nwin).erp_topo_tw_roi_avg = erp_topo_tw_roi_avg;
                   erp_topo_stat.dataroi(nroi).datatw(nwin).erp_topo_tw_sub_avg = erp_topo_tw_sub_avg;

                end
            end 
            
          
        
            
%          %% EXPORTING DATA AND RESULTS OF ANALYSIS
%         save(fullfile(plot_dir,'erp_topo-stat.mat'),'erp_compact');
%         
%         if ~strcmp(which_method_find_extrema,'group_noalign');
%             [dataexpcols, dataexp]=text_export_erp(plot_dir,erp_curve_roi_stat);
%         end
    

 %% EXPORTING DATA AND RESULTS OF ANALYSIS
        out_file_name=fullfile(plot_dir,'erp_compact')
        save([out_file_name,'.mat'],'erp_compact');
                
         if ~ ( strcmp(which_method_find_extrema,'group_noalign') || strcmp(which_method_find_extrema,'continuous') );
            [dataexpcols, dataexp]=text_export_ersp_struct([out_file_name,'.txt'],erp_curve_roi_stat);
        end

         
    end
end