%% function [OUTEEG, rt_cell] =  proj_eeglab_subject_mark_trial_begin(EEG, project)
%
%  mark begin of each trial
%
% project.preproc.insert_begin_trial.target_event_types         =   {'targe1','target2'};         % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers 
% project.preproc.insert_begin_trial.begin_trial_marker_type    =   {'begin_trial_marker_type'};  % string denoting the type (i.e. label) of the new begin trial marker, if empty ([]) begin_trial_marker_type = 'Begin_trial'
% project.preproc.insert_begin_trial.time_shift                 =   [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
%                                                                                                 %      with respect to the target events, if empty ([]) time shift = 0
%
function [OUTEEG] =  proj_eeglab_subject_mark_trial_begin(EEG, project)
 
     OUTEEG = EEG;
     
     params.event_types             = project.preproc.insert_begin_trial.target_event_types;       % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers 
     params.begin_trial_marker_type = project.preproc.insert_begin_trial.begin_trial_marker_type;  % string denoting the type (i.e. label) of the new begin trial marker, if empty ([]) begin_trial_marker_type = 'Begin_trial'
     params.time_shift              = project.preproc.insert_begin_trial.time_shift;               % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers       
                                                                                                   %      with respect to the target events, if empty ([]) time shift = 0
     OUTEEG = eeglab_mark_trial_begin(EEG, params);

end
