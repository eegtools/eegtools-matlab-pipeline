function [ersp_tf times freqs pcond, pgroup, pinter] = eeglab_study_roi_ersp_tf_decimate_times(STUDY, ALLEEG, channels_list,...
                                                                                               levels_f1, levels_f2,num_permutations,stat_time_windows_list,paired,stat_method,...
                                                                                               decimation_factor_times,...
                                                                                               list_select_subjects,list_design_subjects,ersp_mode)

    % function [ersp times freqs pcond, pgroup, pinter] = eeglab_study_roi_tf_grouptimes(STUDY, ALLEEG, channels_list, levels_f1, levels_f2,decimation_factor_times,correction,study_ls,num_permutations)
    % calculate ersp in the channels corresponding to the selected roi grouping times (obtaineing a time-frequency representation with a lowered time resolution) and perform statistics	
    % STUDY is an EEGLab study. 
    % ALLEEG is an EEGLab structure containing all EEG in the STUDY. 
    % channels_list is a cell array with a list of channels (usually the channels of a ROI). 
    % levels_f1 are the levels of the first factor in the selected STUDY design. 
    % levels_f2 are the levels of the second factor in the selected STUDY design. 
    % decimation_factor_times is the number of times to be grouped by averaging.
    % correction is a EEGLab statistical correction for multiple comparisons.
    % study_ls is the LS chosen for the analysis.
    % num_permutations il the number of permutations chosen for the analysis.     
    % masked_times_max is a time threshold (in ms): only times > masked_times_max will be considered for statistics on time-frequency representation.

    STUDY = pop_statparams(STUDY, 'groupstats','off','condstats','off');

    [STUDY ersp_tf times freqs]=std_erspplot(STUDY,ALLEEG,'channels',channels_list,'noplot','on');

    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            if ~isempty(list_select_subjects)
                vec_select_subjects=ismember(list_design_subjects{nf1,nf2},list_select_subjects);
                if ~sum(vec_select_subjects)
                    dis('Error: the selected subjects are not represented in the selected design')
                    return;
                end                        
                ersp_tf{nf1,nf2}=ersp_tf{nf1,nf2}(:,:,:,vec_select_subjects);
            end
        end
    end 


     if strcmp(ersp_mode, 'Pfu')
           for nf1=1:length(levels_f1)
                for nf2=1:length(levels_f2)
                    ersp_tf{nf1,nf2}=(10.^(ersp_tf{nf1,nf2}/10)-1)*100;
                end
           end
     end



    % averaging channels in the roi     
    for nf1=1:length(levels_f1)
        for nf2=1:length(levels_f2)
            M=squeeze(mean(ersp_tf{nf1,nf2},3));
            [total_freqs, total_times, total_subjects]= size(M);
            final_times_mat=fix(total_times/decimation_factor_times);
            fixed_times=decimation_factor_times*final_times_mat;
            M=M(:,1:fixed_times,:);
            tmp_times_mat =  reshape(M, [total_freqs decimation_factor_times final_times_mat total_subjects]);
            tmp_times_mat = squeeze(mean(tmp_times_mat,2));
            ersp_tf{nf1,nf2} = reshape(tmp_times_mat, [total_freqs final_times_mat total_subjects]);
        end
    end   


    tmp_times_vec=reshape(times(1:fixed_times),decimation_factor_times, final_times_mat);
    times= mean(tmp_times_vec);


    [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(ersp_tf,'groupstats','on','condstats','on','mcorrect','none','threshold',NaN,...
                                                                              'naccu',num_permutations,'method', stat_method,'paired',paired);          
    for ind = 1:length(pcond),  pcond{ind}  =  abs(pcond{ind}) ; end;
    for ind = 1:length(pgroup),  pgroup{ind}  =  abs(pgroup{ind}) ; end;
    for ind = 1:length(pinter),  pinter{ind}  =  abs(pinter{ind}) ; end;       

  if ~ isempty(stat_time_windows_list)
             [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,times, stat_time_windows_list);           

    end
    

end