% within a scout structure
% rows are scout
% columns are timepoint
function fileID = brainstorm_subject_scouts_export_2factors(db_name, subjects_list, condition_names, associated_factors, factors_names, input_file_name, varargin)
    iProtocol               = brainstorm_protocol_open(db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    len_cond                = length(condition_names);

    dataexpcols             = {'subject', 'cond', factors_names{1}, factors_names{2}, 'scout', 'time', 'value'};    
    formatSpecData          = ['%s\t%s\t%s\t%s\t%s\t%d\t%f\r\n'];
    formatSpecCols          = [repmat('%s\t',1,6),'%s\r\n'];
    
    
    if isempty(varargin)
        output_file_name    = fullfile(brainstorm_data_path, ['scout_export_' input_file_name '.dat']);
    else
        output_file_name    = varargin{1};
    end
    
    
    fileID                  = fopen(output_file_name,'w');
    fprintf(fileID,formatSpecCols,dataexpcols{:});
    
    for nsubj=1:len_subj
        for ncond=1:len_cond
            
            subj_name   = subjects_list{nsubj};
            cond_name   = condition_names{ncond};
            f1_level    = associated_factors(ncond).f1_level;
            f2_level    = associated_factors(ncond).f2_level;
            
            filename    = fullfile(brainstorm_data_path, subj_name, cond_name, ['matrix_' cond_name '_' input_file_name '.mat']);
            scout       = load(filename);
            
            values      = scout.Value;
            
            if (nsubj == 1 && ncond == 1)
                [scouts_names, time_names] = init_data(scout);
            end
            
            for sc=1:length(scouts_names)
                scn = scouts_names{sc};
                for tw=1:length(time_names)
                    twn = time_names(tw);
                    data_row = {subj_name, cond_name, f1_level, f2_level, scn, twn, values(sc, tw)*1000000000000000};
                    fprintf(fileID, formatSpecData, data_row{:});
                end
            end
        end
    end
    fclose(fileID);
end




function [scouts_names, times] = init_data(scout)
    % scout names
     scouts_names   = {scout.Atlas.Scouts.Label};
     times          = scout.Time;
     
end
