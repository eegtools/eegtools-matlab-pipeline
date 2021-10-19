%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_erp_topo(project, varargin)

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
get_filename_step       = 'subject_erp_topo';
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

ttw = length(project.postprocess.erp.design(1).group_time_windows);

str                                = datestr(now, 'dd-mmm-yyyy-HH-MM-SS');
results_path                = project.paths.results;
subject_erp_topo_path = fullfile(results_path,['subject_erp_topo','_',str]);
if not(exist(subject_erp_topo_path))
    mkdir(subject_erp_topo_path)
end

% -------------------------------------------------------------------------------------------------------------------------------------
if not(isempty(project.subject_compare_cond))
    tcomp = length(project.subject_compare_cond);
    
    for ncomp = 1:tcomp
        current_comparison = project.subject_compare_cond{ncomp};
        tcond = length(current_comparison);
        
        for ntw = 1:ttw
            current_tw = project.postprocess.erp.design(1).group_time_windows(ntw);
            current_tw_name = current_tw.name;
            
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
                        sel_tw =  EEG.times >= current_tw.min & EEG.times <= current_tw.max ;
                        erp_topo_tw = squeeze(mean(erp_curve_allch(:,sel_tw),2));
                        subplot(1,tcond,nc)
                        topoplot(erp_topo_tw, EEG.chanlocs);
                        title(cond_name)
                        hold on
                        
                        if not(isempty(project.results_display.erp.set_caxis_topo_tw))
                            caxis(project.results_display.erp.set_caxis_topo_tw);
                        end
                        cbar;
                        title('uV');
                        str_plot = [current_tw_name,'_', subj_name];
                    else
                        disp(['error: condition file name (' input_name_noext ') not found!!!! exiting .....']);
                    end
                end
                
                
                suptitle(str_plot);               
                
                inputsf.plot_dir    = subject_erp_topo_path;
                inputsf.fig         = fig;
                inputsf.name_embed  = 'subject_erp_topo';
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


