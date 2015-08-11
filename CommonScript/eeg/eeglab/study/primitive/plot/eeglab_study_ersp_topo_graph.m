function  eeglab_study_ersp_topo_graph(input)
%% function  eeglab_study_ersp_topo_graph()
% STUDY                                                                      = input.STUDY;
% design_num                                                                 = input.design_num;
% ersp_topo_tw_fb                                                            = input.ersp_topo_tw_fb;
% set_caxis                                                                  = input.set_caxis;
% chanlocs                                                                   = input.chanlocs;
% name_f1                                                                    = input.name_f1;
% name_f2                                                                    = input.name_f2;
% levels_f1                                                                  = input.levels_f1;
% levels_f2                                                                  = input.levels_f2;
% time_window_name                                                           = input.time_window_name;
% time_window                                                                = input.time_window;
% frequency_band_name                                                        = input.frequency_band_name;
% pcond                                                                      = input.pcond;
% pgroup                                                                     = input.pgroup;
% pinter                                                                     = input.pinter;
% study_ls                                                                   = input.study_ls;
% plot_dir                                                                   = input.plot_dir;
% display_only_significant                                                   = input.display_only_significant;
% display_only_significant_mode                                              = input.display_only_significant_mode;
% display_compact                                                            = input.display_compact;
% display_compact_mode                                                       = input.display_compact_mode;
% ersp_topo_tw_fb_roi_avg                                                    = input.ersp_topo_tw_fb_roi_avg;
% compcond                                                                   = input.compcond;
% compgroup                                                                  = input.compgroup;
% roi_name                                                                   = input.roi_name;
% roi_mask                                                                   = input.roi_mask;
% ersp_mode                                                                  = input.ersp_mode;
% show_head                                                                  = input.show_head;
% compact_display_ylim                                                       = input.compact_display_ylim;
% show_text                                                                  = input.show_text;
% z_transform                                                                = input.z_transform;
% which_error_measure                                                        = input.which_error_measure;


pmaskcond=[];
pmaskgru=[];
pmaskinter=[];


STUDY                                                                      = input.STUDY;
design_num                                                                 = input.design_num;
ersp_topo_tw_fb                                                            = input.ersp_topo_tw_fb;
set_caxis                                                                  = input.set_caxis;
chanlocs                                                                   = input.chanlocs;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
time_window_name                                                           = input.time_window_name;
time_window                                                                = input.time_window;
frequency_band_name                                                        = input.frequency_band_name;
pcond                                                                      = input.pcond;
pgroup                                                                     = input.pgroup;
pinter                                                                     = input.pinter;
study_ls                                                                   = input.study_ls;
plot_dir                                                                   = input.plot_dir;
display_only_significant                                                   = input.display_only_significant;
display_only_significant_mode                                              = input.display_only_significant_mode;
display_compact                                                            = input.display_compact;
display_compact_mode                                                       = input.display_compact_mode;
ersp_topo_tw_fb_roi_avg                                                    = input.ersp_topo_tw_fb_roi_avg;
compcond                                                                   = input.compcond;
compgroup                                                                  = input.compgroup;
roi_name                                                                   = input.roi_name;
roi_mask                                                                   = input.roi_mask;
ersp_measure                                                               = input.ersp_measure;
show_head                                                                  = input.show_head;
compact_display_ylim                                                       = input.compact_display_ylim;
show_text                                                                  = input.show_text;
z_transform                                                                = input.z_transform;
which_error_measure                                                        = input.which_error_measure;


% STUDY, design_num, ersp_topo_tw_fb,set_caxis, chanlocs, name_f1, name_f2, levels_f1,levels_f2,...
%     time_window_name, time_window, ...
%     frequency_band_name, ...
%     pcond, pgroup, pinter,study_ls,  ...
%     plot_dir,...
%     display_only_significant,display_only_significant_mode,...
%     display_compact,display_compact_mode,...
%     ersp_topo_tw_fb_roi_avg,...
%     compcond, compgroup,...
%     roi_name,roi_mask,...
%     ersp_mode,show_head,compact_display_ylim,show_text,z_transform,which_error_measure

%      for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;
%      for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%      for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
%
%      pcond_corr=pcond;
%      pgroup_corr=pgroup;
%      pinter_corr=pinter;

% display (curve) plots with different conditions/groups on the same plots
switch display_compact
    case 'on'
        if strcmp(display_compact_mode,'boxplot')
            
            input_graph.ersp_topo_tw_fb_roi_avg                            = ersp_topo_tw_fb_roi_avg;
            input_graph.plot_dir                                           = plot_dir;
            input_graph.roi_name                                           = roi_name;
            input_graph.chanlocs                                           = chanlocs;
            input_graph.time_window_name                                   = time_window_name;
            input_graph.time_window                                        = time_window;
            input_graph.frequency_band_name                                = frequency_band_name;
            input_graph.name_f1                                            = name_f1;
            input_graph.name_f2                                            = name_f2;
            input_graph.levels_f1                                          = levels_f1;
            input_graph.levels_f2                                          = levels_f2;
            input_graph.pgroup                                             = pgroup;
            input_graph.pcond                                              = pcond;
            input_graph.study_ls                                           = study_ls;
            input_graph.roi_mask                                           = roi_mask;
            input_graph.compcond                                           = compcond;
            input_graph.compgroup                                          = compgroup;
            input_graph.ersp_mode                                          = ersp_mode;
            input_graph.show_head                                          = show_head;
            input_graph.compact_display_ylim                               = compact_display_ylim;
            input_graph.show_text                                          = show_text;
            
            
            std_chantopo_ersp_compact_boxplot(input_graph);
            
            
            
            
            
        end
        
        if strcmp(display_compact_mode,'errorbar')
            
            input_graph.ersp_topo_tw_fb_roi_avg                            = ersp_topo_tw_fb_roi_avg;
            input_graph.plot_dir                                           = plot_dir;
            input_graph.roi_name                                           = roi_name;
            input_graph.chanlocs                                           = chanlocs;
            input_graph.time_window_name                                   = time_window_name;
            input_graph.time_window                                        = time_window;
            input_graph.frequency_band_name                                = frequency_band_name;
            input_graph.name_f1                                            = name_f1;
            input_graph.name_f2                                            = name_f2;
            input_graph.levels_f1                                          = levels_f1;
            input_graph.levels_f2                                          = levels_f2;
            input_graph.pgroup                                             = pgroup;
            input_graph.pcond                                              = pcond;
            input_graph.study_ls                                           = study_ls;
            input_graph.roi_mask                                           = roi_mask;
            input_graph.compcond                                           = compcond;
            input_graph.compgroup                                          = compgroup;
            input_graph.ersp_mode                                          = ersp_mode;
            input_graph.show_head                                          = show_head;
            input_graph.compact_display_ylim                               = compact_display_ylim;
            input_graph.show_text                                          = show_text;
            input_graph.z_transform                                        = z_transform;
            input_graph.which_error_measure                                = which_error_measure;
            
            std_chantopo_ersp_compact_errorbar(input_graph);
            
        end
        
        
        
        
    case 'off'
        titles=eeglab_study_set_subplot_titles(STUDY,design_num);
        % if required, correct for multiple comparisons
        
        
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
        
        input_graph.data                                                   = ersp_topo_tw_fb;
        input_graph.plot_dir                                               = plot_dir;
        input_graph.time_window_name                                       = time_window_name;
        input_graph.time_window                                            = time_window;
        input_graph.frequency_band_name                                    = frequency_band_name;
        input_graph.name_f1                                                = name_f1;
        input_graph.name_f2                                                = name_f2;
        input_graph.levels_f1                                              = levels_f1;
        input_graph.levels_f2                                              = levels_f2;
        input_graph.pmaskcond                                              = pmaskcond;
        input_graph.pmaskgru                                               = pmaskgru;
        input_graph.pmaskinter                                             = pmaskinter;
        input_graph.ersp_mode                                              = ersp_measure;
        input_graph.study_ls                                               = study_ls;
        
        std_chantopo_ersp(input_graph, 'groupstats', pgroup, 'condstats', pcond, 'interstats', pinter, 'caxis', set_caxis, 'chanlocs', chanlocs(roi_mask), 'threshold', tr, 'titles', titles);
        
end
end