function [titles] = eeglab_study_set_subplot_titles(STUDY,design_num)
% function [titles] = eeglab_study_set_subplot_titles(STUDY,design_num)
% sets titles of the subplots when representing group measures (ERP, ERSP) and 
% correpsonding statistics for regions of interest (ROI) in a EEGLab STUDY framework.     
% STUDY is a study structure created/loaded by EEGLab.
% design_num is the number of the design selected for the analysis.

% exctract names of the factores and the names of the corresponding levels for the selected design 
    name_f1=STUDY.design(design_num).variable(1).label;
    name_f2 = [];
    
    levels_f1=STUDY.design(design_num).variable(1).value;
    levels_f2 = [];
    num_var_des = length(STUDY.design(design_num).variable);
    if(num_var_des > 1)
        name_f2                            = STUDY.design(design_num).variable(2).label;
        levels_f2                          = STUDY.design(design_num).variable(2).value;
    end
    

    tlf1=length(levels_f1);
    tlf2=length(levels_f2);

    if tlf1 > 1 && tlf2 <= 1
        titles={};
        p_titles1={};
        meas_titles={};        
        for nf1=1:length(levels_f1)
            meas_titles{nf1}=char([levels_f1{nf1} ]);
        end
        
        titles=([meas_titles,   'P'])';
    end
 
    
    if tlf1 <=1 && tlf2 > 1
        titles={};
        p_titles2={};
        meas_titles={};        
        for nf2=1:length(levels_f2)
            meas_titles{nf2}=char([levels_f2{nf2} ]);
        end
        
        titles=[meas_titles,   'P'];
    end
    
    if tlf1 > 1 && tlf2 > 1
        % set the titles of the subfigures
        titles={};
        p_titles1={};
        p_titles2={};
        for nf1=1:length(levels_f1)
            for nf2=1:length(levels_f2)
               meas_titles{nf1,nf2}=char([levels_f2{nf2} ', ' levels_f1{nf1} ]);
            end
        end

        for nstat=1:nf1
            p_titles1{nstat}=char(['P(within ', levels_f1{nstat},')']);
        end
        p_titles1=[p_titles1,'P(interaction)'];

        for nstat=1:(nf2)
             p_titles2{nstat}=char(['P(within ', levels_f2{nstat},')']);
        end
        titles=[meas_titles;   p_titles2];
        titles=[titles,   p_titles1'];
    end
end