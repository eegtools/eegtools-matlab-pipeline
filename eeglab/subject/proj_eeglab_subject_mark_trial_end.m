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


sel_t1 = find(ismember({OUTEEG.event.type},project.preproc.marker_type.begin_trial));
lat_t1 = [OUTEEG.event(sel_t1).latency];
sel_1st_t1 = sel_t1(1);
lat_1st_t1 = lat_t1(1);

sel_boundary =  find(ismember({OUTEEG.event.type},'boundary'));
lat_boundary = [OUTEEG.event(sel_boundary).latency];


for ntarg = 1: length(project.preproc.insert_end_trial.target_event_types)
    
    target = project.preproc.insert_end_trial.target_event_types(ntarg);
    delay  = project.preproc.insert_end_trial.delay.s;
    
    
    delay_pts     =  floor(delay * OUTEEG.srate); % convert delay from seconds to points
    
    sel_target_t1 = [OUTEEG.event.latency] > lat_1st_t1;
    sel_target_end   = ismember({OUTEEG.event.type},target) & sel_target_t1;
    
    eve_target_end = EEG.event(sel_target_end);
    
    target_end_latency = [eve_target_end.latency];
    
    %     for neve = 1:length(eve_target_end)
    %         n1 = length(OUTEEG.event)+1;
    %         OUTEEG.event(n1)         =   eve_target_end(neve);
    %         OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + delay_pts + 1;
    %         OUTEEG.event(n1).type    =   project.preproc.marker_type.end_trial;
    %     end
    
    for nt1 = 1:length(sel_t1)-1
        % aggiungi un t2 se compreso tra t1 corrente e t1 prossimo
        lat_current_t1 = lat_t1(nt1);
        lat_netx_t1 = lat_t1(nt1+1);
        
        % vettore con i t2 messi fino ad ora 
        alleveup2now = {OUTEEG.event.type};
%         ind_alleveup2now = 1:length(alleveup2now);
        lat_alleveup2now = [OUTEEG.event.latency];
       
%         t2up2now = find(ismember(alleveup2now,project.preproc.marker_type.end_trial)); 
        t2up2now = ismember(alleveup2now,project.preproc.marker_type.end_trial); 

        lat_t2up2now = lat_alleveup2now(t2up2now);
        
        
        sel_current_boundary = lat_boundary > lat_current_t1 & lat_boundary < lat_netx_t1;
        
        prensent_boundary =  sum( sel_current_boundary);
        
        
        sel_current_t2 = lat_t2up2now> lat_current_t1 & lat_t2up2now < lat_netx_t1;
        
        already_prensent_t2 =  sum(sel_current_t2);
        
        
        if not(prensent_boundary) && not(already_prensent_t2)
            
            sel_current_t2 = target_end_latency > lat_current_t1 & target_end_latency < lat_netx_t1;
            
            valid_t2 = sum(sel_current_t2) == 1 ;
            
            if valid_t2
                n1 = length(OUTEEG.event)+1;
                OUTEEG.event(n1)         =   eve_target_end(sel_current_t2);
                OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + delay_pts + 1;
                OUTEEG.event(n1).type    =   project.preproc.marker_type.end_trial;
            end
        end
    end
    
    %all'ultimo aggiungi se esiste un t2 > t1
    nt1 = length(sel_t1);
    lat_current_t1 = lat_t1(nt1);
    
    sel_current_t2 = find(target_end_latency > lat_current_t1);
    if sum(sel_current_t2)
        
        sel_current_boundary = lat_boundary > lat_current_t1 & lat_boundary < sel_current_t2(1);
        
        prensent_boundary =  sum( sel_current_boundary);
        
        if not(prensent_boundary) &&  sum(sel_current_t2)
            n1 = length(OUTEEG.event)+1;
            OUTEEG.event(n1)         =   eve_target_end(sel_current_t2(1));
            OUTEEG.event(n1).latency =   OUTEEG.event(n1).latency + delay_pts + 1;
            OUTEEG.event(n1).type    =   project.preproc.marker_type.end_trial;
        end
        
    end
    
    
    
    
end

% pulisco i t2 disaccoppiati
sel_t2 = find(ismember({OUTEEG.event.type},project.preproc.marker_type.end_trial));
lat_t2 = [OUTEEG.event(sel_t2).latency];

bad_t1 = true(size(sel_t1));

for nt2 = 1:length(sel_t2)
    % aggiungi un t2 se compreso tra t1 corrente e t1 prossimo
    lat_current_t2 = lat_t2(nt2);
    lat_current_t1 = find(lat_t1 < lat_current_t2,1,'last');
    bad_t1(lat_current_t1) = false;
end

sel_bad_t1 = sel_t1(bad_t1);

tot_eve = length(OUTEEG.event);

all_eve_ind = 1:tot_eve;

sel_bad_eve = ismember(all_eve_ind, sel_bad_t1);
sel_good_eve = not(sel_bad_eve);
OUTEEG.event = OUTEEG.event(sel_good_eve);


sorted_event      = OUTEEG.event;
[xx sort_vec]     = sort([OUTEEG.event.latency]);
sorted_event      = sorted_event(sort_vec);
OUTEEG.event      = sorted_event;


OUTEEG = eeg_checkset(OUTEEG);

end