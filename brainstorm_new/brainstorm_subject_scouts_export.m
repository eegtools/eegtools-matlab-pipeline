% within a scout structure
% rows are scout
% columns are timepoint
% accept a period_labels cell array to substitute the timepoints values
function fileID = brainstorm_subject_scouts_export(db_name, subjects_list, cond_list, input_file_name, varargin)
    iProtocol               = brainstorm_protocol_open(db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    len_cond                = length(cond_list);
    
    % default values
    output_file_name        = fullfile(brainstorm_data_path, ['scout_export_' input_file_name '.dat']);
    append                  = 0;
    values_multiplier       = 1;
    period_labels           = [];
    
    % optional values
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'output_file_name'
                output_file_name    = fullfile(brainstorm_data_path, varargin{opt+1});
            case 'append'
                append              = varargin{opt+1};                
            case 'values_multiplier'
                values_multiplier   = varargin{opt+1};                      
            case 'period_labels'
                period_labels       = varargin{opt+1};
        end
    end
    if isempty(period_labels)    
        formatSpecData          = ['%s\t%s\t%s\t%d\t%f\r\n'];
    else
        formatSpecData          = ['%s\t%s\t%s\t%s\t%f\r\n'];
    end
    
    if append
        fileID                  = fopen(output_file_name,'a');
    else
        dataexpcols             = {'subject', 'cond','scout','time','value'};
        formatSpecCols          = [repmat('%s\t',1,4),'%s\r\n'];
        fileID                  = fopen(output_file_name,'w');
        fprintf(fileID,formatSpecCols,dataexpcols{:});
    end
    
    for nsubj=1:len_subj
        for ncond=1:len_cond
            
            subj_name   = subjects_list{nsubj};
            cond_name   = cond_list{ncond};
            
            filename    = fullfile(brainstorm_data_path, subj_name, cond_name, ['matrix_' cond_name '_' input_file_name '.mat']);
            scout       = load(filename);
            
            values      = scout.Value;
            
            ...if (nsubj == 1 && ncond == 1)
                [scouts_names, time_names] = init_data(scout);
            ...end
            
            if not(isempty(period_labels))
                if length(period_labels) ~= length(time_names)
                    disp(['Error in brainstorm_subject_scouts_export: a period label cell array was passed (length: ' num2str(length(period_labels)) '), but results file does not contain the same numebr (length:' num2str(length(time_names)) ')'])
                    fileID = -1;
                    return;
                end
                time_names = period_labels;
            else
                time_names = num2cell(time_names);
                
            end
            for sc=1:length(scouts_names)
                scn = scouts_names{sc};
                for tw=1:length(time_names)
                    twn = time_names{tw};
                    data_row = {subj_name, cond_name, scn, twn, values(sc, tw)*values_multiplier};
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
