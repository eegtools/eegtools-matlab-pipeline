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

switch project.epoching.baseline_insert.mode
    
    case 'none'
        return
        
    case 'trial'
        baseline_file              = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
        EEG                        = pop_loadset(baseline_file);
        OUTEEG                     = proj_eeglab_subject_markbaseline_trial(EEG, project);
        
    case 'external'
        subj_list                  = {project.subjects.data.name};
        subj_index                 = ismember(subj_list, subj_name);
        target_events_file         = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
        baseline_file              = project.subjects(subj_index).data.baseline_file;
        
        if isempty(project.subjects(subj_index).data.baseline_file)
            baseline_file          = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix '.set']);
        end
        
        EEG_target                 = pop_loadset(target_events_file);
        EEG_baseline               = pop_loadset(baseline_file);
        OUTEEG                     = proj_eeglab_subject_markbaseline_external(EEG_target,EEG_baseline, project, subj_name);
end
OUTEEG = pop_saveset(OUTEEG, 'filename',['test_',OUTEEG.filename], 'filepath', OUTEEG.filepath);
end