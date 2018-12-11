function  proj_brainstorm_group_average_cond_results2_cont_new(project,  varargin)

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

list_select_subjects    = project.subjects.list;
vec_select_groups       = project.brainstorm.groupanalysis.vec_select_groups;


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




for nt = 1:length(project.brainstorm.groupanalysis.averaging_continuous_list)
    group_comparison_analysis_type = project.brainstorm.groupanalysis.averaging_continuous_list{nt};
    for ngroup = vec_select_groups
        group_name = project.subjects.group_names{ngroup};
        sel_sub_gru = ismember(project.subjects.groups{ngroup},list_select_subjects);
        list_select_subjects_group = project.subjects.groups{ngroup}(sel_sub_gru);
        db_reload_database(iProtocol);
        brainstorm_group_average_cond_results2(project.brainstorm.db_name, group_name, list_select_subjects_group, project.brainstorm.condition_names, group_comparison_analysis_type);
    end
end
    db_reload_database(iProtocol);


end




