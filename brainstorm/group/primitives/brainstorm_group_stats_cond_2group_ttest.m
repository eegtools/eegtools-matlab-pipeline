%
% deve pescare gli elementi della lista dai gruppi e fare i test tra essi

function sFiles = brainstorm_group_stats_cond_2group_ttest(protocol_name, ...
    group_name1, ...
    list_select_subjects_group1, ...
    group_name2, ...
    list_select_subjects_group2, ...
    data_type, ...
    analysis_type, ...
    cond, ...
    varargin)

iProtocol               = brainstorm_protocol_open(protocol_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

abs_type                = 1;
avgtime                 = 0;
tail                    = 'two';  % two, one- , one+
comment                 = '';
scoutfunc               = 1;
scoutsel                = {};  % {'Uniform400', {'026', '062', '073', '076', '086'}}
timewindow              = [];

options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'abs_type'
            abs_type = varargin{opt+1};
        case 'tail'
            tail = varargin{opt+1};
        case 'comment'
            comment = varargin{opt+1};
        case 'avgtime'
            avgtime = varargin{opt+1};
        case 'scoutfunc'
            scoutfunc = varargin{opt+1};
        case 'scoutsel'
            scoutsel = varargin{opt+1};
        case 'timewindow'
            timewindow = varargin{opt+1};
    end
end


len_subj1                = length(list_select_subjects_group1);
len_subj2                = length(list_select_subjects_group2);




FileNamesA              = cell(1, len_subj1);
FileNamesB              = cell(1, len_subj2);

for nsubj=1:len_subj1
    bst_path1    = fullfile(list_select_subjects_group1{nsubj}, cond, [data_type cond '_' analysis_type '.mat']);
    full_path1   = file_fullpath(bst_path1);
    if exist(full_path1,'file')
        FileNamesA{nsubj} = bst_path1;
    end
end

for nsubj=1:len_subj2
    bst_path2    = fullfile(list_select_subjects_group2{nsubj}, cond, [data_type cond '_' analysis_type '.mat']);
    full_path2   = file_fullpath(bst_path2);
    if exist(full_path2,'file')
        FileNamesB{nsubj} = bst_path2;
    end
end


% Start a new report
bst_report('Start', FileNamesA);

% Process: unpaired t-test
sFiles = bst_process(...
    'CallProcess', 'process_test_parametric2', ...
    FileNamesA, FileNamesB, ...
    'timewindow', timewindow, ...
    'scoutsel'  , scoutsel, ...
    'scoutfunc' , scoutfunc, ...  % Mean
    'isnorm'    , abs_type, ...
    'avgtime'   , avgtime, ...
    'Comment'   , comment, ...
    'test_type' , 'ttest_equal', ...
    'tail'      , tail);  % One-tailed (+)


%     sFiles = bst_process(...
%         'CallProcess', 'process_test_parametric2p', ...
%         sFiles, sFiles2, ...
%         'timewindow', [-0.30078125, 0.6953125], ...
%         'scoutsel', {'Uniform400', {'022', '025', '058', '061'}}, ...
%         'scoutfunc', 1, ...  % Mean
%         'isnorm', 1, ...
%         'avgtime', 1, ...
%         'Comment', 'gigi', ...
%         'test_type', 'ttest_paired', ...  % Paired Student's t-test t = mean(A-B) ./ std(A-B) .* sqrt(n)      df=n-1
%         'tail', 'two');  % Two-tailed
%

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
    'tag', [analysis_type '_' group_name1 '_' group_name2 '_' cond], ...
    'output', 1);  % Add to comment

src_filename    = fullfile(brainstorm_data_path, sFiles(1).FileName);
dest_filename   = fullfile(brainstorm_data_path, '@inter', ['presults_' group_name1 '_' group_name2 '_' cond '_' analysis_type '.mat']);
movefile(src_filename, dest_filename, 'f');

db_reload_studies(sFiles(1).iStudy);
end
