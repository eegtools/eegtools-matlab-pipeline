function [pcond, pgroup, pinter] = eeglab_study_roi_curve_maskp(pcond, pgroup, pinter,times, masked_times_max)
% masked_times_max is a time threshold (in ms): only times > masked_times_max will be considered for statistics on time-frequency representation.
        lcond=length(pcond);
        for nc=1:lcond
            masked_pcond=pcond{nc};
            masked_pcond(times<=masked_times_max)=1;
            pcond{nc}=masked_pcond;

        end
        
        lgroup=length(pgroup);
        for nc=1:lgroup
            masked_pgroup=pgroup{nc};
            masked_pgroup(times<=masked_times_max)=1;
            pgroup{nc}=masked_pgroup;

        end

        linter=length(pinter);
        for nc=1:linter
            masked_pinter=pinter{nc};
            masked_pinter(times<=masked_times_max)=1;
            pinter{nc}=masked_pinter;
        end
        
end