%% function OUTEEG = proj_eeglab_subject_replacebaseline(project, subj_name,varargin)% mode: 'trial', 'external', 'none'
%
% si suppone che siano già stati creati eventi b1 e b2
% l'utente deve dire se riallineare le baseline a b1 o a b2
% NO BISOGNA PRENDERE SEMPRE LA STSSA LUNGHETZZA, RICONDURSI A BASI DI
% LUNGHEZZA UGUALE,QUINDI, PER CHI NE HA SI TAGLIA, PER CHI NON NE HA
% BISOGNA AGGIUNGERNE
% l'utente può porre la baseline prima o dopo l'evento di interesse
% nota: se faccio un eppching devo tornare al continuo pe poi fare
% l'epoching vero e proprio? in realtà no, posso epocare un file già
% epocato ma in quel caso mi devo portare dietrotutti gli eventi ( edevo
% piazzare la baseline sempre o prima o dopo per tutte le classi di eventi,
% impostazione rigida 1 project =  1 epoching (finestra temporale)
% l'epoching e la durata delle epoce deve essere compatibile con
%
%  potrei registrare il vettore con le durate delle baseline, magari anche
%  media deviaz st mediana e range.
%
% la base può precedere o seguire l'evento da triggerare
%
% attenzione: scelgo via conservativa in cui prima segmento i trial e
% quindi mi vengono rimossi automaticamente quelli con dentro boundary, poi
% quindi ho automaticamente l'acccoppiamento di baseline e target (preso ciascuno separatamente)
%
% ########################################################################
% IMPORTANT NOTE: It is assumed that in the artifact rejection phase, all
% the trials with the rejection of the baseline OR the target event are
% removed. If not, proplem occur when aliging newly replaceed baselines and target events.
% ########################################################################
%
% adjust baseline by replaceing before / after target events in each trial baseline segments.
%
% in the 'none' mode no baseline adjustement occurs
%
% in the 'trial' mode baseline segments are taken within the same trial and were originally placed before / after the target events
%
% and project is a structure with the fields:
%
%  project.epoching.epo_st.s;
%  project.epoching.epo_end.s;
%  project.epoching.mrkcode_cond;
%  project.epoching.baseline_replace.baseline_begin_marker;
%  project.epoching.baseline_replace.baseline_end_marker;
%  project.epoching.bc_st.s;
%  project.epoching.bc_end.s;
%  project.epoching.baseline_replace.mode;
%  project.epoching.baseline_replace.baseline_originalposition;
%  project.epoching.baseline_replace.baseline_finalposition;
%  project.epoching.baseline_duration.s
%
%
% in the 'external' mode baseline segments are taken outside trials, from
% the same recording with the target events or  from an external file
%
% NOTE: trials with boundary events are discharged from epoching


function OUTEEG = proj_eeglab_subject_replacebaseline(project, list_select_subjects, varargin)


    get_filename_step       = 'input_epoching';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
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
    
    for subj=1:numsubj

        subj_name               = list_select_subjects{subj};
    
        input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix' , custom_suffix, 'custom_input_folder', custom_input_folder);
        EEG                     = pop_loadset(input_file_name);
        
     
        EEG.icaact_unfiltered=[];
        EEG.icaact_filtered_resampled=[];
        EEG.dipfit=[];
        EEG.icaact=[];
        EEG.etc =[];
        EEG.reject=[];
        EEG.stats=[];
        EEG.virtual_topography=[];
        EEG.virtual_chanlocs=[];
        EEG.virtual_nbchan=[];

        bck.dir                 = fullfile(EEG.filepath, 'hist_pre_replacebaseline');
        bck.prefix              = [];
        EEG                     = eeglab_subject_bck_eeghist(EEG,bck);

        % if strcmp(project.epoching.baseline_replace.create_backup,'on')
        %     
        %     bck.dir = fullfile(EEG.filepath,'bck_pre_replacebaseline');
        %     bck.prefix = [];   
        %     EEG = eeglab_subject_bck_eeg(EEG,bck);    
        %        
        % end


        switch project.epoching.baseline_replace.mode
            case 'none'
                return

            case 'trial'
                OUTEEG =  proj_eeglab_subject_replacebaseline_trial(EEG, project);

            case 'external'
                OUTEEG =  proj_eeglab_subject_replacebaseline_external(EEG, project, subj_name);

        end
        if isempty(OUTEEG)
            disp ('error in proj_eeglab_subject_replacebaseline');
           return 
        end
    end
end

