% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function ResultFile = brainstorm_subject_sources(protocol_name, subj_name, cond_name, input_file, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    % define optional parameters, accepted varargin parameters are: 
    % 'nodepth' ...currently disabled
    norm            = 1; % wMNE
    depth_value     = 1; % do depthweighting
    orient          = 'fixed';
    loose           = [];
    tag             = '';
    headmodelfile   = '';
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'norm'
                norm_str = varargin{opt+1};                
                switch norm_str
                    case 'wmne'
                        norm = 1;
                    case 'dspm'
                        norm = 2;
                    case 'sloreta'
                        norm = 3;
                        depth_value = 0;
                        
                end               
                
            %case 'nodepth'
            %    depth_value=0;
            
            case 'orient'
                if loose
                    disp('************ERROR in brainstorm_subject_sources************');
                    disp(' you cannot set an orient parameters if you previously set the loose one');
                    return;
                else
                    orient = varargin{opt+1};
                end
                
            case 'loose'
                orient = 'loose';
                loose = varargin{opt+1};
                
            case 'tag'
                tag = varargin{opt+1};
                
            case 'headmodelfile'
                headmodelfile = varargin{opt+1};
                brainstorm_subject_set_headmodel_by_file(protocol_name, subj_name, headmodelfile);
        end
    end
    
    % define conditions inputs
    FileNamesA={};
    FileNamesA{1}=fullfile(subj_name, cond_name, input_file); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
    
    % Start a new report
    bst_report('Start', FileNamesA);    
   
    
    sFiles = bst_process(...
        'CallProcess', 'process_inverse_2015', ...
        FileNamesA, [], ...
        'output', 1, ...  % Kernel only: shared
        'inverse', struct(...
             'Comment', 'dSPM: EEG', ...
             'InverseMethod', norm, ...
             'InverseMeasure', 'dspm', ...
             'SourceOrient', {{'free'}}, ...
             'Loose', 0.2, ...
             'UseDepth', 1, ...
             'WeightExp', 0.5, ...
             'WeightLimit', 10, ...
             'NoiseMethod', 'reg', ...
             'NoiseReg', 0.1, ...
             'SnrMethod', 'fixed', ...
             'SnrRms', 0.001, ...
             'SnrFixed', 9, ...
             'ComputeKernel', 1, ...
             'DataTypes', {{'EEG'}}));

    
    
    % do source analysis over all the conditions
    sFiles = bst_process(...
         'CallProcess', 'process_inverse', ...
         FileNamesA, [], ...
         'method', norm, ...  % 
         'wmne', struct(...
         'NoiseCov', [], ...
         'InverseMethod', norm_str, ...
         'SNR', 3, ...
         'diagnoise', 0, ...
         'SourceOrient', {{orient}}, ...
         'loose', loose, ...
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

    % Save report
    ReportFile      = bst_report('Save', sFiles);
    if isempty(sFiles)
        bst_report('Open', ReportFile);        
        rep = load(ReportFile);
        rep.Reports{3,4}
       keyboard 
    end     
     
     
    ResultFile = sFiles(1).FileName;
    sFiles={ResultFile};

    
    
    % rename output files according to analysis specs
    % standard tag is : cond_name_[wmne/dspm/sloreta]_[free/fixed/loose]_[loosevalue]
    % additionally, the input value of TAG is appended
    std_tag=[cond_name ' | ' norm_str ' | ' orient];
    if (strcmp(orient, 'loose'))
        std_tag=[std_tag ' | ' num2str(loose)];
    end   

    if ~isempty(tag)
        std_tag=[std_tag ' | ' tag];
    end
    output_file_name = ['results_' strrep(std_tag, ' | ', '_')]; 
    
    
    % APPLY TAG NAME 
    sFiles = bst_process(...
    'CallProcess', 'process_add_tag', ...
    sFiles, [], ...
    'tag', std_tag, ...
    'output', 1);  % Add to comment

    [dir,name,ext]          = fileparts(ResultFile);
    ResultFile              = fullfile(dir, [output_file_name ext]);
    
    src                     = fullfile(brainstorm_data_path, dir, [name ext]);
    dest                    = fullfile(brainstorm_data_path, dir, [output_file_name ext]);
    movefile(src,dest);

    
    [sStudy, iStudy, iData] = bst_get('DataFile', sFiles(1).DataFile);
    db_reload_studies(iStudy);

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

