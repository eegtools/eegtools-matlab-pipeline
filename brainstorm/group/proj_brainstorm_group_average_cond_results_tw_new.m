function  proj_brainstorm_group_average_cond_results_tw_new(project,  varargin)
% versione vecchia della senza distinzione tra gruppi (introdotta in
% proj_brainstorm_group_average_cond_results_new2)

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


for nt = 1:length(project.brainstorm.groupanalysis.averaging_tw_list)
    db_reload_database(iProtocol);
    group_comparison_analysis_type = project.brainstorm.groupanalysis.averaging_tw_list{nt};
    brainstorm_group_average_cond_results(project.brainstorm.db_name, list_select_subjects, project.brainstorm.condition_names, group_comparison_analysis_type);
    
end
    db_reload_database(iProtocol);

end

