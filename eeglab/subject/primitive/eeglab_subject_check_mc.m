function EEG  =  eeglab_subject_check_mc(EEG, checks, varargin)

if strcmp(checks.begin_trial.switch,'on')
    
    % ogni begin trial deve essere seguito da un end trial prima che da un
    % altro begin trial (al più l'end trial del trial corrente può
    % coincidere col begin trial successivo)
    
    begin_trial_marker = checks.begin_trial.input.begin_trial_marker;
    end_trial_marker   = checks.begin_trial.input.end_trial_marker;
    
    begin_ind = find(ismember({EEG.event.type},begin_trial_marker));
    begin_begin = [begin_ind(1:end-1);begin_ind(2:end)]';
    
    for nbi = 1:size(begin_begin,2)
    
        b1 = begin_begin(nbi,1);
        b2 = begin_begin(nbi,2);
        
        
        
    
    end
    
    

end


if strcmp(checks.end_trial.switch,'on')
end


if strcmp(checks.begin_baseline.switch,'on')
end


if strcmp(checks.end_baseline.switch,'on')
end


end