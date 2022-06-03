function out_file = proj_eeglab_save_montage4brainstorm(project, varargin)

[path, name, ext] = fileparts(project.brainstorm.channels_file_path);

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
custom_input_folder     = project.epoching.custom_output_folder;


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
    
%     eeg_input_path  = project.paths.output_epochs;
%     add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
%     if not(isempty(add_factor_list))
        for nc=1:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            input_file_name                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            [input_path,input_name_noext,input_ext] = fileparts(input_file_name);
            
            if exist(input_file_name, 'file')
                
                try
                    EEG                     = pop_loadset(input_file_name);
                catch
                    [fpath,fname,fext] = fileparts(input_file_name);
                    EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
                end

                name2 = 'brainstorm_channel_EEGLAB_64_10-10';
                out_file = fullfile(path, [name2,ext]);
                locs_eeglab = EEG.chanlocs;
                save(out_file,'locs_eeglab')
                disp(['montage exported to ', out_file])
                return

            else
                disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                %                 return;
            end
        end
%     end
end
end


% % function out_file = proj_eeglab_save_montage4brainstorm(project, varargin)
% % 
% % [path, name, ext] = fileparts(project.brainstorm.channels_file_path);
% % 
% % get_filename_step       = 'input_epoching';
% % 
% % for par=1:2:length(varargin)
% %     switch varargin{par}
% %         case {  ...
% %                 'list_select_subjects'  , ...
% %                 'get_filename_step'     , ...
% %                 'custom_input_folder'   , ...
% %                 'custom_suffix'         , ...
% %                 'mrk_code'              , ...
% %                 'mrk_name'              , ...
% %                 'epo_st'                , ...
% %                 'epo_end'               , ...
% %                 'bc_st'                 , ...
% %                 'bc_end'                , ...
% %                 'bc_type'               , ...
% %                 }
% %             
% % %             if isempty(varargin{par+1})
% % %                 continue;
% % %             else
% %                 assign(varargin{par}, varargin{par+1});
% % %             end
% %     end
% % end
% % 
% % if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
% % numsubj = length(list_select_subjects);
% % 
% % 
% % 
% % subj_name                   = list_select_subjects{1};
% % 
% % input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix);
% % EEG                         = pop_loadset(input_file_name);
% % 
% % 
% % name2 = 'brainstorm_channel_EEGLAB_64_10-10';
% % 
% % out_file = fullfile(path, [name2,ext]);
% % 
% % locs_eeglab = EEG.chanlocs;
% % 
% % save(out_file,'locs_eeglab')
% % 
% % end