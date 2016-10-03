%% function project = clear_project_structure(project)
%  force clearing complex structures, usually called with initProjec function, 
% before loading the project from its file
%
%
%
function project = project_clear(project)

    if isfield(project, 'subjects')
        if isfield(project.subjects, 'data')
            project.subjects = rmfield(project.subjects, 'data');
        end
    end


    if isfield(project, 'study')
        if isfield(project.study, 'factors')
            project.study = rmfield(project.study, 'factors');
        end
    end

    if isfield(project, 'design')
        project = rmfield(project, 'design');
    end



    if isfield(project, 'postprocess')
        if isfield(project.postprocess, 'erp')
            if isfield(project.postprocess.erp, 'design')
                project.postprocess.erp = rmfield(project.postprocess.erp, 'design');
            end
        end
    end


    if isfield(project, 'postprocess')
        if isfield(project.postprocess, 'ersp')
            if isfield(project.postprocess.ersp, 'frequency_bands')
                project.postprocess.ersp = rmfield(project.postprocess.ersp, 'frequency_bands');
            end
        end
    end


    if isfield(project, 'postprocess')
        if isfield(project.postprocess, 'ersp')
            if isfield(project.postprocess.ersp, 'design')
                project.postprocess.ersp = rmfield(project.postprocess.ersp, 'design');
            end
        end
    end

end