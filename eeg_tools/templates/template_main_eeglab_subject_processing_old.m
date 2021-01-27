clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    project.paths.projects_data_root    = '/data/BIODATA/EEG';
    project.paths.svn_scripts_root      = '/wdata/SVN/behaviour_lab_svn';
    project.paths.plugins_root          = '/data/CODE/MATLAB';
else
    project.paths.projects_data_root    = 'C:\Users\Pippo\Documents\EEG_projects';
    project.paths.svn_scripts_root      = 'C:\Users\Pippo\Documents\MATLAB\svn_beviour_lab\EEG_Tools';
    project.paths.plugins_root          = 'C:\Users\Pippo\Documents\MATLAB\toolboxes';
end
%% ==================================================================================
%  PROJECT DATA 
%==================================================================================
project.research_group      = 'PAP';
project.research_subgroup   = 'laura';
project.name                = 'cp_action_observation';                 ... must correspond to 'project.paths.local_projects_data' subfolder name
project.conf_file_name      = 'template_project_structure';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
% I must just add the path of define_project_paths... then it loads everything
project.paths.script.eeg_tools          = fullfile(project.paths.svn_scripts_root, 'CommonScript', 'eeg','eeg_tools', ''); addpath(genpath(project.paths.script.eeg_tools)); 
eval(project.conf_file_name);                                                   % project structure
project                                 = define_project_paths(project);        % global and project paths definition. If 2nd param is 0 or absent, is faster, as it does not call eeglab
%% =====================================================================================================================================================================
%  OVERRIDE
%=====================================================================================================================================================================
% project.subjects.list       = {'CP_05_gregorio'};..., 'CC_02_fabio', 'CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara', 'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'}; ...
% project.subjects.numsubj    = length(project.subjects.list);  % DO not remove this line if u override the subjects list


custom_suffix = '_raw_er2';   ... 16/12/14 CLA: it's NOT an override but, apparently, a mandatory parameter file name suffix used for non-standard operations (second ica, patch triggers, etc...)
% it's first _raw and then do ica. then open by hand _raw, clean segments, save as _raw_er, then do another ica, and save again as raw_er (overwrite). then reopen the ra_er and remove components and save as raw_mc.  


% select number of subjects to be processed: can be  1) commented 2) set
% to [] 3( set to a cell array of strings 4) set to project.subjects.list
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

stat_threshold                  = 0.05;
electrode2inspect               = 'C4';
save_figure                     = 0;


%=====================================================================================================================================================================
% OPERATIONS LIST 
%=====================================================================================================================================================================

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% import raw data and write set/fdt file into epochs subfolder, perform: import, event to string, channel lookup, global filtering
project.operations.do_import                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% preprocessing of the imported file: SUBSAMPLING, CHANNELS TRANSFORMATION, INTERPOLATION, RE-REFERENCE, SPECIFIC FILTERING
project.operations.do_preproc                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% do emg extraction analysis
project.do_emg_analysis                                                             = 0;             

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% do custom modification to event triggers
project.operations.do_patch_triggers                                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% remove pauses and undesidered time interval marked by specific markers
project.operations.do_auto_pauses_removal                                           = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% allow testing some semi-automatic aritfact removal algorhithms
project.operations.do_testart                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform ICA
project.operations.do_ica                                                           = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% use/test semi automatic toolboxes based on ICA to identify bad components
project.operations.do_clean_ica                                                     = 0; 

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% uniform montages between different polygraphs
project.operations.do_uniform_montage                                               = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% reref
project.operations.do_reref                                                         = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% insert trial triggers into the data
project.operations.do_mark_trial                                                    = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% insert baseline triggers into the data
project.operations.do_mark_baseline                                                 = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% check mc file status: triggers, num epochs, errors
project.operations.do_check_mc                                                      = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% epoching
project.operations.do_epochs                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% custom epoching
project.operations.do_custom_epochs                                                 = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% custom epoching that swap electrodes according to handedness
project.operations.do_handedness_epochs                                             = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% add experimental factors information to the data
project.operations.do_factors                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform basic single-subject plotting and analysis, basically 1 condition spectral graphs, single epochs desynch, or 2 conditions comparisons
project.operations.do_singlesubjects_band_comparison                                = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% extract narrowband for each subject and selected condition and save separately each condition in a mat file
project.operations.do_extract_narrowband                                            = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% placeholder flag to execute any custom script
project.operations.do_custom_analysis                                               = 0;

%=====================================================================================================================================================================
% S T A R T    P R O C E S S I N G  
%=====================================================================================================================================================================

try
    
    do_operations

    %==================================================================================

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
