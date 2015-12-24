%% function sFiles = brainstorm_group_stats_baseline_ttest(protocol_name, cond,  analysis_type, avg_func, subjects_list, varargin)
%   analysis_type:   e.g. 'sloreta_fixed_surf'
%   avg_func:                       % 1: Absolute value of average: abs(mean(x))
                                    % 2: Absolute value of average: abs(mean(x))
                                    % 3: Absolute value of average: abs(mean(x))
%                                    
function sFiles = brainstorm_group_stats_baseline_ttest(protocol_name, cond,  analysis_type, prestim, poststim, avg_func, subjects_list, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    
    comment                 = [];
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'comment'
                comment = varargin{opt+1};                
        end
    end    
    
    len_subj                = length(subjects_list);
    FileNamesA              = cell(1, len_subj);
    
    for nsubj=1:len_subj
        bst_path    = fullfile(subjects_list{nsubj}, cond, ['results_' cond '_' analysis_type '.mat']);
        full_path   = file_fullpath(bst_path);
        
        if exist(full_path,'file')
            FileNamesA{nsubj} = bst_path;
        else
            disp(['Error in brainstorm_group_stats_baseline_ttest: file ' ]);
            sFiles = [];
            return;            
        end
    end
 
    % Start a new report
    bst_report('Start', FileNamesA);

    
    % Process: t-test [abs(avg)]: [0ms,996ms] vs. [-400ms,-4ms]
    sFiles = bst_process( ...
        'CallProcess', 'process_ttest_baseline', ...
        FileNamesA, [], ...
        'prestim', prestim, ...
        'poststim', poststim, ...
        'avg_func', avg_func);      

    brainstorm_utility_check_process_success(sFiles);   

    
    ResultFile = sFiles(1).FileName;
    sFiles={ResultFile};    
    
    % remove 'results' string from analysis_type
    analysis_type   = strrep(analysis_type, 'results_', '');
    
    if not(isempty(comment))
        analysis_type = [analysis_type '_' comment];
    end
    
    % APPLY TAG NAME 
    sFiles = bst_process(...
    'CallProcess', 'process_add_tag', ...
    sFiles, [], ...
    'tag', analysis_type, ...
    'output', 1);  % Add to comment    
    
    src_filename    = fullfile(brainstorm_data_path, sFiles(1).FileName);
    dest_filename   = fullfile(brainstorm_data_path, '@inter', ['presults_' cond '_vs_baseline_' analysis_type '.mat']);
    movefile(src_filename, dest_filename, 'f');
    
    db_reload_studies(sFiles(1).iStudy);
end
