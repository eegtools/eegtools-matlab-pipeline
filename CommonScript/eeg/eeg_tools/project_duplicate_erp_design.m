function project = project_duplicate_erp_design(project, num_design)

    for ds=2:num_design
        project.postprocess.erp.design(ds) = project.postprocess.erp.design(1);
    end

end