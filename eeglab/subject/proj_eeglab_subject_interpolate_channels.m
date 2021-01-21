%% function EEG = proj_eeglab_subject_uniform_montage(project, varargin)
% 
%%
function EEG = proj_eeglab_subject_interpolate_channels(project, varargin)

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'uniform_montage';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects', ...
                    'get_filename_step',    ... 
                    'custom_input_folder',  ...
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
    % -------------------------------------------------------------------------------------------------------------------------------------

    for subj=1:numsubj

        subj_name = list_select_subjects{subj};
        inputfile = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder); 
        
        input.inputfile = inputfile;
        input.acquisition_system = project.import.acquisition_system;
        input.montage_list = project.preproc.montage_list;
        input.montage_names = project.preproc.montage_names;
        input.eeglab_channels_file_path = project.eegdata.eeglab_channels_file_path;
        
        EEG       = eeglab_subject_interpolate_channels(input);
        
%         % create a spline file only once for possible headplots with the right
%         % montage
%         % https://www.mathworks.com/matlabcentral/answers/484535-change-in-matlabpath-form-r2018b-to-r2019b-forbidden-path-name-resources
%         
%         if subj == 1
%             spline_file_path = fullfile(EEG.filepath,'spline_file_montage.spl');
%             headplot('setup', EEG.chanlocs, spline_file_path);
%         end
    
    end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name