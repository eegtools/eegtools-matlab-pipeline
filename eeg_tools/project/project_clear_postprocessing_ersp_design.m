function project = project_clear_postprocessing_ersp_design(project)

    if isfield(project, 'postprocess')
        if isfield(project.postprocess, 'ersp')
            if isfield(project.postprocess.erp, 'design')
                project.postprocess.erp = rmfield(project.postprocess.erp, 'design');
            end
        end
    end

end