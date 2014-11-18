function OUTEEG = proj_eeglab_subject_marktrial(EEG, project,  varargin)
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

% % INSERT BEGIN TRIAL MARKERS
% project.preproc.insert_begin_trial.target_event_types         =   {'target1','target2'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers
% project.preproc.insert_begin_trial.begin_trial_marker_type    =   {'begin_trial_marker_type'};  % string denoting the type (i.e. label) of the new begin trial marker, if empty ([]) begin_trial_marker_type = 'begin_trial'
% project.preproc.insert_begin_trial.delay.s                    =   [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
%                                                                                                 %      with respect to the target events, if empty ([]) time shift = 0
%
% % INSERT END TRIAL MARKERS
% project.preproc.insert_end_trial.target_event_types         =     {'target1','target2'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the end trial markers
% project.preproc.insert_end_trial.begin_trial_marker_type    =     {'end_trial_marker_type'};    % string denoting the type (i.e. label) of the new end trial marker, if empty ([]) end_trial_marker_type = 'end_trial'
% project.preproc.insert_end_trial.delay.s                    =     [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new end trial markers
%



OUTEEG = EEG;


target_marker_begin_delay_pts     =  floor(project.preproc.insert_begin_trial.delay.s * OUTEEG.srate); % convert delay from seconds to points
target_marker_end_delay_pts       =  floor(project.preproc.insert_end_trial.delay.s   * OUTEEG.srate);



sel_target_begin = ismember({OUTEEG.event.type},project.preproc.insert_begin_trial.target_event_types);
sel_target_end   = ismember({OUTEEG.event.type},project.preproc.insert_end_trial.target_event_types);

eve_target_begin = EEG.event(sel_target_begin);

for neve = 1:length(eve_target_begin)
    n1 = length(OUTEEG.event)+1;
    OUTEEG.event(n1)         =   eve_target_begin(neve);
    OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + target_marker_begin_delay_pts;
    OUTEEG.event(n1).type    =   project.preproc.insert_begin_trial.begin_trial_marker_type;
end


eve_target_end = EEG.event(sel_target_end);

for neve = 1:length(eve_target_end)
    n1 = length(OUTEEG.event)+1;
    OUTEEG.event(n1)         =   eve_target_begin(neve);
    OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + target_marker_end_delay_pts;
    OUTEEG.event(n1).type    =   project.preproc.insert_end_trial.begin_trial_marker_type;
end



OUTEEG = eeg_checkset(OUTEEG);



end