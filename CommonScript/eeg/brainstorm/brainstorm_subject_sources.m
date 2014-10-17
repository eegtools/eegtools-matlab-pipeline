% orient:       fixed, free, loose
% norm_str:     wmne, dspm, sloreta

function ResultFile = brainstorm_subject_sources(settings_path, protocol_name, subj_name, cond_input_file, varargin)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    % load configuration file
    [path,name_noext,ext] = fileparts(settings_path);
    addpath(path);    eval(name_noext);
    
    % define optional parameters
    % accepted varargin parameters are: 
    % 'nodepth' ...currently disabled
    % 'loose', val    
    depth_value=1;
    ... source_orient='fixed';
    loose_value=std_loose_value;
    tag='';
    head_model_path='';
    
   

    options_num=size(varargin,2);
    for opt=1:options_num
        switch varargin{opt}
            case 'norm'
                opt=opt+1;
                norm_str=varargin{opt};                
                switch norm_str
                    case 'wmne'
                        norm_value=1;
                    case 'dspm'
                        norm_value=2;
                    case 'sloreta'
                        norm_value=3;
                        depth_value=0;
                end                 
            %case 'nodepth'
            %    depth_value=0;
            case 'orient'
                opt=opt+1;
                source_orient=varargin{opt};
            case 'loose_value'
                source_orient='loose';
                opt=opt+1;
                loose_value=varargin{opt};
            case 'tag'
                opt=opt+1;
                tag=varargin{opt};
            case 'headmodelfile'
                opt=opt+1;
                head_model_path=varargin{opt};
                brainstorm_subject_set_headmodel_by_file(protocol_name, subj_name, head_model_path);
        end
    end
    
    % define conditions inputs
    FileNamesA={};
    FileNamesA{1}=fullfile(subj_name, cond_input_file); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
    
    % Start a new report
    bst_report('Start', FileNamesA);    
   
    % do source analysis over all the conditions
    sFiles = bst_process(...
        'CallProcess', 'process_inverse', ...
        FileNamesA, [], ...
        'method', norm_value, ...  % 
        'wmne', struct(...
             'NoiseCov', [], ...
             'InverseMethod', norm_str, ...
             'SNR', 3, ...
             'diagnoise', 0, ...
             'SourceOrient', {{source_orient}}, ...
             'loose', loose_value, ...
             'depth', depth_value, ...
             'weightexp', 0.5, ...
             'weightlimit', 10, ...
             'regnoise', 1, ...
             'magreg', 0.1, ...
             'gradreg', 0.1, ...
             'eegreg', 0.1, ...
             'ecogreg', 0.1, ...
             'seegreg', 0.1, ...
             'fMRI', [], ...
             'fMRIthresh', [], ...
             'fMRIoff', 0.1, ...
             'pca', 1), ...
        'sensortypes', 'EEG', ...
        'output', 3);  % Full results: one per file

    ResultFile = sFiles(1).FileName;
    sFiles={ResultFile};
    
    % rename output files according to analysis specs
    % standard tag is : [wmne/dspm/sloreta]_[free/fixed/loose]_[loosevalue]
    % additionally, the input value of TAG is appended
    std_tag=[norm_str ' | ' source_orient];
    if (strcmp(source_orient, 'loose'))
        std_tag=[std_tag ' | ' num2str(loose_value)];
    end   

    if ~isempty(tag)
        std_tag=[std_tag ' | ' tag];
    end
    
    output_file_name=['results_' strrep(std_tag, ' | ', '_')]; 
    
    
    % APPLY TAG NAME 
    sFiles = bst_process(...
    'CallProcess', 'process_add_tag', ...
    sFiles, [], ...
    'tag', std_tag, ...
    'output', 1);  % Add to comment

    [dir,name,ext] = fileparts(ResultFile);
    src=fullfile(brainstorm_data_path, dir, [name ext]);
    dest=fullfile(brainstorm_data_path, dir, [output_file_name ext]);
    movefile(src,dest);
    ResultFile=fullfile(dir, [output_file_name ext]);

    
    [sStudy, iStudy, iData] = bst_get('DataFile', sFiles(1).DataFile);
    db_reload_studies(iStudy);

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

