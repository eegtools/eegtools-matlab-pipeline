function [subjects_list_by_factor_levels] = eeglab_generate_subjects_list_by_factor_levels(STUDY,design_num)

design_subjects_factor1={};
design_subjects_factor2={};
subjects_list_by_factor_levels={};


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
        sel_subjs=strcmp(design_factor1_levels(nl1),design_subjects_factor1) & strcmp(design_factor2_levels(nl2),design_subjects_factor2);
        subjects_list_by_factor_levels{nl1,nl2}=design_cases(sel_subjs);
    end
end