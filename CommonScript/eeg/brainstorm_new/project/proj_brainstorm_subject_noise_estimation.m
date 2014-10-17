%% proj_brainstorm_subject_noise_estimation(project, subj_name)
% calculate noise covariance on single trials

%%
function proj_brainstorm_subject_noise_estimation(project, subj_name)


    if nargin < 1
        help proj_brainstorm_subject_noise_estimation;
        return;
    end;

    iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    % define conditions inputs
    ...FileNamesA = cell(1, project.epoching.numcond);
    cnt_trials = 0;
    for cond=1:project.epoching.numcond
    
        [sStudies, iStudies] = bst_get('StudyWithCondition', [subj_name '/' project.epoching.condition_names{cond}]);
        num_trials = length(sStudies.Data);
        
        for tr=1:num_trials
            trial_filename = sStudies.Data(tr).FileName;
           if isempty(strfind(trial_filename, 'data_average'))
               cnt_trials = cnt_trials + 1;
               FileNamesA{cnt_trials} = trial_filename;
           end
        end
    
        ...FileNamesA{cond} = fullfile(subj_name, project.epoching.condition_names{cond}, 'data_average.mat');
    end
    
    % Start a new report
    bst_report('Start', FileNamesA);    
   
    % Compute noise covariance
    sFiles = bst_process(...
        'CallProcess', 'process_noisecov', ...
        FileNamesA, [], ...
        'baseline', [project.epoching.bc_st.s, project.epoching.bc_end.s], ...
        'dcoffset', 1, ...
        'method', 2, ...  % Diagonal matrix (better if: nTime < nChannel*(nChannel+1)/2)
        'copycond', 1, ...
        'copysubj', 0);
    
 
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

