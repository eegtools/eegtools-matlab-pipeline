function OUTEEG = proj_eeglab_subject_mark_trial_end(EEG, project,  varargin)
%
% argomenti:
% 2 terne:
%
% label evento inizio
% dt rispetto a evento inizio
% label nuovo marker inizio tria
%
% label evento fine
% dt rispetto a evento fine
% label nuovo marker fine tria
%
%
% label inizio e e fine fine evento potrebbero essere le stesse

%      per la base in modalità external bisognerà, per ogni soggetto, poter
%      selezionare il file da cui prendere la baseline (default, stesso
%      file con gli eventi), il periodo  viene gestito qui: viene
%      automaticamente gestito dalla creazione degli eventi B1 e B2

% si presuppone che il file di base o il periodo di base nel file
% complessivo sia gà stato pulito, in maniera che per file esterni con la
% sola base si possano creare eventi liberamente su tutta la durata del
% file, mentre per base dentro il file complessivo bisognerà, per ogni
% soggetto, marcare nella struttura project l'inizio e la fine [t_inizio_base t_fine]
% per piazzare le serie di eventi b1 e b2. il parametro [t_inizio_base
% t_fine] potrebbe essere lasciato come facoltativo anche per i file di
% base esterni.
%
% % INSERT END TRIAL MARKERS
% project.preproc.insert_end_trial.target_event_types         =     {'target1','target2'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the end trial markers
% project.preproc.insert_end_trial.end_trial_marker_type    =     {'end_trial_marker_type'};    % string denoting the type (i.e. label) of the new end trial marker, if empty ([]) end_trial_marker_type = 'end_trial'
% project.preproc.insert_end_trial.delay.s                    =     [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new end trial markers
%

OUTEEG = EEG;


for ntarg = 1: length(project.preproc.insert_end_trial.target_event_types)
    
    target = project.preproc.insert_end_trial.target_event_types(ntarg);
    delay  = project.preproc.insert_end_trial.delay.s;
    
    
    delay_pts     =  floor(delay * OUTEEG.srate); % convert delay from seconds to points
    
    sel_target_end   = ismember({OUTEEG.event.type},target);
    
    eve_target_end = EEG.event(sel_target_end);
    
    for neve = 1:length(eve_target_end)
        n1 = length(OUTEEG.event)+1;
        OUTEEG.event(n1)         =   eve_target_end(neve);
        OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + delay_pts + 1;
        OUTEEG.event(n1).type    =   project.preproc.marker_type.end_trial;
    end
    
end

sorted_event      = OUTEEG.event;
[xx sort_vec]     = sort([OUTEEG.event.latency]);
sorted_event      = sorted_event(sort_vec);
OUTEEG.event      = sorted_event;


OUTEEG = eeg_checkset(OUTEEG);

end