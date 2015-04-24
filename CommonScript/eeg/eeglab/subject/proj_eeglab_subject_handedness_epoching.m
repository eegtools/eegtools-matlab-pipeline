%% function proj_eeglab_subject_handedness_epoching(project, varargin)
% epochs file and swap them according to subject handedness
%
%
function success = proj_eeglab_subject_handedness_epoching(project, varargin)

    success = 1;
    
    if not(isfield(project.epoching, 'handedness_swap'))
        success = 0;
        error('error in proj_eeglab_subject_handedness_epoching: project.epoching.handedness_swap not defined');
    else
        if strcmp(project.epoching.handedness_swap, 'off')
            warning('you selected handedness_epoching but project.epoching.handedness_swap is off');
            return;
        end
    end

    list_select_subjects    = project.subjects.list;
    custom_suffix           = '';

    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects', ...
                    'custom_suffix' ...
                 }

                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
        end 
    end
    
    if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
    numsubj = length(list_select_subjects);

    for subj=1:numsubj

        subj_name = list_select_subjects{subj};
        
        % get subject handedness
        for ns=1:length(project.subjects.data)
            if (strcmp(project.subjects.data(ns).name, subj_name))
                handedness = project.subjects.data(ns).handedness;
            end
        end
        if strcmp(handedness, project.epoching.handedness_swap)
            
            input_file_name = proj_eeglab_subject_get_filename(project, subj_name, 'input_epoching', 'custom_suffix', custom_suffix);
            copy_file_name  = proj_eeglab_subject_get_filename(project, subj_name, 'input_epoching', 'custom_suffix', [custom_suffix '_orig']);
            
            copyfile(input_file_name, copy_file_name);                          % duplicate source to copy
            eeglab_subject_swap_electrodes(input_file_name, input_file_name);   % swap source
            
            proj_eeglab_subject_epoching(project, 'list_select_subjects', {subj_name});                   % epoch swapped source, so condition files are swapped but their names are preserved
            
            copyfile(copy_file_name,input_file_name);                           % restore source
            delete(copy_file_name);                                             % delete copy file
            
        else
            proj_eeglab_subject_epoching(project, 'list_select_subjects', {subj_name});
        end
    end
end