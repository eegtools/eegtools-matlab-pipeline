
function brainstorm_remove_allsources_results(protocol_name, settings_path)

    % load configuration file
    [path,name_noext,ext] = fileparts(settings_path);
    addpath(path);    eval(name_noext);
    
    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    nsubj = bst_get('SubjectCount');
    subjects = bst_get('ProtocolSubjects');
    for ns=1:nsubj
        subj_name = subjects.Subject(ns).Name;
        for cond=1:length(name_cond)
            file_db_name=fullfile(subj_name, name_cond{cond} ,'data_average.mat');
            results = bst_get('ResultsForDataFile', file_db_name);
            if isstruct(results)
                num_res=length(results.Result);
                for nf=1:num_res
                    system(['rm -f ' fullfile(brainstorm_data_path, results.Result(nf).FileName)]);
                end
            end
        end 
    end
    db_reload_database(iProtocol);
end

