 function  eeglab_study_roi_erp_curve_tw_graph(STUDY, design_num, roi_name, name_f1, name_f2, levels_f1,levels_f2, erp_curve, times,time_windows_design_names, ...
                                                    pcond, pgroup, pinter,study_ls, plot_dir,display_only_significant,...
                                                    display_compact_plots, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,...
                                                    display_single_subjects,compact_display_xlim,compact_display_ylim)
  

     titles=eeglab_study_set_subplot_titles(STUDY,design_num); 
%           
%      % if required, correct for multiple comparisons    
%      for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;    
%      for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%      for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
     
     pcond_nomask=pcond;
     pgroup_nomask=pgroup;
     pinter_nomask=pinter;
     
     
      % display (curve) plots with different conditions/groups on the same plots 
     switch display_compact_plots
         case 'on'
            std_plotcurve_erp_tw_compact(times, erp_curve, plot_dir, roi_name, study_ls, name_f1, name_f2, levels_f1,levels_f2, pgroup,  pcond, compact_display_h0,compact_display_v0,compact_display_sem,compact_display_stats,display_single_subjects,compact_display_xlim,compact_display_ylim,time_windows_design_names);      
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
         if  length(time_windows_design_names) >1
             std_plotcurve_erp_tw(times, erp_curve, plot_dir, roi_name, study_ls, time_windows_design_names, name_f1, name_f2, levels_f1,levels_f2, ...
             pcond_nomask,pgroup_nomask,pinter_nomask,...    
            'groupstats', pgroup, 'condstats', pcond,'interstats', pinter, 'titles',titles  ,'threshold',tr,'plotgroups','apart' ,'plotconditions','apart');
         else
             display('ERROR: Select at least 2 time windows!!!!')
             return;
         end
     end

 end