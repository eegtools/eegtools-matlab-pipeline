%% function [OUTEEG] =  proj_eeglab_subject_mark_block(EEG, project)
%
%  mark evens by block
%
% It is assumed that the begin of trials has been previously marked, e.g. by using eeglab_mark_trial_begin 
%
% project.preproc.mark_block.tot_trial_block           = total number of trial per block                                                                                              
% project.preproc.mark_block.begin_trial_marker_type   = string corresponding to the type (i.e. label) of the new begin trial markers, if empty ([]) begin_trial_marker_type = 'Begin_trial'                                                                                           
%
function [OUTEEG] =  proj_eeglab_subject_mark_block(EEG, project)
 
     OUTEEG = EEG;     
     params.tot_trial_block           = project.preproc.mark_block.tot_trial_block;
     params.begin_trial_marker_type   = project.preproc.mark_block.begin_trial_marker_type;
     
     OUTEEG = eeglab_subject_mark_trial_begin(OUTEEG, params);

end
