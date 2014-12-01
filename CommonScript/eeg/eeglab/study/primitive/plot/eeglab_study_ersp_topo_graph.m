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
            std_chantopo_ersp_compact_boxplot( ersp_topo_tw_fb_roi_avg,...
                plot_dir,roi_name, ...
                chanlocs,...
                time_window_name, time_window, ...
                frequency_band_name, ...
                name_f1, name_f2, levels_f1,levels_f2,...
                pgroup,  pcond, study_ls, ...
                roi_mask,  compcond, compgroup,ersp_measure,show_head,compact_display_ylim,show_text);
        end
        
        if strcmp(display_compact_mode,'errorbar')
            std_chantopo_ersp_compact_errorbar(ersp_topo_tw_fb_roi_avg,...
                plot_dir,roi_name, ...
                chanlocs,...
                time_window_name, time_window, ...
                frequency_band_name, ...
                name_f1, name_f2, levels_f1,levels_f2,...
                pgroup,  pcond, study_ls, ...
                roi_mask,  compcond, compgroup,ersp_measure,show_head,compact_display_ylim,show_text,z_transform,which_error_measure);
            
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
        
        
        std_chantopo_ersp(ersp_topo_tw_fb, plot_dir, time_window_name, time_window, frequency_band_name, name_f1, name_f2, levels_f1,levels_f2, ...
            pmaskcond, pmaskgru, pmaskinter,ersp_measure,study_ls,...
            'groupstats', pgroup, 'condstats', pcond, 'interstats', pinter, 'caxis', set_caxis, 'chanlocs', chanlocs, 'threshold', tr, 'titles', titles);
        
end
end