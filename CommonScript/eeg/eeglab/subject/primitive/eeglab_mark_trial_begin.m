%% function OUTEEG = eeglab_subject_mark_trial_begin(OUTEEG, params )
%
% insert markers of trial begin at the latency of provided event types.
%
% INPUT:
%
% params is a structure with the following fields:
%
% params.target_event_types                   = string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers 
%
% params.begin_trial_marker_type              = string denoting the type (i.e. label) of the new begin trial marker, if empty ([]) begin_trial_marker_type = 'Begin_trial'
%
% params.time_shift                           = time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
%                                               with respect to the target events, if empty ([]) time shift = 0
%
function OUTEEG = eeglab_subject_mark_trial_begin(EEG, params )
    
    OUTEEG = EEG;

    if isempty(params.begin_trial_marker_type)
        params.begin_trial_marker_type = 'Begin_trial';
    end

    if isempty(params.time_shift)
        params.time_shift = 0;
    end

    select_begin_trial_events = ismember({OUTEEG.event.type}, params.target_event_types);

    begin_trial_events = OUTEEG.event(select_begin_trial_events);

    ntoteve = length(OUTEEG.event);
    
    for neve = 1: length(begin_trial_events)
        begin_trial_events(neve).type = params.begin_trial_marker_type;
        begin_trial_events(neve).latency = begin_trial_events(neve).latency + params.time_shift;        
        OUTEEG.event(ntoteve+1) = begin_trial_events(neve);
        OUTEEG = OUTEEG_checkset(OUTEEG);
        ntoteve = ntoteve+1;
    end
end
