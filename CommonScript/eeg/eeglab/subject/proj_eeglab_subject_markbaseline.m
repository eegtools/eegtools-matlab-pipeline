function OUTEEG = proj_eeglab_subject_markbaseline(project, subj_name, varargin)

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


OUTEEG = EEG;

if strcmp(project.epoching.baseline_insert.mode, 'none')
    return
end


if strcmp(project.epoching.baseline_insert.mode, 'trial')
    
    OUTEEG =  proj_eeglab_subject_markbaseline_trial(EEG, project);
    
end

if strcmp(project.epoching.baseline_insert.mode, 'external')
    OUTEEG =  proj_eeglab_subject_markbaseline_external(EEG, project, subj_name);
end
