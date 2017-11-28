function sFiles = proj_brainstorm_group_stats_cond_group_ttest_new(project,varargin)

protocol_name                       = project.brainstorm.db_name;
group_comparison_analysis_type_list = project.brainstorm.groupanalysis.analysis_type_list;
pairwise_comparisons                = project.brainstorm.groupanalysis.pairwise_comparisons;
comparison_comment                  = project.brainstorm.groupanalysis.comment;
comparison_abs_type                 = project.brainstorm.groupanalysis.abs_type;
comparison_interval                 = project.brainstorm.groupanalysis.interval;
data_type                           = project.brainstorm.groupanalysis.data_type;
list_select_subjects                = project.subjects.list;

compare_conds_within_group          = project.brainstorm.groupanalysis.compare_conds_within_group;
compare_groups_within_cond          = project.brainstorm.groupanalysis.compare_groups_within_cond;


vec_select_groups = project.brainstorm.groupanalysis.vec_select_groups;

list_select_conds = [pairwise_comparisons{:}];


for v=1:2:length(varargin)
    if ~isempty(varargin{v+1})
        assign(varargin{v}, varargin{v+1});
    end
end

%% fisso il gruppo e confronto a coppie le condizioni
if compare_conds_within_group
    
    for nt = 1:length(group_comparison_analysis_type_list)
        analysis_type = group_comparison_analysis_type_list{nt};
        
        for ngroup = vec_select_groups
            group_name = project.subjects.group_names{ngroup};
            sel_sub_gru = ismember(project.subjects.groups{ngroup},list_select_subjects);
            list_select_subjects_group = project.subjects.groups{ngroup}(sel_sub_gru);
            
            for pwc=1:length(pairwise_comparisons)
                sFiles = brainstorm_group_stats_2cond_pairedttest2(protocol_name,...
                    pairwise_comparisons{pwc}{1}, ...
                    pairwise_comparisons{pwc}{2}, ...
                    data_type, ...
                    analysis_type, ...
                    group_name, ...
                    list_select_subjects_group, ...
                    'comment', comparison_comment,...
                    'abs_type', comparison_abs_type, ...
                    'timewindow', comparison_interval...
                    );
                
            end
            
        end
        
    end
end
%% fisso la condizione e confronto a coppie i gruppi
if compare_groups_within_cond
    group_contrasts = combnk(vec_select_groups,2);
    tot_group_contrasts = size(group_contrasts,1);
    
    for nt = 1:length(group_comparison_analysis_type_list)
        analysis_type = group_comparison_analysis_type_list{nt};
        
        for nc = 1:length(list_select_conds)
            
            for ngc = 1:tot_group_contrasts
                
                indg1 = group_contrasts(ngc,1);
                indg2 = group_contrasts(ngc,2);
                
                group_name1 = project.subjects.group_names{indg1};
                sel_sub_gru1 = ismember(project.subjects.groups{indg1},list_select_subjects);
                list_select_subjects_group1 = project.subjects.groups{indg1}(sel_sub_gru1);
                
                group_name2 = project.subjects.group_names{indg2};
                sel_sub_gru2 = ismember(project.subjects.groups{indg2},list_select_subjects);
                list_select_subjects_group2 = project.subjects.groups{indg2}(sel_sub_gru2);
                
                sFiles = brainstorm_group_stats_cond_2group_ttest(protocol_name,...
                    group_name1, ...
                    list_select_subjects_group1, ...
                    group_name2, ...
                    list_select_subjects_group2, ...
                    data_type, ...
                    analysis_type, ...
                    list_select_conds{nc}, ...
                    'comment', comparison_comment,...
                    'abs_type', comparison_abs_type, ...
                    'timewindow', comparison_interval...
                    );
            end
        end
        
    end
end

iProtocol = brainstorm_protocol_open(project.brainstorm.db_name);
db_reload_database(iProtocol);
end

