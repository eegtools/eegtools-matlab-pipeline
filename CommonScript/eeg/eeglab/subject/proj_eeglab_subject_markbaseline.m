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


list_select_subjects  = project.subjects.list;

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);


switch project.epoching.baseline_replace.mode
    
    case 'none'
        return
        
    case 'trial'
        for subj=1:numsubj
            subj_name           = list_select_subjects{subj};
            baseline_file       = proj_eeglab_subject_get_filename(project, subj_name, 'output_import_data');
            EEG                 = pop_loadset(baseline_file);
            OUTEEG              = proj_eeglab_subject_markbaseline_trial(EEG, project);
            OUTEEG              = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
        end
        
    case 'external'
        for subj=1:numsubj
            subj_name           = list_select_subjects{subj};
            subj_index          = ismember(list_select_subjects, subj_name);
            target_events_file  = proj_eeglab_subject_get_filename(project, subj_name, 'output_import_data');
            baseline_file       = project.subjects(subj_index).data.baseline_file;
            
            if isempty(project.subjects(subj_index).data.baseline_file)
                baseline_file   = target_events_file;
            end
            
            EEG_target          = pop_loadset(target_events_file);
            EEG_baseline        = pop_loadset(baseline_file);
            OUTEEG              = proj_eeglab_subject_markbaseline_external(EEG_target,EEG_baseline, project, subj_name);
            OUTEEG              = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
        end
end

end