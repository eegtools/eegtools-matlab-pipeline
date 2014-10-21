%%function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,freqs, time_windows_list)
%  perform statistics only for selected time windows [tw1_start, tw1_end;tw2_start, tw2_end,... ]
function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp_f(pcond, pgroup, pinter,freqs, freq_bands_list,mask_coef)
    
    
        lcond=length(pcond);
        for nc=1:lcond
            masked_pcond=pcond{nc};
            
            mask_freqs= zeros(size(masked_pcond,1),1);            
            for nfb=1:size(freq_bands_list,1) % for each frequency band
                mask_freqs(freqs>=freq_bands_list(nfb,1) & freqs<=freq_bands_list(nfb,2))=1;
            end
            mask_freqs = mask_freqs==1;           
            masked_pcond(mask_freqs,:)= masked_pcond(mask_freqs,:)/mask_coef;
            pcond{nc}=masked_pcond;
        end
        
        lgroup=length(pgroup);
        for nc=1:lgroup
            masked_pgroup=pgroup{nc};
            masked_pgroup(mask_freqs,:)=masked_pgroup(mask_freqs,:)/mask_coef;
            pgroup{nc}=masked_pgroup;

        end

        linter=length(pinter);
        for nc=1:linter
            masked_pinter=pinter{nc};
            masked_pinter(mask_freqs,:)=masked_pinter(mask_freqs,:)/mask_coef;
            pinter{nc}=masked_pinter;
        end        
end