% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function  proj_brainstorm_subject_sources_spatial_reduction_new(project,  varargin)

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



condition_names             = project.epoching.condition_names;    cond_length = length(condition_names);
for t=1:length(project.brainstorm.postprocess.tag_list)
    tag         = project.brainstorm.postprocess.tag_list{t};
    input_file  = [project.brainstorm.average_file_name '.mat'];   .... e.g. 'data_average.mat'
        
for cond=1:project.epoching.numcond
    cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_select_subjects, condition_names{cond}, input_file, tag);
    for s=1:length(cond_files)
        result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
        brainstorm_results_downsample(project.brainstorm.db_name, result_file, downsample_atlasname);
    end
end

end

end

