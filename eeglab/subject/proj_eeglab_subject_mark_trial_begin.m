function OUTEEG = proj_eeglab_subject_mark_trial_begin(EEG, project,  varargin)
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


OUTEEG = EEG;
alleve_lat = [EEG.event.latency];
alleve_lab = {EEG.event.type};

sel_boundary = ismember(alleve_lab, 'boundary');
lat_boundary = alleve_lat(sel_boundary);

for ntarg = 1: length(project.preproc.insert_begin_trial.target_event_types)
    
    target = project.preproc.insert_begin_trial.target_event_types(ntarg);
    delay  = project.preproc.insert_begin_trial.delay.s;
    
    delay_pts     =  floor(delay * OUTEEG.srate); % convert delay from seconds to points
    
    sel_target_begin = ismember({OUTEEG.event.type},target);
    
    eve_target_begin = EEG.event(sel_target_begin);
    
    for neve = 1:length(eve_target_begin)
        
        target_candidate = eve_target_begin(neve);
        
        lat_target_candidate = target_candidate.latency;
        lat_current_t1_candidate= lat_target_candidate + delay_pts-1;
        
        boundary_between_t1_target = lat_boundary >= lat_current_t1_candidate  & lat_boundary <= lat_target_candidate ;
        
       
        
        
        
        if sum(boundary_between_t1_target) == 0 
            n1 = length(OUTEEG.event)+1;
            OUTEEG.event(n1)         =   eve_target_begin(neve);
            OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + delay_pts-1;
            OUTEEG.event(n1).type    =   project.preproc.marker_type.begin_trial;
        end
    end
    
end

sorted_event      = OUTEEG.event;
[xx sort_vec]     = sort([OUTEEG.event.latency]);
sorted_event      = sorted_event(sort_vec);
OUTEEG.event      = sorted_event;
OUTEEG.event      = OUTEEG.event([OUTEEG.event.latency]>=0);

OUTEEG = eeg_checkset(OUTEEG);



end