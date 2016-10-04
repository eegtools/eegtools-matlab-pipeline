%% function project = initProject(project, varargin)
%   load a new project structure in the workspace
%
function project = project_init(project, varargin)
    project = project_clear(project);     % force clearing complex structures
    eval(project.conf_file_name);                   % load variables from file
    project = project_define_paths(project, varargin{1});        % define project paths
end

