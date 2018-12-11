% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function  proj_brainstorm_subject_sources_new(project,  varargin)

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
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

if not(isfield(project.brainstorm,'condition_names'))
    project.brainstorm.condition_names = project.epoching.condition_names;
    project.brainstorm.numcond         = project.epoching.numcond;
end

% perform sources processing over subject/condition/data_average.mat
sources_results = cell(length(list_select_subjects), project.brainstorm.sensors.tot_num_contrasts);

for subj=1:length(list_select_subjects)
    % 4 conditions
    for cond=1: project.brainstorm.numcond
        cond_name                       = project.brainstorm.condition_names{cond};
        for sources_params=1:length(project.brainstorm.do_sources.params)
            sources_results{subj, cond}     = brainstorm_subject_sources(project.brainstorm.db_name, list_select_subjects{subj}, cond_name, [project.brainstorm.average_file_name '.mat'], project.brainstorm.do_sources.params{sources_params}{:});
        end
    end
end

end

