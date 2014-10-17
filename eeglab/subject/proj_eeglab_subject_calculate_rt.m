%% function [OUTEEG, rt_cell] =  proj_eeglab_subject_calculate_rt(EEG, project)
%  calculate reaction times
%
% project.preproc.rt.eve1_type               = string or cell array of strings with the first event(s) type(s) from which start
%                                              count the duration
% project.preproc.rt.eve2_type               = string with the second event type
%
% project.preproc.rt.allowed_tw_ms.min       = the minimum latency allowed for the duration beteween eve1 and eve2. if empty no inferior limit
% project.preproc.rt.allowed_tw_ms.max       = the maximum latency allowed for the duration beteween eve1 and eve2  if empty no superior limit
%
% project.preproc.rt.output_folder           = the folder where the rt files will be placed, if empty the same folder of the eeg data file
%
function [OUTEEG, rt_cell] =  proj_eeglab_subject_calculate_rt(EEG, project)

    params.eve1_type         = project.preproc.rt.eve1_type;
    params.eve2_type         = project.preproc.rt.eve2_type;
    params.allowed_tw_ms.min = project.preproc.rt.allowed_tw_ms.min;
    params.allowed_tw_ms.max = project.preproc.rt.allowed_tw_ms.max;
    params.output_folder     = project.preproc.rt.output_folder;
    
    [OUTEEG, rt_cell] =  eeglab_subject_calculate_rt(EEG, params);

end