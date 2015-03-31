%%function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,freqs, time_windows_list)
%  perform statistics only for selected time windows [tw1_start, tw1_end;tw2_start, tw2_end,... ]
function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp_f(pcond, pgroup, pinter,freqs, freq_bands_list,mask_coef)


%         lcond=length(pcond);
%         for nc=1:lcond
%             masked_pcond=pcond{nc};
% 
%             mask_freqs= zeros(size(masked_pcond,1),1);
%             for nfb=1:size(freq_bands_list,1) % for each frequency band
%                 mask_freqs(freqs>=freq_bands_list(nfb,1) & freqs<=freq_bands_list(nfb,2))=1;
%             end
%             mask_freqs = mask_freqs==1;
%             masked_pcond(mask_freqs,:)= masked_pcond(mask_freqs,:)/mask_coef;
%             pcond{nc}=masked_pcond;
%         end

lcond=length(pcond);

ff = freqs(2)-freqs(1);

for nc=1:lcond
    masked_pcond=pcond{nc};
    lt = size(masked_pcond,2);
    df = repmat([1:5]*ff,lt);
    ldf = length(df);
    [x, idf1]=sort(rand(1,ldf));
    [x, idf2]=sort(rand(1,ldf));
    
    dff1 = df(idf1);
    dfff1 = smooth(dff1(1:lt));
    
    
    dff2 = df(idf2);
    dfff2 = smooth(dff2(1:lt));
    
    
    mask_freqs= zeros(size(masked_pcond));
    for nfb=1:size(freq_bands_list,1) % for each frequency band
        for nt=1:lt % for each time window
            
            f1 = freq_bands_list(nfb,1) - dfff1(nt);
            f2 = freq_bands_list(nfb,2) + dfff2(nt);
            mask_freqs(freqs>=f1 & freqs<=f2,nt)=1;
        end
    end
    
%     mask_freqs = ~mask_freqs;
%     masked_pcond(mask_freqs)=1;
%     pcond{nc}=masked_pcond;
            mask_freqs = mask_freqs==1;
            masked_pcond(mask_freqs)= masked_pcond(mask_freqs)/mask_coef;
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