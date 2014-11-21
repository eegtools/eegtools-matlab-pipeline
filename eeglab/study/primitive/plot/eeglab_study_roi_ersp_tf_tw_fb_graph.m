function [] = eeglab_study_roi_ersp_tf_tw_fb_graph(input)
%% function [] = eeglab_study_roi_ersp_tf_tw_fb_graph(input)
% STUDY                           = input.STUDY;
% design_num                      = input.design_num;
% roi_name                        = input.roi_name;
% name_f1                         = input.name_f1;
% name_f2                         = input.name_f2;
% levels_f1                       = input.levels_f1;
% levels_f2                       = input.levels_f2;
% ersp                            = input.ersp;
% times                           = input.times;
% freqs                           = input.freqs;
% pcond                           = input.pcond;
% pgroup                          = input.pgroup;
% pinter                          = input.pinter;
% set_caxis                       = input.set_caxis;
% study_ls                        = input.study_ls;
% time_windows_names              = input.time_windows_names;
% frequency_bands_names           = input.frequency_bands_names;
% plot_dir                        = input.plot_dir;
% freq_scale                      = input.freq_scale;
% display_only_significant        = input.display_only_significant;
% display_only_significant_mode   = input.display_only_significant_mode;
% ersp_mode                       = input.ersp_mode;
% display_pmode                   = input.display_pmode;

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
time_windows_names              = input.time_windows_names;
frequency_bands_names           = input.frequency_bands_names;
plot_dir                        = input.plot_dir;
freq_scale                      = input.freq_scale;
display_only_significant        = input.display_only_significant;
display_only_significant_mode   = input.display_only_significant_mode;
ersp_mode                       = input.ersp_mode;
display_pmode                   = input.display_pmode;


titles=eeglab_study_set_subplot_titles(STUDY,design_num);

pmaskcond=[];
pmaskgru=[];
pmaskinter=[];

%
%   % if required, correct for multiple comparisons
%     for ind = 1:length(pcond),  pcond{ind}  =  mcorrect(pcond{ind},correction) ; end;
%     for ind = 1:length(pgroup),  pgroup{ind}  =  mcorrect(pgroup{ind},correction) ; end;
%     for ind = 1:length(pinter),  pinter{ind}  =  mcorrect(pinter{ind},correction) ; end;
%

% if required, apply a significance treshold
switch display_only_significant
    case 'on'
        if strcmp(display_only_significant_mode,'binary')
            tr=study_ls;
            for ind = 1:length(pcond),  pcond{ind}  =  pcond{ind}<study_ls ; end;
            for ind = 1:length(pgroup),  pgroup{ind}  =  pgroup{ind}<study_ls ; end;
            for ind = 1:length(pinter),  pinter{ind}  =  pinter{ind}<study_ls ; end;
        end
        
        if strcmp(display_only_significant_mode,'thresholded')
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


% plot ersp and statistics
std_plottf_ersp_tw_fb(times, freqs, ersp, time_windows_names, frequency_bands_names , plot_dir,roi_name, name_f1, name_f2, levels_f1,levels_f2,...
    pmaskcond, pmaskgru, pmaskinter,ersp_mode,display_pmode,...
    'datatype', 'ersp','groupstats', pgroup, 'condstats', pcond,'interstats', pinter, ...
    'plotmode','normal','titles',titles ,'tftopoopt',{'mode', 'ave'},'caxis',set_caxis ,...
    'threshold',tr,'freqscale',freq_scale);

end
