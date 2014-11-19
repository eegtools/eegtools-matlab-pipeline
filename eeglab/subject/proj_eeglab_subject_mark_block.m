%% function [OUTEEG] =  proj_eeglab_subject_mark_block(EEG, project)
%
%  mark evens by block
%
% It is assumed that the begin of trials has been previously marked, e.g. by using eeglab_mark_trial_begin
%

% INSERT BLOCK MARKERS (only if
% project.preproc.insert_begin_trial.begin_trial_marker_type is non empty)
% project.preproc.insert_block.trials_per_block                                = 40;              % number denoting the number of trials per block
% project.preproc.mark_block.begin_trial_marker_type   = string corresponding to the type (i.e. label) of the new begin trial markers, if empty ([]) begin_trial_marker_type = 'Begin_trial'
%
% note: current version create new events adding to the orginal event types
% the suffix '-#block'. It DOES NOT create events begin/end for each block
%
function [OUTEEG] =  proj_eeglab_subject_mark_block(EEG, project)

OUTEEG = EEG;

if isempty(project.preproc.insert_begin_trial.begin_trial_marker_type) || project.preproc.insert_block.trials_per_block
    return;
else
    sel_trial_begin = find(ismember({OUTEEG.event.type},project.preproc.insert_begin_trial.begin_trial_marker_type));
    
    % check if number of trials per block and number of blocks are coherent
    incoherent_blocks = not(rem(length(sel_trial_begin),project.preproc.insert_block.trials_per_block) == 0);
    
    if incoherent_blocks
        return;
    else
        tot_blocks   =  length(sel_trial_begin)/project.preproc.insert_block.trials_per_block;
        block_limits =  sel_trial_begin(1:project.preproc.insert_block.trials_per_block:end);
        block_begin  =  block_limits(1:(end-1));
        block_end    =  block_limits(2:end);
        eve_ind      =  1:length(EEG.event);
        
        for nblock = 1:tot_blocks
            
            sel_eve_block = eve_ind >= block_begin(nblock) & eve_ind < block_end(nblock);
            eve_block     = EEG.event(sel_eve_block);
            
            for neve = 1:length(eve_block)
                n1 = length(OUTEEG.event)+1;
                OUTEEG.event(n1)         =   eve_block(neve);
                OUTEEG.event(n1).type    =   [OUTEEG.event(n1).type,'-block',num2str(nblock)];
            end
            
        end
        
        
        OUTEEG = eeg_checkset(OUTEEG);
        
    end
    
end



end
