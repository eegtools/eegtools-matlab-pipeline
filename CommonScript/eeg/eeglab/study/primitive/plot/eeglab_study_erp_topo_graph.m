function eeglab_study_erp_topo_graph(input)

STUDY                                                                      = input.STUDY;
design_num                                                                 = input.design_num;
erp_topo                                                                   = input.erp_topo;
set_caxis                                                                  = input.set_caxis;
chanlocs                                                                   = input.chanlocs;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
time_window_name                                                           = input.time_window_name;
time_window                                                                = input.time_window;
pcond                                                                      = input.pcond;
pgroup                                                                     = input.pgroup;
pinter                                                                     = input.pinter;
study_ls                                                                   = input.study_ls;
plot_dir                                                                   = input.plot_dir;
display_only_significant                                                   = input.display_only_significant;
display_only_significant_mode                                              = input.display_only_significant_mode;
display_compact                                                            = input.display_compact;
display_compact_mode                                                       = input.display_compact_mode;
erp_topo_tw_roi_avg                                                        = input.erp_topo_tw_roi_avg;
compcond                                                                   = input.compcond;
compgroup                                                                  = input.compgroup;
roi_name                                                                   = input.roi_name;
roi_mask                                                                   = input.roi_mask;
show_head                                                                  = input.show_head;
compact_display_ylim                                                       = input.compact_display_ylim;
show_text                                                                  = input.show_text;

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
            
            input_plot.erp_topo_tw_roi_avg                                 = erp_topo_tw_roi_avg;
            input_plot.plot_dir                                            = plot_dir;
            input_plot.roi_name                                            = roi_name;
            input_plot.chanlocs                                            = chanlocs;
            input_plot.time_window_name                                    = time_window_name;
            input_plot.time_window                                         = time_window;
            input_plot.name_f1                                             = name_f1;
            input_plot.name_f2                                             = name_f2;
            input_plot.levels_f1                                           = levels_f1;
            input_plot.levels_f2                                           = levels_f2;
            input_plot.pgroup                                              = pgroup;
            input_plot.pcond                                               = pcond;
            input_plot.study_ls                                            = study_ls;
            input_plot.roi_mask                                            = roi_mask;
            input_plot.compcond                                            = compcond;
            input_plot.compgroup                                           = compgroup;
            input_plot.show_head                                           = show_head;
            input_plot.compact_display_ylim                                = compact_display_ylim;
            input_plot.show_text                                           = show_text;
            
            std_chantopo_erp_compact_boxplot(input_plot);
        end
        
        if strcmp(display_compact_mode,'errorbar')
            
            input_plot.erp_topo_tw_roi_avg=erp_topo_tw_roi_avg;
            input_plot.plot_dir=plot_dir;
            input_plot.roi_name=roi_name;
            input_plot.chanlocs=chanlocs;
            input_plot.time_window_name=time_window_name;
            input_plot.time_window=time_window;
            input_plot.name_f1=name_f1;
            input_plot.name_f2=name_f2;
            input_plot.levels_f1=levels_f1;
            input_plot.levels_f2=levels_f2;
            input_plot.pgroup=pgroup;
            input_plot.pcond=pcond;
            input_plot.study_ls=study_ls;
            input_plot.roi_mask=roi_mask;
            input_plot.compcond=compcond;
            input_plot.compgroup=compgroup;
            input_plot.show_head=show_head;
            input_plot.compact_display_ylim=compact_display_ylim;
            input_plot.show_text=show_text;
            
            std_chantopo_erp_compact_errorbar(input_plot);
            
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
        
        
        input_plot.data=erp_topo;
        input_plot.plot_dir=plot_dir;
        input_plot.time_window_name=time_window_name;
        input_plot.time_window=time_window;
        input_plot.name_f1=name_f1;
        input_plot.name_f2=name_f2;
        input_plot.levels_f1=levels_f1;
        input_plot.levels_f2=levels_f2;
        input_plot.pmaskcond= pmaskcond;
        input_plot.pmaskgru=pmaskgru;
        input_plot.pmaskinter=pmaskinter;
        input_plot.study_ls=study_ls;
        
        std_chantopo_erp(input_plot,...
            'groupstats', pgroup, ...
            'condstats' , pcond, ...
            'interstats', pinter, ...
            'caxis',      set_caxis, ...
            'chanlocs',   chanlocs, ...
            'threshold', tr,...
            'titles', titles ...
            );
end

end
%  , 'topoplotopt',{ 'style', 'both','pmask',[ones(10,1);zeros(68,1)] }
%,'topoplotopt',{ 'style', 'both', 'shading', 'interp' ,'pmask',[ones(10,1);zeros(68,1)]}