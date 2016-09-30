% it will contain as much CASE branches as the available processes

function project = initProject(project)
    eval(project.conf_file_name);
    project = define_project_paths(project);
end

