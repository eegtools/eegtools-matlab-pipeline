%% function OUTEEG = eeglab_subject_mark_rt_quantile(EEG, params )
%
% append to trial within different blocks with a string '_#percentile'. It is assumed that the begin of trials has been previously marked, e.g. by using eeglab_mark_trial_begin
%
% INPUT:
%
% params is a structure with the following fields:
%

%
function [OUTEEG, rt_stats] = eeglab_subject_mark_rt_quantile(EEG, params)

OUTEEG          = EEG;
rt_stats        =[];

rt_cell         = {OUTEEG.event.rt};


rt_vec  = [OUTEEG.event.rt];

find_rt = not(cellfun('isempty',rt_cell));

exist_rt = sum(find_rt);

if not(exist_rt)
    return;
end

rt_cell_noempty = rt_cell;

for neve = 1:length(rt_cell_noempty)
    if isempty(rt_cell_noempty{neve})
        rt_cell_noempty{neve} = NaN;
    end
end

rt_stats.median = median(rt_vec);
rt_stats.q.lower = [];
rt_stats.q.upper = [];



if not(isempty(params.pc.lower))
    
    sel_eve_lowerq   = false(length(rt_cell_noempty),1);
    sel_eve_upperq   = false(length(rt_cell_noempty),1);
    
    rt_stats.q.lower = quantile(rt_vec, params.pc.lower);
    
    for neve = 1:length(rt_cell_noempty)
        sel_eve_lowerq(neve)   = rt_cell_noempty{neve} < rt_stats.q.lower;
    end
    
    ind_eve_lowerq = find(sel_eve_upperq);
    
    eve_lowerq     = OUTEEG.event(ind_eve_lowerq);
    
    for neq = 1 : length(ind_eve_lowerq)
        
        nn             = length(OUTEEG.event)+1;
        OUTEEG.event(nn)       = eve_lowerq(neq);
        OUTEEG.event(nn).type = [OUTEEG.event(nn).type, '__upper_q_rt'];
        
    end
    
end


if not(isempty(params.pc.upper))
    
    rt_stats.q.upper = quantile(rt_vec, params.pc.upper);
    
    for neve = 1:length(rt_cell_noempty)
        sel_eve_upperq(neve)   = rt_cell_noempty{neve} > rt_stats.q.upper;
    end
    
    ind_eve_upperq = find(sel_eve_upperq);
    
    eve_lowerq     = OUTEEG.event(ind_eve_upperq);
    
    for neq = 1 : length(ind_eve_upperq)
        
        nn             = length(OUTEEG.event)+1;
        OUTEEG.event(nn)       = eve_lowerq(neq);
        OUTEEG.event(nn).type = [OUTEEG.event(nn).type, '__upper_q_rt'];
        
    end
    
end



end



