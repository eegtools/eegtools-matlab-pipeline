%% function OUTEEG = proj_eeglab_subject_marktrial( project, varargin)
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
%
%      per la base in modalità external bisognerà, per ogni soggetto, poter
%      selezionare il file da cui prendere la baseline (default, stesso
%      file con gli eventi), il periodo  viene gestito qui: viene
%      automaticamente gestito dalla creazione degli eventi B1 e B2
%
% si presuppone che il file di base o il periodo di base nel file
% complessivo sia gà stato pulito, in maniera che per file esterni con la
% sola base si possano creare eventi liberamente su tutta la durata del
% file, mentre per base dentro il file complessivo bisognerà, per ogni
% soggetto, marcare nella struttura project l'inizio e la fine [t_inizio_base t_fine]
% per piazzare le serie di eventi b1 e b2. il parametro [t_inizio_base
% t_fine] potrebbe essere lasciato come facoltativo anche per i file di
% base esterni.
%
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
%
function OUTEEG = proj_eeglab_subject_marktrial( project, varargin)

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

    if not(iscell(project.preproc.insert_begin_trial.target_event_types)), project.preproc.insert_begin_trial.target_event_types = {project.preproc.insert_begin_trial.target_event_types}; end
    if not(iscell(project.preproc.insert_end_trial.target_event_types)),   project.preproc.insert_end_trial.target_event_types   = {project.preproc.insert_end_trial.target_event_types}; end

    % if not(iscell(project.preproc.marker_type.begin_trial)),               project.preproc.marker_type.begin_trial               = {project.preproc.marker_type.begin_trial}; end
    % if not(iscell(project.preproc.marker_type.end_trial)),                 project.preproc.marker_type.end_trial                 = {project.preproc.marker_type.end_trial}; end

    for subj=1:numsubj

        subj_name   = list_select_subjects{subj};
        input_file  = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);

%         EEG         = pop_loadset(input_file);
        [fpath,fname,fext] = fileparts(input_file);EEG = pop_loadset('filepath',fpath,'filename',[fname,fext]);
        
        
        aeve = {EEG.event.type};
        sel_nb = not(ismember(aeve,{project.preproc.marker_type.begin_trial,project.preproc.marker_type.end_trial}));
        EEG.event = EEG.event(sel_nb);

        
        OUTEEG      = EEG;

        c1          = sum(not(cellfun(@isempty,(project.preproc.insert_begin_trial.target_event_types))));
        c2          = not(isempty(project.preproc.marker_type.begin_trial));

        if (c1 && c2)
            OUTEEG = proj_eeglab_subject_mark_trial_begin(OUTEEG, project);
        end

        c1 = sum(not(cellfun(@isempty,(project.preproc.insert_end_trial.target_event_types))));
        c2 = not(isempty(project.preproc.marker_type.end_trial));

        if (c1 && c2)
            OUTEEG = proj_eeglab_subject_mark_trial_end(OUTEEG, project);
        end

        
        
%         % accoppio t1 e t2, t1 condiderati stabili
%         
%         alleve_type = {OUTEEG.event.type};
%         alleve_latency = [OUTEEG.event.latency];
%         
%         t1 = project.preproc.marker_type.begin_trial;
%         sel_t1 = find(ismember(alleve_type,t1));
%         lat_t1 = alleve_latency(sel_t1);
%         
%         t2 = project.preproc.marker_type.end_trial;
%         sel_t2 = find(ismember(alleve_type,t2));
%         lat_t2 = alleve_latency(sel_t2);
%         
%         bad_t2 = lat_t2 < lat_t1(1);
%         
%         
%         for nt1 = 1:length(sel_t1)
%             
%             sel_current_t2 = lat_t2 > lat_t1(nt1) & lat_t2 < lat_t1(nt1+1);
%             current_t2 = 
%         
%         end
        
        OUTEEG = eeg_checkset(OUTEEG);
        OUTEEG = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
    end
end