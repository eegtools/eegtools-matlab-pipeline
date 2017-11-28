clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    
    project.paths.projects_data_root    = '/data/projects';
    project.paths.projects_scripts_root = '/data/behavior_lab_svn/behaviourPlatform';
    project.paths.plugins_root          = '/data/matlab_toolbox';
    project.paths.global_scripts_root   = '/data/matlab_toolbox/eegtools-matlab-pipeline';
else
    project.paths.projects_data_root    = 'd:\\data\projects';
    project.paths.projects_scripts_root = 'd:\\data\behavior_lab_svn\behaviourPlatform';
    project.paths.plugins_root          = 'd:\\data\matlab_toolbox';
    project.paths.global_scripts_root   = 'd:\\data\matlab_toolbox\eegtools-matlab-pipeline';
end

%% ==================================================================================
%  PROJECT DATA 
%==================================================================================
project.research_group      = 'MNI';
project.research_subgroup   = '';
project.name                = 'perception_action_musicians';    ... must correspond to 'project.paths.local_projects_data' subfolder name
project.conf_file_name      = 'project_structure';              ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================


%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.script.eeg_tools_project = fullfile(project.paths.global_scripts_root, 'eeg_tools', 'project', ''); addpath(project.paths.script.eeg_tools_project); 
project                                = project_init(project);             ... project structure
%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================

stat_analysis_suffix='ERP_N2_tw_align';


if ~ isempty(stat_analysis_suffix)
    stat_analysis_suffix=[stat_analysis_suffix,'-',datestr(now,30)];
end

design_num_vec          = [4]; ...[2,3];
sel_cell_string         = [];

% select number of subjects to be processed: can be  
% 1) commented 
% 2) set to [] 
% 3) set to a cell array of strings 
% 4) set to project.subjects.list
list_select_subjects    = project.subjects.list;% {'CC_01_vittoria', 'CC_02_fabio', 'CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara', 'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'}; ...project.subjects.list;

% if a list is not set, or is empty, all subjects in the project are
% processed 
if not(exist('list_select_subjects','var'))
    list_select_subjects    = project.subjects.list;
else
    if isempty(list_select_subjects) 
        list_select_subjects    = project.subjects.list;
    end
end
numsubj                         = length(list_select_subjects);
project.subjects.curr_list      = list_select_subjects;
%% =====================================================================================================================================================================
%  OPERATIONS LIST 
%=====================================================================================================================================================================

project.stats.eeglab.erp.correction                     = 'fdr';
project.stats.erp.pvalue                                = 0.05;
project.results_display.erp.compact_display_xlim        = [0 300];


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_temppar';
project                                                 = initProject(project); 
design_num_vec                                          = [1];
project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....

project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_tw_noalign_temppar';
project                                                 = initProject(project); 
design_num_vec                                          = [2,3,4];
project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N170','min',145, 'max',180, 'ref_roi', 'TP8');
project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);




% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_mesial';
project                                                 = initProject(project); 
design_num_vec                                          = [1];
project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....

project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);


% --------------------------------------------------------------------------------------------------------------------------
stat_analysis_suffix                                    = 'ERP_tw_align_mesial';
project                                                 = initProject(project); 
design_num_vec                                          = [2,3,4];
project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N200','min',175, 'max',225, 'ref_roi', 'FCz');
project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);




% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% ----------- E N D --------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------