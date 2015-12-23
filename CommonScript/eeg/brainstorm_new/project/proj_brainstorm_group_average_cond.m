
function sFiles = proj_brainstorm_group_average_cond(project, varargin) ... subjects_list, cond_list, input_file_name

    protocol_name = project.brainstorm.db_name;
    
    % default
    subjects_list   = project.subjects.list;
    cond_list       = project.epoching.condition_names;
    input_file_name = project.brainstorm.average_file_name;
    
    for v=1:2:length(varargin)
       if ~isempty(varargin{v+1})
           switch varargin{v}
               case 'input_file_name'
                   input_file_name = varargin{v+1};
               case 'cond_list'
                   cond_list = varargin{v+1};
               case 'subjects_list'
                   subjects_list = varargin{v+1};
           end
       end
    end

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    len_cond                = length(cond_list);
    
    FileNamesA              = cell(1,len_subj);
    
    for ncond=1:len_cond
        for nsubj=1:len_subj
            FileNamesA{nsubj}=fullfile(subjects_list{nsubj}, cond_list{ncond}, [input_file_name '.mat']);
        end
        
        % Start a new report
        bst_report('Start', FileNamesA);

        % Process: grand average (by condition) of input results
        sFiles = bst_process(...
            'CallProcess', 'process_average', ...
            FileNamesA, [], ...
            'avgtype', 4, ...  group by condition (grand average)
            'avg_func', 1, ... 
            'keepevents', 1); 

        % Save report
        ReportFile      = bst_report('Save', sFiles);
        if isempty(sFiles)
            bst_report('Open', ReportFile);        
            rep = load(ReportFile);
            rep.Reports{3,4}
           keyboard 
        end 

        src_filename=fullfile(brainstorm_data_path, sFiles(1).FileName);
        dest_filename=fullfile(brainstorm_data_path, 'Group_analysis', cond_list{ncond}, [input_file_name '_' cond_list{ncond} '.mat']);
        movefile(src_filename, dest_filename, 'f');    
   
    end
     
    db_reload_studies(sFiles(1).iStudy);end
