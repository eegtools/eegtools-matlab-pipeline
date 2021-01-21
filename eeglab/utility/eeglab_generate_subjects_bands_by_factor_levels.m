function [subjects_bands_by_factor_levels] = eeglab_generate_subjects_bands_by_factor_levels(STUDY, design_num, subjects_data, global_frequency)

% design_num=10

design_subjects_factor1={};
design_subjects_factor2={};
subjects_bands_by_factor_levels={};

eeglab_version = eeg_getversion;

if sum(strfind(eeglab_version,'14'))
    design_cases={STUDY.design(design_num).cell.case};
else
    design_cases=STUDY.design(design_num).cases.value;
end
design_cases_frequency=design_cases;


% subjects_list=unique(design_cases);
% subjects_frequency=[];
%     for nn=1:length(subjects_list)
%         subjects_frequency=[subjects_frequency;{frequency_bands_list}];
%     end


% fill with global or individual fb
for nsub=1:length(subjects_data)
    sel_subjs=strcmp(subjects_data(nsub).name, design_cases);
    if isfield(subjects_data(nsub), 'frequency_bands_list')
        if ~isempty(subjects_data(nsub).frequency_bands_list)
            design_cases_frequency(sel_subjs)={subjects_data(nsub).frequency_bands_list};
        else
            design_cases_frequency(sel_subjs)={global_frequency};
        end
    else
        design_cases_frequency(sel_subjs)={global_frequency};
    end
end

if sum(strfind(eeglab_version,'14'))
    
    % split according to design specifications
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
            subjects_bands_by_factor_levels{nl1,nl2}=design_cases_frequency(sel_subjs);
        end
    end
else
    
    % split according to design specifications
    for ns=1:length(design_cases)
        design_subjects_factor1(ns)=design_cases(ns);
    end
    
    
    design_factor1=STUDY.design(design_num).variable(1).label;
    
    design_factor1_levels=STUDY.design(design_num).variable(1).value;
    if (length(STUDY.design(design_num).variable) > 1)
        
        % split according to design specifications
        for ns=1:length(design_cases)
            design_subjects_factor2(ns)=design_cases(ns);
        end
        
        design_factor2=STUDY.design(design_num).variable(2).label;
        design_factor2_levels=STUDY.design(design_num).variable(2).value;
        
        for nl1=1:length(design_factor1_levels)
            for nl2=1:length(design_factor2_levels)
%                 sel_subjs=strcmp(design_factor1_levels(nl1),design_subjects_factor1) & strcmp(design_factor2_levels(nl2),design_subjects_factor2);
                subjects_bands_by_factor_levels{nl1,nl2}=design_cases_frequency;
            end
        end
    else
        for nl1=1:length(design_factor1_levels)
            subjects_bands_by_factor_levels{nl1,1}=design_cases_frequency;
            
        end
    end
    
end
end