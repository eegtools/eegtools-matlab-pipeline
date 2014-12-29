function EEG = proj_eeglab_subject_add_factor(project, varargin)

list_select_subjects  = project.subjects.list;


options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
        case 'pre_epoching_input_file_name'
            pre_epoching_input_file_name = varargin{opt+1};
    end
end
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj};
    
    eeg_input_path  = project.paths.output_epochs;
    add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
    if ~isempty(add_factor_list)
        for nc=1:project.epoching.numcond
            cond_name=project.epoching.condition_names{nc};
            input_file_name = proj_eeglab_subject_get_filename(project, subj_name,'add_factor','pre_epoching_input_file_name',pre_epoching_input_file_name,'cond_name',cond_name);...fullfile(eeg_input_path, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);
                [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
            
            if exist(input_file_name, 'file')
                
                EEG = pop_loadset(input_file_name);project.epoching.numcond;
                tot_eve=length(EEG.event);
                
                for nl=1:length(add_factor_list)
                    names_factors{nl}=add_factor_list(nl).factor;
                end
                names_factors=unique(names_factors);
                
                % inizializzo
                for nf=1:length(names_factors)
                    for neve=1:tot_eve
                        str=char(['EEG.event(', num2str(neve), ').', names_factors{nf}, ' = ',  '''','nolevels','''' ,';']);
                        % display(str)
                        eval(str);
                    end
                end
                % aggiungere un ciclo di for all'interno della lista, nb che dobbiamo avere un and: tutte le stringhe devono essere presenti
                for nl=1:length(add_factor_list)
                    listf=add_factor_list(nl).file_match;
                    nmatch=0;
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