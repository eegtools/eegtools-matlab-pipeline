function [] = eeglab_study_roi_ersp_curve_fb_graph(input)


% STUDY, design_num, roi_name, name_f1, name_f2, levels_f1,levels_f2, ersp_curve_fb, times, frequency_band_name, ...
% pcond, pgroup, pinter,study_ls,plot_dir,...
% display_only_significant,display_compact_plots, compact_display_h0,compact_display_v0,compact_display_sem,...
% compact_display_stats,display_single_subjects,compact_display_xlim,compact_display_ylim,...
%  ersp_measure


STUDY                                                                = input.STUDY;
design_num                                                           = input.design_num;
roi_name                                                             = input.roi_name;
name_f1                                                              = input.name_f1;
name_f2                                                              = input.name_f2;
levels_f1                                                            = input.levels_f1;
levels_f2                                                            = input.levels_f2;
ersp_curve_fb                                                        = input.ersp_curve_fb;
times                                                                = input.times;
frequency_band_name                                                  = input.frequency_band_name;
pcond                                                                = input.pcond;
pgroup                                                               = input.pgroup;
pinter                                                               = input.pinter;
study_ls                                                             = input.study_ls;
plot_dir                                                             = input.plot_dir;
display_only_significant                                             = input.display_only_significant;
display_compact_plots                                                = input.display_compact_plots;
compact_display_h0                                                   = input.compact_display_h0;
compact_display_v0                                                   = input.compact_display_v0;
compact_display_sem                                                  = input.compact_display_sem;
compact_display_stats                                                = input.compact_display_stats;
display_single_subjects                                              = input.display_single_subjects;
compact_display_xlim                                                 = input.compact_display_xlim;
compact_display_ylim                                                 = input.compact_display_ylim;
ersp_measure                                                         = input.ersp_measure;
list_design_subjects                                                 = input.list_design_subjects;


% display(levels_f2)

titles=eeglab_study_set_subplot_titles(STUDY,design_num);

%      % if required, correct for multiple comparisons
%      for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;
%      for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%      for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
%
switch display_single_subjects
    case 'on'
        
        input_graph.list_design_subjects                                   = list_design_subjects;
        input_graph.times                                                  = times;
        input_graph.ersp_curve_fb                                          = ersp_curve_fb; 
        input_graph.plot_dir                                               = plot_dir;
        input_graph.roi_name                                               = roi_name;
        input_graph.levels_f1                                              = levels_f1;
        input_graph.levels_f2                                              = levels_f2;
        input_graph.frequency_band_name                                    = frequency_band_name;
        
        std_plotcurve_ersp_fb_single_subject(input_graph)
        
    case 'off'
        
        % display (curve) plots with different conditions/groups on the same plots
        switch display_compact_plots
            case 'on'
                
                input_graph.times                                                  = times;
                input_graph.ersp_curve_fb                                          = ersp_curve_fb;
                input_graph.plot_dir                                               = plot_dir;
                input_graph.roi_name                                               = roi_name;
                input_graph.study_ls                                               = study_ls;
                input_graph.frequency_band_name                                    = frequency_band_name;
                input_graph.name_f1                                                = name_f1;
                input_graph.name_f2                                                = name_f2;
                input_graph.levels_f1                                              = levels_f1;
                input_graph.levels_f2                                              = levels_f2;
                input_graph.pgroup                                                 = pgroup;
                input_graph.pcond                                                  = pcond;
                input_graph.compact_display_h0                                     = compact_display_h0;
                input_graph.compact_display_v0                                     = compact_display_v0;
                input_graph.compact_display_sem                                    = compact_display_sem;
                input_graph.compact_display_stats                                  = compact_display_stats;
                input_graph.compact_display_xlim                                   = compact_display_xlim;
                input_graph.compact_display_ylim                                   = compact_display_ylim;
                input_graph.ersp_measure                                           = ersp_measure;
                
                
                std_plotcurve_ersp_fb_compact(input_graph)
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
                input_graph.times = times;
                input_graph.data = ersp_curve_fb;
                input_graph.plot_dir = plot_dir;
                input_graph.roi_name = roi_name;
                input_graph.study_ls = study_ls;
                input_graph.frequency_band_name = frequency_band_name;
                input_graph.name_f1 = name_f1;
                input_graph.name_f2 = name_f2;
                input_graph.levels_f1 = levels_f1;
                input_graph.levels_f2 = levels_f2;
                input_graph.ersp_mode = ersp_measure;
                
                std_plotcurve_ersp_fb(input_graph,'groupstats', pgroup, 'condstats', pcond,'interstats', pinter, 'titles',titles  ,'threshold',tr);
        end
end
end