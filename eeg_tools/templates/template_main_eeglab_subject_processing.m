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
%  OVERRIDE
%=====================================================================================================================================================================
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


custom_suffix = '_raw_er2';   ... 16/12/14 CLA: it's NOT an override but, apparently, a mandatory parameter file name suffix used for non-standard operations (second ica, patch triggers, etc...)
% it's first _raw and then do ica. then open by hand _raw, clean segments, save as _raw_er, then do another ica, and save again as raw_er (overwrite). then reopen the ra_er and remove components and save as raw_mc.  


stat_threshold                  = 0.05;
electrode2inspect               = 'C4';
save_figure                     = 0;

try
    operations = {
        'do_import'... import and create a backup _raw file
        'do_import_collect',...import and merge different files of a single subject
        'do_remove_upto_start_experiment',...
        'do_remove_pauses',...
        'do_testart',... automatic removal of artifacts using ASR and clean_rawdata
        'do_preproc',...
        'do_recover_raw',... to recover data from raw file
        'do_ica',... ica and save backup file _icabck with ica decomposition 
        'do_remove_ica',... 
        'do_recover_ica',...
        'do_reref',... reref and create backup file _refbck
        'do_recover_ref',...
        'do_mark_trial', ...
        'do_mark_baseline',...
        'do_rectify',...
        'do_epochs',...
        'do_factors',...
        'do_select_eeg_ch',...
        'do_recover_allch',...
        'do_align_montages',...
        'do_export_ch4brainstorm',...
        'do_microstates',...
        'do_subject_spectra',...
        'do_subject_replot_spectra',...

        };
    
    for nop = 1:length(operations)
        
        operation = operations{nop};
        project                                                 = project_init(project);
        
        result = startProcess(project, ...
            operation,  ...
            'list_select_subjects', list_select_subjects);
        
    end


% fill here startPtocess operations .....

% if do_patch_triggers
%     for subj=1:project.subjects.numsubj
%         subj_name=project.subjects.list{subj}; 
%         file_name=fullfile(project.paths.input_epochs, [subj_name pre_epoching_input_file_name '.set']);
% 
%         %   0) rename triggers
%         ...eeglab_subject_events_rename(file_name, {'50','60','70'},{'6','7','8'});
%         
%         %   1) START & END triggers missing
%         ...eeglab_subject_events_add_event_around_first_event(file_name, '1', -2);
%         ...eeglab_subject_events_add_event_around_last_event(file_name, '4', 4);
%         
%         %   2) I WANT TO ANTICIPATE the pause-end trigger
%         ...eeglab_subject_events_move_second_event_in_a_sequence(file_name, {project.task.events.pause_trigger_value}, {project.task.events.resume_trigger_value}, -1.5);        
% 
%         %   3) WHEN EXIST ONLY QUESTION TRIGGER : 
%         %      add: - a pause trigger value at the same latency of a question_trigger_value 
%         %           - a resume trigger 1sec before the event following the question trigger
%         ...eeglab_subject_events_add_event_at_code_and_around_next(file_name, project.task.events.question_trigger_value, project.task.events.pause_trigger_value, project.task.events.resume_trigger_value, (project.epoching.epo_st.s - 0.1) );
% 
%         %   4) WHEN EXIST QUESTION TRIGGER AND RESUME TRIGGER : 
%         %      add a pause trigger value at the same latency of a question_trigger_value
%         ...eeglab_subject_events_add_event_around_another_event(file_name, project.task.events.question_trigger_value, project.task.events.pause_trigger_value, 0.01);
%         %eeglab_subject_events_add_eve1_pre_eve2(file_name,{project.task.events.question_trigger_value},{project.task.events.resume_trigger_value},10000000000,project.task.events.pause_trigger_value); same function as above
%     
%     
%         %   5) mark baseline start and end
%         ...eeglab_subject_events_add_event_around_other_events(file_name, [project.epoching.mrkcode_cond{1:length(project.epoching.mrkcode_cond)}], project.task.events.baseline_start_trigger_value, project.epoching.bc_st.s);
%         ...eeglab_subject_events_add_event_around_other_events(file_name, [project.epoching.mrkcode_cond{1:length(project.epoching.mrkcode_cond)}], project.task.events.baseline_end_trigger_value, project.epoching.bc_end.s);
% 
%         %   6) WHEN DOES NOT EXIST END TRIAL TRIGGERS
%         eeglab_subject_events_add_event_around_other_events(file_name, [project.epoching.mrkcode_cond{1:length(project.epoching.mrkcode_cond)}], project.task.events.videoend_trigger_value, 3.4);
%         
%         
%         %   7)  CALCULATE DISTANCE BETWEEN TRIGGERS ....need to create the following vars: means1 = zeros(project.subjects.numsubj,1);   means2 = zeros(project.subjects.numsubj,1);
%         ...subjects_data{subj} = eeglab_subject_events_distances_three_triggers_classes(file_name, [project.epoching.mrkcode_cond{3:length(project.epoching.mrkcode_cond)}], {'7','8'}, {'5'});
%         ...means1(subj)         = mean([subjects_data{subj}{:,2}]);
%         ...if size(subjects_data{subj}, 2) > 2
%         ...    means2(subj)         = mean([subjects_data{subj}{:,3}]);
%         ...else
%         ...    means2(subj)         = 0;
%         ...end        
%     end
% end


%     %==================================================================================
%     if project.operations.do_custom_epochs
%         % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
%          for subj=1:project.subjects.numsubj
%             subj_name=project.subjects.list{subj};
% 
%             %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%             % SPECIAL CASE OF SWAPPING ACCORDING TO HANDEDNESS
%             for ns=1:length(project.subjects.data)
%                 if (strcmp(project.subjects.data(ns).name, subj_name))
%                     handedness=project.subjects.data(ns).handedness;
%                 end
%             end
%             if strcmp(handedness, 'l')
%                 input_file_name    = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '.set']);
%                 swapped_file_name  = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_sw' '.set']);
% 
%                 if ~exist(swapped_file_name, 'file')
%                     eeglab_subject_swap_electrodes(input_file_name, swapped_file_name);
%                 end
%                 proj_eeglab_subject_epoching(project, subj_name, 'custom_suffix', '_sw');
%             else
%                 proj_eeglab_subject_epoching(project, subj_name);
%             end
%             %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%          end
%     end
    
%     %==================================================================================
%     if project.operations.do_singlesubjects_band_comparison
%         for subj=1:project.subjects.numsubj
%             subj_name=project.subjects.list{subj};        
%             cond_files=cell(1,project.epoching.numcond);
%             for nc=1:project.epoching.numcond
%                 cond_files{nc} = fullfile(project.paths.output_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' project.epoching.condition_names{nc} '.set']);
%             end
%              eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{1}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
%              eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{2}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
%     %         eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{3}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
%     %         eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{4}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
% 
%     %         eeglab_subject_tf_plot_2conditions(cond_files{2}, cond_files{1}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
%     %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{2}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
%     %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{1}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
%     %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{4}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
%     
%             eeglab_subject_components_tf_plot_onecondition_vs_baseline(cond_files{1}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
%             eeglab_subject_components_tf_plot_onecondition_vs_baseline(cond_files{2}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
%     
%         end
%     end
    %==================================================================================

    
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)    
end
