function project = project_duplicate_ersp_design(project, num_design)

    for ds=2:length(num_design)
        project.postprocess.ersp.design(ds) = project.postprocess.ersp.design(1);
    end

end