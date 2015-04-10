function OUTEEG = proj_eeglab_subject_markbaseline_trial(EEG, project, varargin)


% project.epoching.baseline_replace.baseline_begin_marker
% project.epoching.baseline_replace.baseline_end_marker
%
%
% project.epoching.baseline_mark.baseline_begin_target_marker                                    % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
% project.epoching.baseline_mark.baseline_begin_target_marker_delay.s                            % the delay (in seconds) between the target marker and the begin baseline marker to be placed:
%                                                                                                 % >0 means that baseline begin FOLLOWS the target,
%                                                                                                 % =0 means that baseline begin IS AT THE SAME TIME the target,
%                                                                                                 % <0 means that baseline begin ANTICIPATES the target.
%                                                                                                 % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data,
%                                                                                                 % or in milliseconds relative to the epoch's time-locking event for epoched data.
%                                                                                                 % As we will see in the event scripting section,
%                                                                                                 % the latency information is stored internally in data samples (points or EEGLAB 'pnts')
%                                                                                                 % relative to the beginning of the continuous data matrix (EEG.data).
%
% project.epoching.baseline_duration.s    = project.epoching.bc_end.s - project.epoching.bc_st.s ;


OUTEEG = EEG;


target_marker_delay_pts     =  floor(project.epoching.baseline_mark.baseline_begin_target_marker_delay.s * OUTEEG.srate); % convert delay from seconds to points
baseline_duration_pts       =  floor(project.epoching.baseline_duration.s * OUTEEG.srate);

sel_target_baseline = ismember({OUTEEG.event.type},project.epoching.baseline_mark.baseline_begin_target_marker);
eve_target_baseline = EEG.event(sel_target_baseline);

for neve = 1:length(eve_target_baseline)
    n1 = length(OUTEEG.event)+1;
    n2 = length(OUTEEG.event)+2;
    
    OUTEEG.event(n1)         =   eve_target_baseline(neve);
    OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + target_marker_delay_pts;
    OUTEEG.event(n1).type    =   project.preproc.marker_type.begin_baseline;
    
    
    OUTEEG.event(n2)         =   eve_target_baseline(neve);
    OUTEEG.event(n2).latency =   OUTEEG.event(n2).latency + target_marker_delay_pts + baseline_duration_pts;
    OUTEEG.event(n2).type    =   project.preproc.marker_type.end_baseline;
    
end

OUTEEG = eeg_checkset(OUTEEG);
end