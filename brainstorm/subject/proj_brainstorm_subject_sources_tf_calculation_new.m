% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function  proj_brainstorm_subject_sources_tf_calculation_new(project,  varargin)

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

if not(isfield(project.brainstorm,'condition_names'))
    project.brainstorm.condition_names = project.epoching.condition_names;
    project.brainstorm.numcond         = project.epoching.numcond;
end


sources_norm=[sources_norm '_s3000'];

if ~project.operations.do_sources_calculation
    % reconstruct output source relative paths.
    src_name=['results_' sources_norm];
    if (strcmp(source_orient, 'loose'))
        dest_name=[src_name '_loose'];
    end
    sources_results=cell(length(list_select_subjects), project.brainstorm.sensors.tot_num_contrasts);
    for subj=1:length(list_select_subjects)
        for cond=1:project.brainstorm.numcond
            cond_name                       = project.brainstorm.condition_names{cond};
            sources_tf_results{subj,cond} = fullfile(list_select_subjects{subj}, cond_name, [src_name '.mat']);
        end
        for mcond=1:length(name_maineffects)
            totcond=mcond+length(cond_name);
            sources_tf_results{subj,totcond} = fullfile(list_select_subjects{subj}, name_maineffects{mcond}, [src_name '.mat']);
        end
    end
end
end

