function results = proj_brainstorm_group_stats_baseline_ttest_new(project,varargin)

protocol_name                         = project.brainstorm.db_name;
group_comparison_analysis_type_list   = project.brainstorm.groupanalysis.analysis_type_list;
list_select_subjects                  = project.subjects.list;
baseline_comparisons                  = project.brainstorm.baselineanalysis.comparisons;
baseline                              = project.brainstorm.baselineanalysis.baseline;
poststim                              = project.brainstorm.baselineanalysis.poststim;
comment                               = project.brainstorm.groupanalysis.comment;

results = {};






for v=1:2:length(varargin)
    if ~isempty(varargin{v+1})
        assign(varargin{v}, varargin{v+1});
    end
end



for nt = 1:length(group_comparison_analysis_type_list)
    analysis_type = group_comparison_analysis_type_list{nt};
    
    
    for ngroup = vec_select_groups
        group_name = project.subjects.group_names{ngroup};
        sel_sub_gru = ismember(project.subjects.groups{ngroup},list_select_subjects);
        list_select_subjects_group = project.subjects.groups{ngroup}(sel_sub_gru);
        
        
        %   avg_func:                 1: Absolute value of average: abs(mean(x))
        %                             2: Absolute value of average: abs(mean(x))
        %                             3: Absolute value of average: abs(mean(x))
        
        
        for bc=1:length(baseline_comparisons)...protocol_name, cond,  analysis_type, prestim, poststim, avg_func, subjects_list, varargin
                results{bc} = brainstorm_group_stats_baseline_ttest_new(protocol_name, ...
                baseline_comparisons{bc}, ...
                analysis_type, ...
                group_name,...
                baseline,...
                poststim,...
                2 , ... AVG_FUNC
                list_select_subjects_group, ...
                'comment', comment ...
                );
        end
        
        
        
    end
    
end
iProtocol = brainstorm_protocol_open(project.brainstorm.db_name);
db_reload_database(iProtocol);
end



