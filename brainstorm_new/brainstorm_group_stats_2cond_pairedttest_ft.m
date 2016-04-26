%% function sFiles = brainstorm_group_stats_2cond_pairedttest(protocol_name, cond1, cond2,  analysis_type, subjects_list)
%   analysis_type:   e.g. 'sloreta_fixed_surf'
%
function sFiles = brainstorm_group_stats_2cond_pairedttest(protocol_name, cond1, cond2,  data_type, analysis_type, subjects_list, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    abs_type                = 1;
    avgtime                 = 0;
    tail                    = 'two';  % two, one- , one+
    comment                 = '';
    scoutfunc               = 1;
    scoutsel                = {};   % {'Uniform400', {'026', '062', '073', '076', '086'}}
    timewindow              = [];
    corr                    = 1;  % 1: no, 2: cluster, 3: bonferroni, 4: fdr, 5: max, 6: holm, 7: hockberg
    nperm                   = 1000;
    pvalue                  = 0.05;
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'timewindow'
                timewindow = varargin{opt+1};   
            case 'scoutsel'
                scoutsel = varargin{opt+1}; 
            case 'scoutfunc'
                scoutfunc = varargin{opt+1};  
            case 'abs_type'
                abs_type = varargin{opt+1};
            case 'avgtime'
                avgtime = varargin{opt+1};   
            case 'nperm'
                nperm = varargin{opt+1};
            case 'tail'
                tail = varargin{opt+1};   
            case 'corr'
                corr = varargin{opt+1};  
            case 'comment'
                comment = varargin{opt+1};   
            case 'pvalue'
                pvalue = varargin{opt+1};
        end
    end    
    
    switch tail
        case 'two'
            tail=2;
        case 'one-'
            tail=1;
        case 'one+'
            tail=3; 
    end
    % 1: no, 2: cluster, 3: bonferroni, 4: fdr, 5: max, 6: holm, 7: hockberg    
    switch corr
        case 'no'
            corr=1;
        case 'cluster'
            corr=2;
        case 'bonferroni'
            corr=3; 
        case 'fdr'
            corr=4;
        case 'max'
            corr=5;
        case 'holm'
            corr=6;             
        case 'hockberg'
            corr=7;             
    end    
    
    
    len_subj                = length(subjects_list);
    FileNamesA              = cell(1, len_subj);
    FileNamesB              = cell(1, len_subj);
    
    for nsubj=1:len_subj
        bst_path1    = fullfile(subjects_list{nsubj}, cond1, [data_type cond1 '_' analysis_type '.mat']);
        full_path1   = file_fullpath(bst_path1);
        
        bst_path2    = fullfile(subjects_list{nsubj}, cond2, [data_type cond2 '_' analysis_type '.mat']);
        full_path2   = file_fullpath(bst_path2);
        
        if exist(full_path1,'file')
            FileNamesA{nsubj} = bst_path1;
        else
            disp(['Error in brainstorm_group_stats_2cond_pairedttest: file ' ]);
            sFiles = [];
            return;            
        end
        
        if exist(full_path2,'file')
            FileNamesB{nsubj} = bst_path2;
        else
            disp(['Error in brainstorm_group_stats_2cond_pairedttest: file ' ]);
            sFiles = [];
            return;            
        end
    end
 
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: paired t-test
    

% Process: Permutation t-test: FDR correction
    sFiles = bst_process('CallProcess', 'process_ft_sourcestatistics', ...
        FileNamesA, FileNamesB, ...
        'timewindow'    , timewindow, ...   % []
        'scoutsel'      , scoutsel, ...     % {}
        'scoutfunc'     , scoutfunc, ...    % Mean
        'abs'           , abs_type, ...     % 1
        'avgtime'       , avgtime, ...      % 0
        'randomizations', nperm, ...        % 1000
        'statistictype' , 2, ...            % Paired t-test
        'tail'          , tail, ...         % Two-tailed
        'correctiontype', corr, ...         % no
        'minnbchan'     , 0, ...
        'Comment'       , comment, ...        
        'clusteralpha'  , pvalue);          % 0.05
    

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
    
    % remove 'results' string from analysis_type
    analysis_type   = strrep(analysis_type, data_type, '');
    
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
    dest_filename   = fullfile(brainstorm_data_path, '@inter', ['presults_' cond1 '_' cond2 '_' analysis_type '.mat']);
    movefile(src_filename, dest_filename, 'f');
    
    db_reload_studies(sFiles(1).iStudy);
end
