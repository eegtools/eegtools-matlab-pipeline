%% function project = initProject(project)
%   load a new project structure in the workspace
%
function project = project_init(project)
    project = project_clear(project);     % force clearing complex structures
    eval(project.conf_file_name);                   % load variables from file
    project = define_project_paths(project);        % define project paths
end

