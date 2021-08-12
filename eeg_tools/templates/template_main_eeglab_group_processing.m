clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    %     project.paths.projects_data_root    = '/data/projects';
    %     project.paths.projects_scripts_root = '/data/behavior_lab_svn/behaviourPlatform';
    %     project.paths.plugins_root          = '/data/matlab_toolbox';
    %     project.paths.framework_root        = '/data/CODE/MATLAB/eegtools/matlab-pipeline';
    project.paths.projects_data_root    = '/home/campus/projects/';
    project.paths.projects_scripts_root = '/home/campus/behaviourPlatform';
    project.paths.plugins_root          = '/home/campus/work/work-matlab/matlab_toolbox';
    project.paths.framework_root        = '/home/campus/behaviourPlatform/CommonScript/eeg';
    project.paths.script.project       = '/home/campus/behaviourPlatform/VisuoHaptic/claudio/bisezione_lb/';%'/media/workingdir/VisuoHaptic/mariabianca_amadeo/bisezione_sordi/processing/matlab/';
    
    
    % eventuale settaggio diretto della directory con gli script e di quella con i dati (se commentate o vuote vengono costruti automaticamente i percorsi usando le info su gruppo, sotto-gruppo ecc)
    %      project.paths.script.project       = '/home/campus/behaviourPlatform/CMON/EEG_Pantomima/Matlab/eegproc/';
    %      project.paths.project              = '';
    
else
    project.paths.projects_data_root    = 'd:\\data\projects';
    project.paths.projects_scripts_root = 'd:\\data\behavior_lab_svn\behaviourPlatform';
    project.paths.plugins_root          = 'd:\\data\matlab_toolbox';
    project.paths.framework_root        = 'd:\\data\matlab_toolbox\eegtools-matlab-pipeline';
end
%% ==================================================================================
%  PROJECT DATA
%==================================================================================
project.research_group      = 'MNI';
project.research_subgroup   = '';
project.name                = 'perception_action_musicians';    ... must correspond to 'project.paths.local_projects_data' subfolder name
    project.conf_file_name      = 'template_project_structure';              ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
    %% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.script.eeg_tools_project = fullfile(project.paths.framework_root, 'eeg_tools', 'project', ''); addpath(project.paths.script.eeg_tools_project);
project                                = project_init(project);             ... project structure
    %% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================
% to be edited according to experiment.....
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


% operations = {
%     'do_study',...                                                         1
%     'do_study_catsub',...                                                  2 before creating the study cat for each subject all epochs of all conditions (less files, lighter study, faster computations)
%     'do_design',...                                                        3
%     'do_study_compute_channels_measures',...                               4
%     'study_plot_roi_erp_curve_continous',...                               5
%     'study_plot_roi_erp_curve_tw_group_noalign',...                        6
%     'study_plot_roi_erp_curve_tw_individual_noalign',...                   7
%     'study_plot_roi_erp_curve_tw_individual_align',...                     8
%     'study_plot_roieog_erp_curve_continous',...                            9
%     'study_plot_roi_erpeog_curve_tw_group_noalign',...                     10
%     'study_plot_roi_erpeog_curve_tw_individual_noalign',...                11
%     'study_plot_roi_erpeog_curve_tw_individual_align',...                  12
%     'study_plot_roi_erpemg_curve_continous',...                            13
%     'study_plot_roi_erpemg_curve_tw_group_noalign',...                     14
%     'study_plot_roi_erpemg_curve_tw_individual_noalign',...                15
%     'study_plot_roi_erpemg_curve_tw_individual_align',...                  16
%     'study_erp_define_roi_tw_datadriven',...                               17
%     'study_ersp_define_roi_tw_datadriven',...                              18
%     'study_plot_erp_topo_tw_group_noalign',...                             19
%     'study_plot_erp_topo_tw_individual_noalign',...                        20
%     'study_plot_erp_topo_tw_individual_align',...                          21
%     'study_plot_erp_topo_tw_individual_align',...                          22
%     'study_plot_erp_topo_compact_tw_group_noalign',...                     23
%     'study_plot_erp_topo_compact_tw_individual_noalign',...                24
%     'study_plot_erp_topo_compact_tw_individual_align',...                  25
%     'plot_erp_headplot_tw',...                                             26
%     'study_plot_allch_erp_time',...                                        27
%     'study_plot_roi_ersp_tf_continuous',...                                28
%     'study_plot_roi_ersp_tf_decimate_times',...                            29
%     'study_plot_roi_ersp_tf_decimate_freqs',...                            30
%     'study_plot_roi_ersp_tf_decimate_times_freqs',...                      31
%     'study_plot_roi_ersp_tf_tw_fb',...                                     32
%     'study_plot_roi_ersp_curve_continous',...                              33
%     'study_plot_roi_ersp_curve_tw_individual_noalign',...                  34
%     'study_plot_roi_ersp_curve_continous_standard',...                     35
%     'study_plot_roi_ersp_curve_tw_group_noalign_standard',...              36
%     'study_plot_roi_ersp_curve_tw_individual_noalign_standard',...         27
%     'study_plot_roi_ersp_curve_tw_individual_align_standard',...           38
%     'study_plot_roi_ersp_curve_continous_compact',...                      39
%     'study_plot_roi_ersp_curve_tw_group_align_compact',...                 40 STILL MISSING
%     'study_plot_roi_ersp_curve_tw_individual_noalign_compact',...          41
%     'study_plot_roi_ersp_curve_tw_individual_align_compact',...            42
%     'study_plot_ersp_topo_tw_fb_group_noalign',...                         43
%     'study_plot_ersp_topo_tw_fb_individual_noalign',...                    44
%     'study_plot_ersp_topo_tw_fb_individual_align',...                      45
%     'study_plot_ersp_topo_tw_fb_group_noalign_compact',...                 46
%     'study_plot_ersp_topo_tw_fb_individual_noalign_compact',...            47
%     'study_plot_ersp_topo_tw_fb_individual_align_compact',...              48
%     'study_plot_allch_ersp_curve_fb_time',...                              49
%     };

operations_file_path = fullfile(project.paths.script.eeg_tools,'operations.xlsx');
[ndata, text, menu_operations] =  xlsread(operations_file_path,'group');
indices = alldata(:,1);
operations = alldata(:,2);
descriptions = alldata(:,3);

get_menu = 1;
if get_menu
    disp(operations_file_path);
    disp(menu_operations);
else    
    for nop = 1:2%1:length(operations)
        
        operation = operations{nop};
        
        disp(['Begin ' operation]);
        
        
        project                                                 = project_init(project);
        
        result = startProcess(project, ...
            operation,  ...
            'list_select_subjects', list_select_subjects);
        
        disp(['End ' operation]);
        
        
    end
end

% project.stats.eeglab.erp.correction                     = 'fdr';
% project.stats.erp.pvalue                                = 0.05;
% project.results_display.erp.compact_display_xlim        = [0 300];
%
% stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_temppar';
% project                                                 = initProject(project);
% design_num_vec                                          = [1];
% project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....
%
% project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
% project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
% result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);
%
%
% % --------------------------------------------------------------------------------------------------------------------------
% stat_analysis_suffix                                    = 'ERP_tw_noalign_temppar';
% project                                                 = initProject(project);
% design_num_vec                                          = [2,3,4];
% project.postprocess.erp.roi_list                        = {{'CP6'};{'TP8'}};
% project.postprocess.erp.roi_names                       = {'CP6', 'TP8'};
% project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N170','min',145, 'max',180, 'ref_roi', 'TP8');
% project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
% result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);
%
%
%
%
% % --------------------------------------------------------------------------------------------------------------------------
% stat_analysis_suffix                                    = 'ERP_curve_plots_allconditions_mesial';
% project                                                 = initProject(project);
% design_num_vec                                          = [1];
% project.stats.erp.num_permutations                      = 2;                                % this will have to be better managed i nthe future....
%
% project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
% project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
% result = startProcess(project, 'study_plot_roi_erp_curve_continous', stat_analysis_suffix, design_num_vec, list_select_subjects);
%
%
% % --------------------------------------------------------------------------------------------------------------------------
% stat_analysis_suffix                                    = 'ERP_tw_align_mesial';
% project                                                 = initProject(project);
% design_num_vec                                          = [2,3,4];
% project.postprocess.erp.roi_list                        = {{'FCz'};{'AFz'}};
% project.postprocess.erp.roi_names                       = {'FCz', 'AFz'};
% project.postprocess.erp.design(1).group_time_windows(1) = struct('name','N200','min',175, 'max',225, 'ref_roi', 'FCz');
% project.postprocess.erp.design(1).which_extrema_curve   = {{'min'};{'min'}};    ... roi x time_windows
% result = startProcess(project, 'study_plot_roi_erp_curve_tw_individual_align', stat_analysis_suffix, design_num_vec, list_select_subjects);




% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% ----------- E N D --------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------