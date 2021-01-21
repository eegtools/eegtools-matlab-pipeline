function [subjects_list_by_factor_levels] = eeglab_generate_subjects_list_by_factor_levels(project, STUDY,design_num)

design_subjects_factor1={};
design_subjects_factor2={};
subjects_list_by_factor_levels={};

eeglab_version = eeg_getversion;

if sum(strfind(eeglab_version,'14'))
    
    design_cases={STUDY.design(design_num).cell.case};
    
    for ns=1:length(design_cases)
        design_subjects_factor1(ns)=STUDY.design(design_num).cell(ns).value(1);
        design_subjects_factor2(ns)=STUDY.design(design_num).cell(ns).value(2);
    end
    
    design_factor1=STUDY.design(design_num).variable(1).label;
    design_factor2=STUDY.design(design_num).variable(2).label;
    
    design_factor1_levels=STUDY.design(design_num).variable(1).value;
    design_factor2_levels=STUDY.design(design_num).variable(2).value;
    
    for nl1=1:length(design_factor1_levels)
        for nl2=1:length(design_factor2_levels)
            sel_subjs=strcmp(design_factor1_levels(nl1),design_subjects_factor1) &...
                strcmp(design_factor2_levels(nl2),design_subjects_factor2);
            subjects_list_by_factor_levels{nl1,nl2}=design_cases(sel_subjs);
        end
    end
    
else
    
    design_cases=[STUDY.design(design_num).cases.value];
    
    %     for ns=1:length(design_cases)
    %         design_subjects_factor1(ns)=STUDY.design(design_num).cell(ns).value(1);
    %         design_subjects_factor2(ns)=STUDY.design(design_num).cell(ns).value(2);
    %     end
    %
    design_factor1=STUDY.design(design_num).variable(1).label;
    
    
    design_factor1_levels=STUDY.design(design_num).variable(1).value;
    
    
    if length(STUDY.design(design_num).variable) > 1
        design_factor2=STUDY.design(design_num).variable(2).label;
        design_factor2_levels=STUDY.design(design_num).variable(2).value;
        for nl1=1:length(design_factor1_levels)
            for nl2=1:length(design_factor2_levels)
                subjects_list_by_factor_levels{nl1,nl2}=design_cases;
            end
        end
        
        if strcmp(design_factor1,'group') || strcmp(design_factor1,'gruppo')
            for ncg = 1:length(project.subjects.group_names)
                current_group = project.subjects.group_names(ncg);
                sel_groups = find(ismember(design_factor1_levels,current_group));
                if sum(sel_groups)
                    for nl2=1:length(design_factor2_levels)
                        subjects_list_by_factor_levels{sel_groups,nl2}=intersect(project.subjects.groups{ncg},design_cases);
                    end
                end
            end
            
        end
        
        
        if strcmp(design_factor2,'group') || strcmp(design_factor2,'gruppo')
            for ncg = 1:length(project.subjects.group_names)
                current_group = project.subjects.group_names(ncg);
                sel_groups = find(ismember(design_factor2_levels,current_group));
                if sum(sel_groups)
                    for nl1=1:length(design_factor1_levels)
                        subjects_list_by_factor_levels{nl1,sel_groups}=intersect(project.subjects.groups{ncg},design_cases);
                    end
                end
            end
            
        end
    else
        for nl1=1:length(design_factor1_levels)
            for nl2=1
                subjects_list_by_factor_levels{nl1,nl2}=design_cases;
            end
        end
        
        if strcmp(design_factor1,'group') || strcmp(design_factor1,'gruppo')
            for ncg = 1:length(project.subjects.group_names)
                current_group = project.subjects.group_names(ncg);
                sel_groups = find(ismember(design_factor1_levels,current_group));
                if sum(sel_groups)
                    for nl2=1
                        subjects_list_by_factor_levels{sel_groups,nl2}=intersect(project.subjects.groups{ncg},design_cases);
                    end
                end
            end
            
        end
        
        
        
    end
    
    
    
    
    
    
    
    
end
end