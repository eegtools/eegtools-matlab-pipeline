%% [output] = eeglab_study_roi_ersp_tf_simple(input)
%
% calculate ersp time frequency and perform standard EEGLAB statistics with
% the original time-frequency resolution
% 
% STUDY                                = input.STUDY;
% ALLEEG                               = input.ALLEEG; 
% channels_list                        = input.channels_list;
% levels_f1                            = input.levels_f1; 
% levels_f2                            = input.levels_f2;
% num_permutations                     = input.num_permutations;
% stat_time_windows_list               = input.stat_time_windows_list;
% paired                               = input.paired;
% stat_method                          = input.stat_method;
% list_select_subjects                 = input.list_select_subjects;
% list_design_subjects                 = input.list_design_subjects;
% ersp_measure                         = input.ersp_measure;
% num_tails                            = input.num_tails;
% stat_freq_bands_list                 = input.stat_freq_bands_list;
% mask_coef                            = input.mask_coef;  
%
%
% output.ersp_tf    = ersp_tf;
% output.times      = times;     
% output.freqs      = freqs; 
% output.pcond      = pcond;
% output.pgroup     = pgroup;
% output.pinter     = pinter;


function [output] = eeglab_study_roi_ersp_tf_simple(input)




STUDY                                = input.STUDY;
ALLEEG                               = input.ALLEEG; 
channels_list                        = input.channels_list;
levels_f1                            = input.levels_f1; 
levels_f2                            = input.levels_f2;
num_permutations                     = input.num_permutations;
stat_time_windows_list               = input.stat_time_windows_list;
paired                               = input.paired;
stat_method                          = input.stat_method;
list_select_subjects                 = input.list_select_subjects;
list_design_subjects                 = input.list_design_subjects;
ersp_measure                         = input.ersp_measure;
num_tails                            = input.num_tails;
stat_freq_bands_list                 = input.stat_freq_bands_list;
mask_coef                            = input.mask_coef;  
alignt0                              = input.alignt0;
split_base                           = input.split_base;
design_num                           = input.design_num;

  if nargin < 1
    help eeglab_study_roi_ersp_tf_simple;
    return;
  end;    
 
STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');

if not(split_base)
    [STUDY ersp_tf times freqs]=std_erspplot(STUDY,ALLEEG,'channels',channels_list,'noplot','on');
else
    fname_out = fullfile(STUDY.filepath,[STUDY.design(design_num).name,'.mat']);
    load(fname_out,'erspdata_post_bc','times_post', 'freqs_post');
    allch = [STUDY.changrp.channels];
    ersp_tf_allch = erspdata_post_bc;
    times   = times_post;
    freqs   = freqs_post;
    clear erspdata_post_bc  times_post freqs_post;
    sel_ch_roi = ismember(allch,channels_list);
    [trr, tcc] = size(ersp_tf_allch);
    for nrr = 1:trr
        for ncc = 1:tcc
            ersp_tf{nrr,ncc} = ersp_tf_allch{nrr,ncc}(:,:,sel_ch_roi,:);
        end
    end
end

if alignt0
    
    sel_times = times >= 0;
    tsel_times = sum(sel_times);
    [trr, tcc] = size(ersp_tf);
    
    for nrr = 1:trr
        for ncc = 1:tcc
            ersp_mat = ersp_tf{nrr,ncc}(:,sel_times,:,:);
            ersp_mat0 = repmat(ersp_mat(:,1,:,:),1,tsel_times,1);
            ersp_tf{nrr,ncc} = ersp_mat - ersp_mat0;
        end
    end
    times = times(sel_times);
end
    

    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    disp('Error: the selected subjects are not represented in the selected design')
                    return;
                end                        
                ersp_tf{nf1,nf2}=ersp_tf{nf1,nf2}(:,:,:,vec_select_subjects);
                list_design_subjects{nf1,nf2}=list_design_subjects{nf1,nf2}(vec_select_subjects);
            end
        end
    end  

    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            ersp_tf{nf1,nf2} = squeeze(mean(ersp_tf{nf1,nf2},3));
        end
    end
    
     if strcmp(ersp_measure, 'Pfu')
       for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
                ersp_tf{nf1,nf2}=(10.^(ersp_tf{nf1,nf2}/10)-1)*100;

            end
       end   
    end

    [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_tf,num_tails,'groupstats','on','condstats','on','mcorrect','none','threshold', NaN,...
                                                                              'naccu',num_permutations,'method', stat_method,'paired',paired);          
    for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}) ; end;
    for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
    for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end;

    if ~ isempty(stat_freq_bands_list)
             [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp_f(pcond, pgroup, pinter,freqs, stat_freq_bands_list,mask_coef);           
    end

    if ~ isempty(stat_time_windows_list)
             [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,times, stat_time_windows_list);           

    end
    
    
output.ersp_tf              = ersp_tf;
output.times                = times;
output.freqs                = freqs;
output.pcond                = pcond;
output.pgroup               = pgroup;
output.pinter               = pinter;
output.list_design_subjects = list_design_subjects;

end
