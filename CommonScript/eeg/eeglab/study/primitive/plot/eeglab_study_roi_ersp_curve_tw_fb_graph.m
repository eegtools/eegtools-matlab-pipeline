 function eeglab_study_roi_ersp_curve_tw_fb_graph(STUDY, design_num, roi_name, name_f1, name_f2, levels_f1,levels_f2, ersp_curve_fb, times, frequency_band_name,time_windows_design_names, ...
                                                       pcond, pgroup, pinter,study_ls,plot_dir,display_only_significant,...
                                                       display_compact_plots, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,...
                                                       compact_display_xlim,compact_display_ylim,ersp_mode)
  
     titles=eeglab_study_set_subplot_titles(STUDY,design_num);    
%      
%      % if required, correct for multiple comparisons    
%      for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;    
%      for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%      for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
%      
%      
%      pcond_corr=pcond;
%      pgroup_corr=pgroup;
%      pinter_corr=pinter;
     
     
     pcond_nomask=pcond;
     pgroup_nomask=pgroup;
     pinter_nomask=pinter;
     
     
    % display (curve) plots with different conditions/groups on the same plots 
     switch display_compact_plots
         case 'on'   
            std_plotcurve_ersp_tw_fb_compact(times, ersp_curve_fb, plot_dir, roi_name, study_ls, frequency_band_name, time_windows_design_names, name_f1, name_f2, levels_f1,levels_f2,...
                pgroup,  pcond, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,compact_display_xlim,compact_display_ylim,ersp_mode)      
         case 'off'
           % if required, apply a significance treshold    
            switch display_only_significant
                 case 'on'
                       tr=study_ls; 
                        for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}<study_ls) ; end;
                        for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}<study_ls) ; end;
                        for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}<study_ls) ; end;
                 case 'off'
                       tr=NaN;                            
            end
            % plot ersp and statistics
             if  length(time_windows_design_names) >1
                 std_plotcurve_ersp_tw_fb(times, ersp_curve_fb, plot_dir, roi_name, study_ls, frequency_band_name, time_windows_design_names, name_f1, name_f2, levels_f1,levels_f2,ersp_mode, ...
                 pcond_nomask,pgroup_nomask,pinter_nomask,...    
                 'groupstats', pgroup, 'condstats', pcond,'interstats', pinter, 'titles',titles  ,'threshold',tr,'plotgroups','apart' ,'plotconditions','apart');
             else
                 display('ERROR: Select at least 2 time windows!!!!')
                return;
             end
     end
 end

