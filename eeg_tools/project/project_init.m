%% function project = initProject(project, varargin)
%   load a new project structure in the workspace
%
function project = project_init(project, varargin)

    project                         = project_clear(project);                   % force clearing complex structures  
    
    eval(project.conf_file_name);                                               % load variables from file
    
    project                         = project_init_operations_flags(project);   % init operations flags
    if project.operations.do_source_analysis
        project                     = project_init_operations_flags_brainstorm(project);    % init brainstorm operations flags
    end
    project                         = project_define_paths(project, varargin{:});        % define project paths
end

