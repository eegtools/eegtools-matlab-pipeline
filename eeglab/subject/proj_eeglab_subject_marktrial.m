function EEG = proj_eeglab_subject_marktrial(project, subj_name, varargin)
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

end