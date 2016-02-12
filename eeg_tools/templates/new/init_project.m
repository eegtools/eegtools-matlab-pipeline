function project = init_project(project, varargin)

    if nargin < 2
        start_toolbox = 1;
    else
        start_toolbox = varargin{1};        
    end
    
    
    project.paths.script.common_scripts     = fullfile(project.paths.svn_scripts_root, 'CommonScript', '');
    addpath(project.paths.script.common_scripts);      ... to get genpath2

    project.paths.script.eeg_tools          = fullfile(project.paths.script.common_scripts, 'eeg','eeg_tools', '');
    addpath(project.paths.script.eeg_tools);           ... to get define_project_paths

    project.paths.script.project            = fullfile(project.paths.svn_scripts_root, project.research_group, project.research_subgroup , project.name, '');   
    addpath(genpath2(project.paths.script.project));   ... in general u don't need to import the others' projects svn folders

    eval(project.conf_file_name);                                               ... project structure
    project                                 = define_project_paths(project, start_toolbox);    ... global and project paths definition. If 2nd param is 0, is faster, as it does not call eeglab
    project                                 = init_operations_flags(project);
end