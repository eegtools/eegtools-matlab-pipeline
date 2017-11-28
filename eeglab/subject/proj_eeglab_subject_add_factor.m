%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_add_factor(project, varargin)

 if sum(ismember({project.study.factors.factor},'condition'))
    disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
    return
 end

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'add_factor';
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

    for subj=1:numsubj
        subj_name       = list_select_subjects{subj};

        eeg_input_path  = project.paths.output_epochs;
        add_factor_list = project.study.factors;
        % ----------------------------------------------------------------------------------------------------------------------------
        if not(isempty(add_factor_list))
            for nc=1:project.epoching.numcond
                cond_name                               = project.epoching.condition_names{nc};
                input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                [input_path,input_name_noext,input_ext] = fileparts(input_file_name);

                if exist(input_file_name, 'file')

                    EEG             = pop_loadset(input_file_name);
                    
                    
                    % remove factor condition which is reserved
                    if isfield(EEG.event,'condition')
                        EEG.event = rmfield(EEG.event,'condition');
                    end
                    
                    tot_eve         = length(EEG.event);

                    for nl=1:length(add_factor_list)
                        names_factors{nl} = add_factor_list(nl).factor;
                    end
                    names_factors   = unique(names_factors);

                    % inizializzo
                    for nf=1:length(names_factors)
                        for neve=1:tot_eve
                            str=char(['EEG.event(', num2str(neve), ').', names_factors{nf}, ' = ',  '''','nolevels','''' ,';']);
                            % display(str)
                            eval(str);
                        end
                        
                         for nepo=1:length(EEG.epoch)
                                str=['EEG.epoch(', num2str(nepo), ').', ['event' names_factors{nf}], ' = ',  '''','nolevels','''' ,';'];
                                eval(str);
                            
                         end
                        
                    end
                    % aggiungere un ciclo di for all'interno della lista, nb che dobbiamo avere un and: tutte le stringhe devono essere presenti
                    for nl=1:length(add_factor_list)
                        listf   = add_factor_list(nl).file_match;
                        nmatch  = 0;
                        for nf=1:length(listf)
                            nmatch=nmatch+~isempty(strfind(input_name_noext,listf{nf}));
                        end

                        if nmatch
                            for neve=1:tot_eve
                                str=['EEG.event(', num2str(neve), ').', char(add_factor_list(nl).factor), ' = ',  '''',char(add_factor_list(nl).level),'''' ,';'];
                                eval(str);
                            end

                            for nepo=1:length(EEG.epoch)
                                str=['EEG.epoch(', num2str(nepo), ').', ['event' char(add_factor_list(nl).factor)], ' = ',  '''',char(add_factor_list(nl).level),'''' ,';'];
                                eval(str);
                            end

                        end
                    end
                    EEG = pop_saveset( EEG, 'filename',input_name_noext,'filepath',input_path);

                else
                    disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                    %                 return;
                end
            end
        end
    end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name


