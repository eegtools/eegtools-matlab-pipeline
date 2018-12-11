function EEG = proj_eeglab_subject_recover_allch(project, varargin)

% if sum(ismember({project.study.factors.factor},'condition'))
%     disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
%     return
% end

if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_output_folder') )
    project.epoching.custom_output_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_output_folder     = project.epoching.custom_output_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'add_factor';
% custom_suffix           = '';
% custom_output_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_output_folder',  ...
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
    subj_name       = list_select_subjects{subj};
    
    eeg_output_path  = project.paths.output_epochs;
%     add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
%     if not(isempty(add_factor_list))
        for nc=1:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            output_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_output_folder', custom_output_folder);
            [output_path,output_name_noext,output_ext] = fileparts(output_file_name);
            input_file_name = fullfile(output_path,[output_name_noext,'_bckch',ext]);
            
            if exist(input_file_name, 'file')                
                EEG             = pop_loadset(input_file_name);
                EEG = pop_saveset( EEG, 'filename',[output_name_noext,output_ext],'filepath',eeg_output_path);
            else
                disp(['error: condition file name (' input_file_name ') not found!!!! exiting .....']);
                %                 return;
            end
        end
%     end
end
end



















