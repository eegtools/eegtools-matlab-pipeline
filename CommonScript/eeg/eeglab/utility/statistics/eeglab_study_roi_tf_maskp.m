%%function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,times, time_windows_list)
%  perform statistics only for selected time windows [tw1_start, tw1_end;tw2_start, tw2_end,... ]
function [pcond, pgroup, pinter] = eeglab_study_roi_tf_maskp(pcond, pgroup, pinter,times, time_windows_list)
    
    
        lcond=length(pcond);
        for nc=1:lcond
            masked_pcond=pcond{nc};
            
            mask_times= zeros(size(masked_pcond,2),1);            
            for ntw=1:size(time_windows_list,1) % for each time window
                mask_times(times>=time_windows_list(ntw,1) & times<=time_windows_list(ntw,2))=1;
            end
            mask_times = ~mask_times;           
            masked_pcond(:,mask_times)=1;
            pcond{nc}=masked_pcond;
        end
        
        lgroup=length(pgroup);
        for nc=1:lgroup
            masked_pgroup=pgroup{nc};
            masked_pgroup(:,mask_times)=1;
            pgroup{nc}=masked_pgroup;

        end

        linter=length(pinter);
        for nc=1:linter
            masked_pinter=pinter{nc};
            masked_pinter(:,mask_times)=1;
            pinter{nc}=masked_pinter;
        end        
end