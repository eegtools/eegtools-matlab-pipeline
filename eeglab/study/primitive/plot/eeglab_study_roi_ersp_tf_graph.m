function [] = eeglab_study_roi_ersp_tf_graph(input)
%% function [] = eeglab_study_roi_ersp_tf_graph(input)
%  STUDY                           = input.STUDY;
%     design_num                      = input.design_num;
%     roi_name                        = input.roi_name;
%     name_f1                         = input.name_f1;
%     name_f2                         = input.name_f2;
%     levels_f1                       = input.levels_f1;
%     levels_f2                       = input.levels_f2;
%     ersp                            = input.ersp;
%     times                           = input.times;
%     freqs                           = input.freqs;
%     pcond                           = input.pcond;
%     pgroup                          = input.pgroup;
%     pinter                          = input.pinter;
%     set_caxis                       = input.set_caxis;
%     study_ls                        = input.study_ls;
%     plot_dir                        = input.plot_dir;
%     freq_scale                      = input.freq_scale;
%     display_only_significant        = input.display_only_significant;
%     display_only_significant_mode   = input.display_only_significant_mod;
%     ersp_measure                    = input.ersp_measure;
%     group_time_windows_list         = input. group_time_windows_list;
%     frequency_bands_list            = input.frequency_bands_list;
%     display_pmode                   = input.display_pmode;
%

STUDY                           = input.STUDY;
design_num                      = input.design_num;
roi_name                        = input.roi_name;
name_f1                         = input.name_f1;
name_f2                         = input.name_f2;
levels_f1                       = input.levels_f1;
levels_f2                       = input.levels_f2;
ersp                            = input.ersp_tf;
times                           = input.times;
freqs                           = input.freqs;
pcond                           = input.pcond_corr;
pgroup                          = input.pgroup_corr;
pinter                          = input.pinter_corr;
set_caxis                       = input.set_caxis;
study_ls                        = input.study_ls;
plot_dir                        = input.plot_dir;
freq_scale                      = input.freq_scale;
display_only_significant        = input.display_only_significant;
display_only_significant_mode   = input.display_only_significant_mode;
ersp_measure                    = input.ersp_measure;
group_time_windows_list         = input. group_time_windows_list;
frequency_bands_list            = input.frequency_bands_list;
display_pmode                   = input.display_pmode;
display_compact_plots           = input.display_compact_plots;



pmaskcond=[];
pmaskgroup=[];
pmaskinter=[];
% do_compact = 1;

titles=eeglab_study_set_subplot_titles(STUDY,design_num);




% if required, apply a significance treshold
switch display_only_significant
    case 'on'
        if strcmp(display_only_significant_mode,'binary')
            tr=study_ls;
            for ind = 1:length(pcond),  pmaskcond{ind}  =  pcond{ind}<study_ls ; end;
            for ind = 1:length(pgroup),  pmaskgroup{ind}  =  pgroup{ind}<study_ls ; end;
            for ind = 1:length(pinter),  pmaskinter{ind}  =  pinter{ind}<study_ls ; end;
        end
        
        if strcmp(display_only_significant_mode,'thresholded')
            tr=NaN;
            
            for ind = 1:length(pcond),    pmaskcond{ind}  =  abs(pcond{ind}<study_ls); end;
            for ind = 1:length(pgroup),  pmaskgroup{ind}  =  abs(pgroup{ind}<study_ls); end;
            for ind = 1:length(pinter),  pmaskinter{ind}  =  abs(pinter{ind}<study_ls); end;
            
        end
        
    case 'off'
        tr=NaN;
end

input_graph.times                                                          = times;
input_graph.freqs                                                          = freqs;
input_graph.data                                                           = ersp;
input_graph.plot_dir                                                       = plot_dir;
input_graph.roi_name                                                       = roi_name;
input_graph.name_f1                                                        = name_f1;
input_graph.name_f2                                                        = name_f2;
input_graph.levels_f1                                                      = levels_f1;
input_graph.levels_f2                                                      = levels_f2;
input_graph.pmaskcond                                                      = pmaskcond;
input_graph.pmaskgru                                                       = pmaskgroup;
input_graph.pmaskinter                                                     = pmaskinter;
input_graph.ersp_measure                                                   = ersp_measure;
% input_graph.group_time_windows_list                                        = group_time_windows_list;
input_graph.frequency_bands_list                                           = frequency_bands_list;
input_graph.display_pmode                                                  = display_pmode;
input_graph.set_caxis                                                      = set_caxis;
input_graph.study_ls                                                       = study_ls;

% plot ersp and statistics
if strcmp(display_compact_plots, 'on')
    std_plottf_ersp_compact(input_graph);
    
else
    std_plottf_ersp(input_graph, 'datatype', 'ersp','groupstats', pgroup, 'condstats', pcond,'interstats', pinter, 'plotmode','normal','titles',titles ,...
        'tftopoopt',{'mode', 'ave'},'caxis',set_caxis ,'threshold',tr,'freqscale',freq_scale);
end
end
