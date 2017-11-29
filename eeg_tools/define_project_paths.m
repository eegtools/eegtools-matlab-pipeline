% AIM : prepare variables for project_define_paths, using the DO OPERATIONS approach
% each main defines the following paths (*also added to path):
%   - project.paths.projects_data_root          = '/data/projects';
%   - project.paths.svn_scripts_root            = '/data/behavior_lab_svn/behaviourPlatform';
%   - project.paths.plugins_root                = '/data/matlab_toolbox';

%   - project.paths.script.eeg_tools            = fullfile(project.paths.svn_scripts_root, 'CommonScript', 'eeg','eeg_tools', '');   

% Requirements:
%   - project.paths.script.eeg_tools  to be defined in the main
%   - eval(project.conf_file_name)    to be called in the main

% it defines:
%   - project.paths.script.eeg_tools_project
%   - project.paths.framework_root
%   - project.paths.projects_scripts_root
%
% init operations flags for sensors (eeglab) & sources (brainstorm) analyses
% calls project_define_paths

function project = define_project_paths(project, varargin)

    project.paths.framework_root            = fullfile(project.paths.svn_scripts_root, 'CommonScript', 'eeg', '');
    project.paths.script.eeg_tools_project  = fullfile(project.paths.script.eeg_tools, 'project', '');  addpath(project.paths.script.eeg_tools_project); 
    project.paths.projects_scripts_root     = project.paths.svn_scripts_root; 

    project                                 = project_clear(project);                   % force clearing complex structures  
    project                                 = project_init_operations_flags(project);   % init operations flags

    % retro-compatibility issue, old project_structure have : project.do_source_analysis, new one : project.operations.do_source_analysis
    if isfield(project, 'operations')
        if isfield(project.operations, 'do_source_analysis')
            if project.operations.do_source_analysis
                project                     = project_init_operations_flags_brainstorm(project);    % init brainstorm operations flags
            end
        else
            if project.do_source_analysis
                project                     = project_init_operations_flags_brainstorm(project);    % init brainstorm operations flags
            end        
        end
    else
        if project.do_source_analysis
            project                         = project_init_operations_flags_brainstorm(project);    % init brainstorm operations flags
        end        
    end
    project                                 = project_define_paths(project, varargin{:});     
end
