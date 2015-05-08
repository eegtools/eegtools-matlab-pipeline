function results  =  eeglab_subject_check_mc(EEG, checks, varargin)

    errors = cell(1, length(EEG.event));
    % ========================================================================================
    % begin_trial
    % ogni begin trial deve essere seguito da un end trial prima che da un altro begin trial
    % al più l'end trial del trial corrente può coincidere col begin trial successivo)  
    % all'ultimo begin trial, controlla che ci sia un end trial dopo
    
    if strcmp(checks.begin_trial.switch,'on')

        begin_trial_marker  = checks.begin_trial.input.begin_trial_marker;
        begin_ind           = find(ismember({EEG.event.type}, {begin_trial_marker}));
        num_begin           = length(begin_ind);
        results.good_bt_et  = false(1, num_begin);
        begin_begin         = [begin_ind(1:end-1); begin_ind(2:end)]';

        % end_trial
        end_trial_marker    = checks.begin_trial.input.end_trial_marker;
        end_ind             = find(ismember({EEG.event.type}, {end_trial_marker}));
        
        for nbi = 1:size(begin_begin, 1)
            
            b1 = begin_begin(nbi,1);    b2 = begin_begin(nbi,2);
            v1 = end_ind >= b1;         v2 = end_ind <= b2;
            
            if sum(v1 & v2) == 1
                results.good_bt_et(nbi) = true;
            else
                errors{begin_ind(nbi)} = [errors{begin_ind(nbi)} 'begin_trial::end_trial '];
            end
        end
        if sum(end_ind > b2) == 1
            results.good_bt_et(num_begin) = true;
        else
            errors{begin_ind(nbi)} = [errors{begin_ind(nbi)} 'begin_trial::end_trial '];
        end
    end

    % ========================================================================================
    % end_trial 
    % ogni end trial deve essere seguito da un begin trial prima che da un altro end trial
    % al più l'begin trial del trial corrente può coincidere col end trial successivo)        
    
    if strcmp(checks.end_trial.switch,'on') 

        end_trial_marker    = checks.end_trial.input.end_trial_marker;
        end_ind             = find(ismember({EEG.event.type}, {end_trial_marker}));
        num_end             = length(end_ind);
        results.good_et_bt          = false(1, num_end);
        end_end             = [end_ind(1:end-1); end_ind(2:end)]';

        % begin trial
        begin_trial_marker  = checks.end_trial.input.begin_trial_marker;
        begin_ind           = find(ismember({EEG.event.type}, {begin_trial_marker}));
        
        for nei = 1:size(end_end,1)
            
            e1 = end_end(nei,1);        e2 = end_end(nei,2);
            v1 = begin_ind >= e1;       v2 = begin_ind <= e2;
            
            if sum(v1 & v2) == 1
                results.good_et_bt(nei) = true;
            else
                errors{end_ind(nei)} = [errors{end_ind(nei)} 'end_trial::begin_trial '];
            end
        end        
    end

    % ========================================================================================
    % begin_baseline 
    % controllo che ci sia sempre un solo end_baseline
    if strcmp(checks.begin_baseline.switch,'on') 
        
        begin_baseline_marker   = checks.begin_baseline.input.begin_baseline_marker;
        begin_ind               = find(ismember({EEG.event.type}, {begin_baseline_marker}));
        num_begin               = length(begin_ind);       
        results.good_bb_eb              = false(1, num_begin);
        
        % end_baseline_marker
        end_baseline_marker     = checks.begin_baseline.input.end_baseline_marker;        
        
        for bb=1:num_begin
            if strcmp(EEG.event(begin_ind(bb)+1).type, end_baseline_marker)
                results.good_bb_eb(bb) = true;
            else
                errors{begin_ind(bb)} = [errors{begin_ind(bb)} 'begin_baseline::end_baseline '];
            end
        end
    end

    % ========================================================================================
    % end_baseline
    % ogni end_baseline deve essere seguito da un begin baseline prima che da un altro end_baseline
    % inoltre dopo ogni end baseline ci deve essere un solo end trial.
    if strcmp(checks.end_baseline.switch,'on')
        
        end_baseline_marker         = checks.end_baseline.input.end_baseline_marker;
        eb_ind                      = find(ismember({EEG.event.type}, {end_baseline_marker}));
        num_eb                      = length(eb_ind);
        results.good_eb_bb          = false(1, num_eb);
        results.good_eb_et          = false(1, num_eb);
        end_end                     = [eb_ind(1:end-1); eb_ind(2:end)]';
        
        % begin_baseline
        begin_baseline_marker       = checks.end_baseline.input.begin_baseline_marker;
        bb_ind                      = find(ismember({EEG.event.type}, {begin_baseline_marker}));

        for nbi = 1:size(end_end,1)
            b1 = end_end(nbi,1);    b2 = end_end(nbi,2);
            v1 = bb_ind >= b1;      v2 = bb_ind <= b2;
            
            if sum(v1 & v2) == 1
                results.good_eb_bb(nbi) = true;
            else
                errors{eb_ind(nbi)} = [errors{eb_ind(nbi)} 'end_baseline::begin_baseline '];
            end
        end
        
        % end_trial_marker
        end_trial_marker            = checks.end_baseline.input.end_trial_marker;
        et_ind                      = find(ismember({EEG.event.type}, {end_trial_marker}));
        
        for nbi = 1:size(end_end,1)
            b1 = end_end(nbi,1);    b2 = end_end(nbi,2);
            v1 = et_ind >= b1;      v2 = et_ind <= b2;
            
            if sum(v1 & v2) == 1
                results.good_eb_et(nbi) = true;
            else
                errors{eb_ind(nbi)} = [errors{eb_ind(nbi)} 'end_baseline::end_trial_marker '];
            end
        end        
    end
    % ========================================================================================
    % ========================================================================================
    % summarize, display results
    results.errors.vector   = find(not(cellfun(@isempty, errors)));
    results.errors.msg      = errors(results.errors.vector);
    results.errors.num      = length(results.errors.vector);
    
    disp(['check trials triggers integrity on file ' EEG.filename]);
    if results.errors.num
        for res=1:results.errors.num

            results.errors.latencies(res) = EEG.event(results.errors.vector(res)).latency/EEG.srate;
            str = ['trigger ' num2str(results.errors.vector(res)) ', at latency : ' num2str(results.errors.latencies(res)) ', error msg: ' results.errors.msg{res}]; 
            disp(str);
        end
        results.can_epoch = 0;
        str               = 'errors!!';
    else
        results.can_epoch = 1;
        str               = 'OK';
    end
    
    disp('good trials available....');
    num_cond = size(checks.conditions_triggers, 1);
    for nc=1:num_cond
        results.trials_num(nc) = length(find(ismember({EEG.event.type}, checks.conditions_triggers{nc})));
        disp([num2str(results.trials_num(nc)) ' trials of condition ' num2str(nc)]);
    end
    
    disp([num2str(size(EEG.icaact,1)) ' ICA components are present in the file']);
    disp(['status: ' str]);
    
    % ========================================================================================
    % ========================================================================================
    % ========================================================================================
end