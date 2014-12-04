function EEG = proj_eeglab_subject_add_factor(project, subj_name)
    

    eeg_input_path  = project.paths.output_epochs;
    add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
    if ~isempty(add_factor_list)
        for nc=1:project.epoching.numcond
            cond_name=project.epoching.condition_names{nc};
            input_file_name=fullfile(eeg_input_path, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);
            [input_path,input_name_noext,input_ext] = fileparts(input_file_name);   
            
            if exist(input_file_name, 'file')                       

                EEG = pop_loadset(input_file_name);
                tot_eve=length(EEG.event);

                for nl=1:length(add_factor_list)
                    names_factors{nl}=add_factor_list(nl).factor;
                end
                names_factors=unique(names_factors);

                % inizializzo        
                for nf=1:length(names_factors)
                    for neve=1:tot_eve
                        str=['EEG.event(', num2str(neve), ').', names_factors{nf}, ' = ',  '''','nolevels','''' ,';'];
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
