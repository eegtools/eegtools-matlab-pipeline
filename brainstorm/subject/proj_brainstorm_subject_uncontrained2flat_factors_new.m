% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function  proj_brainstorm_subject_uncontrained2flat_factors_new(project,  varargin)

iProtocol               = brainstorm_protocol_open(protocol_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

list_select_subjects    = project.subjects.list;

for par=1:2:length(varargin)
    switch varargin{par}
        case { 'list_select_subjects', ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end



condition_names             = {project.study.factors.level};    cond_length = length(condition_names);
for t=1:length(project.brainstorm.postprocess.tag_list)
    tag         = project.brainstorm.postprocess.tag_list{t};
    input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'
        
for cond=1:cond_length
    cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_select_subjects, condition_names{cond}, input_file, tag);
    for s=1:length(cond_files)
        result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
        brainstorm_result_uncontrained2flat(project.brainstorm.db_name, result_file, source_flatting_method);
    end
end
end
    db_reload_database(iProtocol);

end

