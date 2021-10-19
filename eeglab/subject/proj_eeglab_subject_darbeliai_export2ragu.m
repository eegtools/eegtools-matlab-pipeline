%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_darbeliai_export2ragu(project, varargin)



if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_input_folder') )
    project.epoching.custom_input_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_input_folder     = project.epoching.custom_input_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'darbeliai_export2ragu';
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
    
    eeg_input_path  = project.paths.output_epochs;
    add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
%     if not(isempty(add_factor_list))
        for nc=1:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            input_file                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            [input_path,input_name_noext,input_ext] = fileparts(input_file);
            
            if exist(input_file, 'file')
                
                [fpath,fname,fext] = fileparts(input_file);
                EEG = pop_loadset('filepath',fpath,'filename',[fname,fext],'loadmode','info');
                [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );              
         
            else
                disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                %                 return;
            end
        end
%     end
end
Neklausti_failu = 1;
dir_data_ragu = fullfile(project.paths.output_epochs,'data_ragu');
if not(exist(dir_data_ragu))
    mkdir(dir_data_ragu);
end
silent = 1;
eksportuoti_ragu_programai_silent(ALLEEG,EEG,CURRENTSET,...
    Neklausti_failu,...
    dir_data_ragu,...
    silent);

disp(['Data exported to Ragu in ', dir_data_ragu])
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name


