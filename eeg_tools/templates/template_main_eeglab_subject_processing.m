clear project
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    
    project.paths.projects_data_root    = '/data/projects';
    project.paths.svn_scripts_root      = '/data/behavior_lab_svn/behaviourPlatform';
    project.paths.plugins_root          = '/data/matlab_toolbox';
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
project.conf_file_name      = 'project_structure_observation';         ... project_structure file name, located in : project.paths.eegtools_svn_local / project.research_group_svn_folder / project.name

%% =====================================================================================================================================================================
%  DESIGN SPECIFICATION
%==================================================================================
...
...
...
...
%% =====================================================================================================================================================================
%  PROJECT STRUCTURE AND FILE SYSTEM INITIALIZATION
%=====================================================================================================================================================================
project.paths.script.common_scripts     = fullfile(project.paths.svn_scripts_root, 'CommonScript', '');                                                     addpath(project.paths.script.common_scripts);      ... to get genpath2
project.paths.script.eeg_tools          = fullfile(project.paths.script.common_scripts, 'eeg','eeg_tools', '');                                             addpath(project.paths.script.eeg_tools);           ... to get define_project_paths
project.paths.script.project            = fullfile(project.paths.svn_scripts_root, project.research_group, project.research_subgroup , project.name, '');   addpath(genpath2(project.paths.script.project));   ... in general u don't need to import the others' projects svn folders

eval(project.conf_file_name);                                               ... project structure
project                                 = define_project_paths(project);    ... global and project paths definition. If 2nd param is 0, is faster, as it does not call eeglab
init_operations_flags

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

numsubj = length(list_select_subjects);

stat_threshold = 0.05;
electrode2inspect='C4';
save_figure=0;


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
% uniform montages between different polygraphs
project.operations.do_uniform_montage                                               = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% epoching
project.operations.do_epochs                                                        = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% custom epoching
project.operations.do_custom_epochs                                                 = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% add experimental factors information to the data
project.operations.do_factors                                                       = 0;

%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% extract narrowband for each subject and selected condition and save
% separately each condition in a mat file
project.operations.do_extract_narrowband                                            = 0;


%---------------------------------------------------------------------------------------------------------------------------------------------------------------------
% perform basic single-subject plotting and analysis, basically 1 condition spectral graphs, single epochs desynch, or 2 conditions comparisons
project.operations.do_singlesubjects_band_comparison                                = 0;

%=====================================================================================================================================================================
% S T A R T    P R O C E S S I N G  
%=====================================================================================================================================================================

try
    
    do_operations

    %==================================================================================
    if project.operations.do_patch_triggers
        for subj=1:project.subjects.numsubj
            subj_name   = project.subjects.list{subj}; 
            file_name   = proj_eeglab_subject_get_filename(project, subj_name, 'custom_pre_epochs', 'custom_suffix', custom_suffix);            

            %   1) if not present, add start trigger 1 sec before the first trigger

            %   2) add: - a pause trigger value at the same latency of a question_trigger_value 
            %           - a resume trigger 1sec before the event following the question trigger
            ...eeglab_subject_events_add_event_at_code_and_before_next(file_name, 'S201', project.task.events.start_pause_trigger, project.task.events.end_pause_trigger, abs(project.epoching.epo_st.s));

            eeglab_subject_events_add_event_around_other_events(file_name, {}, project.task.events.baseline_start_trigger_value, project.task.events.end_pause_trigger, abs(project.epoching.epo_st.s));

            %   3) add a pause trigger value at the same latency of a question_trigger_value
            %eeglab_subject_events_add_eve1_pre_eve2(file_name, {project.task.events.question_trigger_value},{project.task.events.resume_trigger_value},10000000000,project.task.events.pause_trigger_value)
        end
    end


    %==================================================================================
    if project.operations.do_custom_epochs
        % do preprocessing up to epochs: avgref, epochs, rmbase: create one trails dataset for each condition
         for subj=1:project.subjects.numsubj
            subj_name=project.subjects.list{subj};

            %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            % SPECIAL CASE OF SWAPPING ACCORDING TO HANDEDNESS
            for ns=1:length(project.subjects.data)
                if (strcmp(project.subjects.data(ns).name, subj_name))
                    handedness=project.subjects.data(ns).handedness;
                end
            end
            if strcmp(handedness, 'l')
                input_file_name    = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '.set']);
                swapped_file_name  = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_sw' '.set']);

                if ~exist(swapped_file_name, 'file')
                    eeglab_subject_swap_electrodes(input_file_name, swapped_file_name);
                end
                proj_eeglab_subject_epoching(project, subj_name, 'custom_suffix', '_sw');
            else
                proj_eeglab_subject_epoching(project, subj_name);
            end
            %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         end
    end
    
    %==================================================================================
    if project.operations.do_singlesubjects_band_comparison
        for subj=1:project.subjects.numsubj
            subj_name=project.subjects.list{subj};        
            cond_files=cell(1,project.epoching.numcond);
            for nc=1:project.epoching.numcond
                cond_files{nc} = fullfile(project.paths.output_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' project.epoching.condition_names{nc} '.set']);
            end
             eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{1}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
             eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{2}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
    %         eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{3}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});
    %         eeglab_subject_tf_plot_onecondition_vs_baseline(cond_files{4}, electrode2inspect, 'cycles', cycles, 'pvalue', stat_threshold, 'correct', 'none', 'baseline', [project.epoching.bc_st.ms project.epoching.bc_end.ms], 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path), 'freq_bands', {project.postprocess.ersp.frequency_bands_list{2}});

    %         eeglab_subject_tf_plot_2conditions(cond_files{2}, cond_files{1}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
    %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{2}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
    %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{1}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
    %         eeglab_subject_tf_plot_2conditions(cond_files{3}, cond_files{4}, electrode2inspect, 'pvalue', stat_threshold, 'save_fig', save_figure, 'fig_output_path', fullfile(project.paths.results, fig_output_path));
        end
    end
    %==================================================================================

    
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)    
end
