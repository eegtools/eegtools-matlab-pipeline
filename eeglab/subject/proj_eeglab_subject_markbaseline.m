%% function OUTEEG = proj_eeglab_subject_markbaseline(project, varargin)
%
% per la base in modalità external bisognerà, per ogni soggetto, poter
% selezionare il file da cui prendere la baseline (default, stesso
% file con gli eventi), il periodo  viene gestito qui: viene
% automaticamente gestito dalla creazione degli eventi B1 e B2
% si presuppone che il file di base o il periodo di base nel file
% complessivo sia gà stato pulito, in maniera che per file esterni con la
% sola base si possano creare eventi liberamente su tutta la durata del
% file, mentre per base dentro il file complessivo bisognerà, per ogni
% soggetto, marcare nella struttura project l'inizio e la fine [t_inizio_base t_fine]
% per piazzare le serie di eventi b1 e b2. il parametro [t_inizio_base
% t_fine] potrebbe essere lasciato come facoltativo anche per i file di
% base esterni.

function OUTEEG = proj_eeglab_subject_markbaseline(project, varargin)

list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
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
% -------------------------------------------------------------------------------------------------------------------------------------

if (iscell(project.preproc.marker_type.begin_baseline)), project.preproc.marker_type.begin_baseline = project.preproc.marker_type.begin_baseline{:}; end
if (iscell(project.preproc.marker_type.end_baseline)), project.preproc.marker_type.end_baseline = project.preproc.marker_type.end_baseline{:}; end
if not(iscell(project.preproc.insert_begin_baseline.target_event_types)), project.preproc.insert_begin_baseline.target_event_types = {project.preproc.insert_begin_baseline.target_event_types}; end
if not(iscell(project.preproc.insert_end_baseline.target_event_types)), project.preproc.insert_end_baseline.target_event_types = {project.preproc.insert_end_baseline.target_event_types}; end


switch project.epoching.baseline_replace.mode
    
    case 'none'
        return
        
    case 'trial'
        for subj=1:numsubj
            subj_name           = list_select_subjects{subj};
            baseline_file       = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            EEG                 = pop_loadset(baseline_file);
            
            aeve = {EEG.event.type};
            sel_nb = not(ismember(aeve,{project.preproc.marker_type.begin_baseline,project.preproc.marker_type.end_baseline}));
            EEG.event = EEG.event(sel_nb);
            
            OUTEEG              = proj_eeglab_subject_markbaseline_trial(EEG, project);
            OUTEEG              = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
        end
        
    case 'external'
        for subj=1:numsubj
            subj_name           = list_select_subjects{subj};
            subj_index          = ismember(project.subjects.list, subj_name);
            target_events_file  = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            baseline_file       = project.subjects.data(subj_index).baseline_file;
            
            if isempty(project.subjects.data(subj_index).baseline_file)
                baseline_file   = target_events_file;
            end
            
            EEG_target          = pop_loadset(target_events_file);
            EEG_baseline        = pop_loadset(baseline_file);
            if not(isempty(project.subjects.data(subj_index).baseline_file))
                if isstruct(EEG_baseline.event)
                    aeve = {EEG_baseline.event.type};
                    sel_nb = not(ismember(aeve,{'boundary',project.preproc.marker_type.begin_baseline,project.preproc.marker_type.end_baseline}));
                    EEG_baseline.event = EEG_baseline.event(sel_nb);
                end
                aeve = {EEG_target.event.type};
                sel_nb = not(ismember(aeve,{project.preproc.marker_type.begin_baseline,project.preproc.marker_type.end_baseline}));
                EEG_target.event = EEG_target.event(sel_nb);
           
            
            
            end
            
            
            OUTEEG              = proj_eeglab_subject_markbaseline_external(EEG_target,EEG_baseline, project, subj_name);
            OUTEEG              = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
        end
end

end