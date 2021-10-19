%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_erp_curve(project, varargin)

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
get_filename_step       = 'subject_erp_curve';
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

troi = length(project.postprocess.erp.roi_list);

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
results_path                = project.paths.results;
subject_erp_curve_path = fullfile(results_path,['subject_erp_curve','_',str]);
if not(exist(subject_erp_curve_path))
    mkdir(subject_erp_curve_path)
end

% -------------------------------------------------------------------------------------------------------------------------------------
if not(isempty(project.subject_compare_cond))
    tcomp = length(project.subject_compare_cond);
    
    for ncomp = 1:tcomp
        current_comparison = project.subject_compare_cond{ncomp};
        tcond = length(current_comparison);        
        
        for nroi = 1:troi
            current_roi = project.postprocess.erp.roi_list{nroi};
            current_roi_name = project.postprocess.erp.roi_names{nroi};
            
            for subj=1:numsubj
                subj_name       = list_select_subjects{subj};
                
                eeg_input_path  = project.paths.output_epochs;
                close all
                %                     fig = figure;
                fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
                for nc=1:tcond
                    cond_name                               = current_comparison{nc};
                    
                    % ----------------------------------------------------------------------------------------------------------------------------
                    
                    input_file                         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', cond_name, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                    [input_path,input_name_noext,input_ext] = fileparts(input_file);
                    
                    if exist(input_file, 'file')
                        [fpath,fname,fext] = fileparts(input_file);
                        EEG = pop_loadset('filepath',fpath,'filename',[fname,fext]);
                        allch = {EEG.chanlocs.labels};
                        erp_curve_allch = squeeze(mean(EEG.data,3));
                        sel_ch = ismember(allch,current_roi);
                        erp_curve_roi = squeeze(mean(erp_curve_allch(sel_ch,:),1));                        
                        plot(EEG.times,erp_curve_roi);
                        hold on                        
                    else
                        disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                    end
                end
                if not(isempty(project.results_display.erp.compact_display_ylim))
                    ylim(project.results_display.erp.compact_display_ylim);
                end
                str_plot = [current_roi_name,'_', subj_name];
                title(str_plot);
                yline(0,'--');
                xline(0,'--');
                xlabel('Times (ms)');
                ylabel('ERP (uV)');
                legend(current_comparison)
                
                inputsf.plot_dir    = subject_erp_curve_path;
                inputsf.fig         = fig;
                inputsf.name_embed  = 'subject_erp_curve';
                inputsf.suffix_plot = str_plot;
                save_figures(inputsf,'res','-r100','exclude_format','svg');
                close all
            end
        end
    end
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


