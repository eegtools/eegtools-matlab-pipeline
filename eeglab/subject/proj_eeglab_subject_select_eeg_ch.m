function EEG = proj_eeglab_subject_select_eeg_ch(project, varargin)

% if sum(ismember({project.study.factors.factor},'condition'))
%     disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
%     return
% end

if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_input_folder') )
    project.epoching.custom_input_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_input_folder     = project.epoching.custom_input_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'add_factor';
% custom_suffix           = '';
% custom_input_folder     = '';

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
    subj_name       = list_select_subjects{subj};
    
%     eeg_input_path  = project.paths.output_epochs;
%     add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
%     if not(isempty(add_factor_list))
        for nc=1:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
            
            if exist(input_file_name, 'file')
                
                EEG             = pop_loadset(input_file_name);
                EEG2 = pop_select(EEG,'channel', 1:project.eegdata.nch_eeg);

                EEG = pop_saveset( EEG, 'filename',[input_name_noext,'_bckch',input_ext],'filepath',input_path);
                
                EEG2 = pop_saveset( EEG2, 'filename',EEG2.filename,'filepath',input_path);
                

            else
                disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                %                 return;
            end
        end
%     end
end
end



















