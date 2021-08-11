%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_export_trial_erp_mean(project, varargin)

if sum(ismember({project.study.factors.factor},'condition'))
    disp('the factor name condition is reserved by eeglab: please change name e.g. to cond')
    return
end

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
    
    eeg_input_path  = project.paths.output_epochs;
    out_dir = fullfile(eeg_input_path, 'out_erp');
    if not(exist(out_dir))
        mkdir(out_dir);
    end
    fname_out = [subj_name,'_trial_erp_mean.zot'];
    fpath_out = fullfile(out_dir,fname_out);
    fid = fopen(fpath_out, 'w+');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n', 'subject', 'condition', 'tw', 'roi','trial','erp_mean');
%     add_factor_list = project.study.factors;
    % ----------------------------------------------------------------------------------------------------------------------------
%     if not(isempty(add_factor_list))
        for nc=1:project.epoching.numcond
            cond_name                               = project.epoching.condition_names{nc};
            input_file                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
            [input_path,input_name_noext,input_ext] = fileparts(input_file);
            
            if exist(input_file, 'file')
                
                [fpath,fname,fext] = fileparts(input_file);
                EEG = pop_loadset('filepath',fpath,'filename',[fname,fext]);
                
                for ntw = 1:length(project.postprocess.erp.design(1).group_time_windows)
                    for nr = 1:length(project.postprocess.erp.roi_list)
                        sel_roi = ismember({EEG.chanlocs.labels},project.postprocess.erp.roi_list{nr});
                        sel_t =...
                            EEG.times >= project.postprocess.erp.design(1).group_time_windows(ntw).min & ...
                            EEG.times <= project.postprocess.erp.design(1).group_time_windows(ntw).max;
                        sel_data = EEG.data(sel_roi,sel_t,:);
                        mean_sel_data  = squeeze(mean(sel_data,[1,2]));
                        
                        for ntrial =  1:length(mean_sel_data)
                            fprintf(fid, '%s\t%s\t%s\t%s\t%d\t%d\n', ...
                                subj_name, cond_name,...
                                project.postprocess.erp.design(1).group_time_windows(ntw).name, ...
                                project.postprocess.erp.roi_names{nr}...
                                ,ntrial,mean_sel_data(ntrial));
                        end
                    end
                end
                
            end
        end
      fclose(fid);
                 
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


