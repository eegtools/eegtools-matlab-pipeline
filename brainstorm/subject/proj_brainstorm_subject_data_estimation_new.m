%% proj_brainstorm_subject_noise_estimation(project, subj_name)
% calculate noise covariance on single trials

%%
function proj_brainstorm_subject_data_estimation_new(project,  varargin)


if nargin < 1
    help proj_brainstorm_subject_noise_estimation;
    return;
end;

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;


list_select_subjects    = project.subjects.list;
start_interval_s        = project.epoching.bc_st.s;
end_interval_s          = project.epoching.bc_end.s;


for par=1:2:length(varargin)
    switch varargin{par}
        case { 'list_select_subjects', ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
        case 'tw'
            tw_interval         = varargin{par+1};
            start_interval_s    = tw_interval(1);
            end_interval_s      = tw_interval(2);
    end
end

for subj=1:length(list_select_subjects)
    subj_name = list_select_subjects{subj};
    
    % define conditions inputs
    ...FileNamesA = cell(1, project.epoching.numcond);
        cnt_trials = 0;
    for  cond=1:project.epoching.numcond
        
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
        'target', 2, ...  % Data covariance
        'dcoffset', 1, ...
        'method', 1, ...  % Full matrix (better if: nTime < nChannel*(nChannel+1)/2)
        'copycond', 1, ...
        'copysubj', 0);
    
    
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
end
end

end