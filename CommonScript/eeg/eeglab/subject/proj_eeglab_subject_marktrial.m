function OUTEEG = proj_eeglab_subject_marktrial( project, varargin)
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

% % INSERT BEGIN TRIAL MARKERS (only if both the target and the begin trial
% % types are NOT empty)
% project.preproc.insert_begin_trial.target_event_types         =   {'target1','target2'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers
% project.preproc.insert_begin_trial.begin_trial_marker_type    =   {'begin_trial_marker_type'};  % string denoting the type (i.e. label) of the new begin trial marker
% project.preproc.insert_begin_trial.delay.s                    =   [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
%                                                                                                 %      with respect to the target events, if empty ([]) time shift = 0.
%
% % INSERT END TRIAL MARKERS (only if both the target and the begin trial
% % types are NOT empty)
% project.preproc.insert_end_trial.target_event_types         =     {'target1','target2'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the end trial markers
% project.preproc.insert_end_trial.end_trial_marker_type    =     {'end_trial_marker_type'};    % string denoting the type (i.e. label) of the new end trial marker
% project.preproc.insert_end_trial.delay.s                    =     [];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new end trial markers
%


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


if not(iscell(project.preproc.insert_begin_trial.target_event_types)), project.preproc.insert_begin_trial.target_event_types = {project.preproc.insert_begin_trial.target_event_types}; end


if not(iscell(project.preproc.insert_end_trial.target_event_types)),   project.preproc.insert_end_trial.target_event_types   = {project.preproc.insert_end_trial.target_event_types}; end


% if not(iscell(project.preproc.marker_type.begin_trial)),               project.preproc.marker_type.begin_trial               = {project.preproc.marker_type.begin_trial}; end
% 
% if not(iscell(project.preproc.marker_type.end_trial)),                 project.preproc.marker_type.end_trial                 = {project.preproc.marker_type.end_trial}; end



numsubj = length(list_select_subjects);

for subj=1:numsubj
    
    
    subj_name   = list_select_subjects{subj};
    input_file   = proj_eeglab_subject_get_filename(project, subj_name, 'output_import_data');
    
    EEG                        = pop_loadset(input_file);
    
    OUTEEG = EEG;
    
    
    
    c1 = sum(not(cellfun(@isempty,(project.preproc.insert_begin_trial.target_event_types))));
    c2 = not(isempty(project.preproc.marker_type.begin_trial));
    
    if (c1 && c2)
        
        OUTEEG = proj_eeglab_subject_mark_trial_begin(OUTEEG, project);
        
    end
    
    c1 = sum(not(cellfun(@isempty,(project.preproc.insert_end_trial.target_event_types))));
    c2 = not(isempty(project.preproc.marker_type.end_trial));
    
    if (c1 && c2)
        
        OUTEEG = proj_eeglab_subject_mark_trial_end(OUTEEG, project);
        
    end
    
    
    OUTEEG = eeg_checkset(OUTEEG);
    OUTEEG = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
    
end

end