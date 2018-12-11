%% proj_brainstorm_subject_noise_estimation(project, subj_name)
% calculate noise covariance on single trials

%%
function proj_brainstorm_subject_noise_estimation(project, subj_name, varargin)


if nargin < 1
    help proj_brainstorm_subject_noise_estimation;
    return;
end;

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;


start_interval_s        = project.epoching.bc_st.s;
end_interval_s          = project.epoching.bc_end.s;

options_num=size(varargin,2);
for opt=1:2:options_num
    switch varargin{opt}
        case 'tw'
            tw_interval         = varargin{opt+1};
            start_interval_s    = tw_interval(1);
            end_interval_s      = tw_interval(2);
    end
end

% define conditions inputs
...FileNamesA = cell(1, project.epoching.numcond);
    cnt_trials = 0;
for cond=1:project.epoching.numcond
    
    [sStudies, iStudies] = bst_get('StudyWithCondition', [subj_name '/' project.epoching.condition_names{cond}]);
    if not(isempty(sStudies)) && not(isempty(iStudies))
        num_trials = length(sStudies.Data);
        
        for tr=1:num_trials
            trial_filename = sStudies.Data(tr).FileName;
            if isempty(strfind(trial_filename, 'data_average'))
                cnt_trials = cnt_trials + 1;
                FileNamesA{cnt_trials} = trial_filename;
            end
        end
    end
    ...FileNamesA{cond} = fullfile(subj_name, project.epoching.condition_names{cond}, 'data_average.mat');
end
if exist('FileNamesA')
    % Start a new report
    bst_report('Start', FileNamesA);
    
    % Compute noise covariance
    sFiles = bst_process(...
        'CallProcess', 'process_noisecov', ...
        FileNamesA, [], ...
        'baseline', [start_interval_s, end_interval_s], ...
        'target', 1, ...  % Noise covariance
        'dcoffset', 1, ...
        'method', 2, ...  % Diagonal matrix (better if: nTime < nChannel*(nChannel+1)/2)
        'copycond', 1, ...
        'copysubj', 0);
    
    
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
end
end

