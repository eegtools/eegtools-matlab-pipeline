 function eeglab_study_erp_topo_graph(STUDY, design_num, erp_topo,set_caxis, chanlocs, name_f1, name_f2, levels_f1,levels_f2,...
                                            time_window_name, time_window, ...
                                            pcond, pgroup, pinter,study_ls, ...
                                            plot_dir,...
                                            display_only_significant,display_only_significant_mode,...
                                            display_compact,display_compact_mode,...
                                            erp_topo_tw_fb_roi_avg,...
                                            compcond, compgroup,...
                                            roi_name,roi_mask,show_head,compact_display_ylim,show_text)
     pmaskcond=[];
     pmaskgru=[]; 
     pmaskinter=[];  

     
     
     titles=eeglab_study_set_subplot_titles(STUDY,design_num); 
%           
%      % if required, correct for multiple comparisons    
%      for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;    
%      for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%      for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
%      
%      pcond_corr=pcond;
%      pgroup_corr=pgroup;
%      pinter_corr=pinter;
     
     
     switch display_compact
         
          case 'on'
             if strcmp(display_compact_mode,'boxplot')
               std_chantopo_erp_compact_boxplot( erp_topo_tw_fb_roi_avg,... 
                                   plot_dir,roi_name, ...
                                   chanlocs,...
                                   time_window_name, time_window, ...                                   
                                   name_f1, name_f2, levels_f1,levels_f2,... 
                                   pgroup,  pcond, study_ls, ...
                                   roi_mask,  compcond, compgroup,show_head, compact_display_ylim,show_text);
             end
             
             if strcmp(display_compact_mode,'errorbar')
                 std_chantopo_erp_compact_errorbar(erp_topo_tw_fb_roi_avg,... 
                                   plot_dir,roi_name, ...
                                   chanlocs,...
                                   time_window_name, time_window, ...                                   
                                   name_f1, name_f2, levels_f1,levels_f2,... 
                                   pgroup,  pcond, study_ls, ...
                                   roi_mask,  compcond, compgroup,show_head, compact_display_ylim,show_text);
             
             end
         
         case 'off'        
     
         % if required, apply a significance treshold    
                switch display_only_significant
                    case 'on'  
                        if strcmp(display_only_significant_mode,'electrodes')
                            tr=study_ls; 
                            for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}<study_ls) ; end;
                            for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}<study_ls) ; end;
                            for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}<study_ls) ; end;
                        end

                        if strcmp(display_only_significant_mode,'surface')
                           tr=NaN;   
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           for ind = 1:length(pcond),    pmaskcond{ind}  =  abs(pcond{ind}<study_ls); end;
                           for ind = 1:length(pgroup),  pmaskgru{ind}  =  abs(pgroup{ind}<study_ls); end;
                           for ind = 1:length(pinter),  pmaskinter{ind}  =  abs(pinter{ind}<study_ls); end;
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        end
                     case 'off'
                           tr=NaN;  
                end                  


         std_chantopo_erp(erp_topo, plot_dir, time_window_name,time_window, name_f1, name_f2, levels_f1,levels_f2,...
                          pmaskcond, pmaskgru, pmaskinter,study_ls,...
                          'groupstats', pgroup, 'condstats', pcond, 'interstats', pinter, 'caxis', set_caxis, 'chanlocs', chanlocs, 'threshold', tr,'titles', titles ...
                           );
     end

 end
%  , 'topoplotopt',{ 'style', 'both','pmask',[ones(10,1);zeros(68,1)] }
%,'topoplotopt',{ 'style', 'both', 'shading', 'interp' ,'pmask',[ones(10,1);zeros(68,1)]}