%% function OUTEEG = eeglab_subject_mark_block(EEG, params )
%
% append to trial within different blocks with a string '_block#'. It is assumed that the begin of trials has been previously marked, e.g. by using eeglab_mark_trial_begin 
% 
% INPUT:
% 
% params is a structure with the following fields:
%
% params.tot_trial_block           = total number of trial per block
% params.begin_trial_marker_type   = string corresponding to the type (i.e. label) of the new begin trial markers, if empty ([]) begin_trial_marker_type = 'Begin_trial'
%
function OUTEEG = eeglab_subject_mark_block(EEG, params )
    
    OUTEEG = EEG;

    if isempty(params.begin_trial_marker_type)
        params.begin_trial_marker_type = 'Begin_trial';
    end

    ntoteve    = length(EEG.event);
    ind_toteve = 1:ntoteve;


    select_begin_trial_events = find(ismember({EEG.event.type}, params.begin_trial_marker_type));

    tot_blocks = length(select_begin_trial_events) / params.tot_trial_block;

    if ~isinteger(tot_blocks)
        disp('Please check the number of trial per block')
        return
    end


    for nblock = 1:tot_blocks

        if nblock ==1

            sel_eve_block = ind_toteve >= select_begin_trial_events(1) & ind_toteve <= select_begin_trial_events(params.tot_trial_block+1);    

        elseif nblock > 1 && nblock < tot_blocks

            sel_eve_block = ind_toteve >= select_begin_trial_events(nblock*params.tot_trial_block) & ind_toteve <= select_begin_trial_events(nblock*params.tot_trial_block+1)   ;

        else

            sel_eve_block = ind_toteve >= select_begin_trial_events(nblock*params.tot_trial_block); 

        end

          block_events = OUTEEG.event(sel_eve_block);

          for neve = 1: length(block_events)
            block_events(neve).type = [char(block_events(neve).type), '_block', str2double(nblock)]  ; 
            OUTEEG.event(ntoteve+1) =  block_events(neve);
            OUTEEG = eeg_checkset(OUTEEG);
            ntoteve = ntoteve+1;
          end
    end
end




    