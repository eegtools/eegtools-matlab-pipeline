% read input .set file, do a global baseline correction and then do epoching 
% varargin


function EEG = proj_eeglab_study_create_group_conditions(project, varargin)

    ... default values
    cond_names      = project.epoching.condition_names;
    groups_list     = project.subjects.groups;
    groups_names    = project.subjects.group_names;
    
    
    options_num=size(varargin,2);
    
    for opt=1:2:options_num
        
        switch varargin{opt}
        case {'cond_names', 'groups_list', 'groups_names'}
            if isempty(varargin{opt+1})
                continue;
            else
                assign(varargin{opt}, varargin{opt+1});
            end            
        end
    end

    % ----------------------------------------------------------------------------------------------------------------------------
    % create input filename
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    for cond = 1:length(cond_names)
        cond_name = cond_names{cond};
        
        for grp = 1:length(groups_names)
            group_name = groups_names{grp};
            
            for subj = 1:length(groups_list{grp})
                subj_name           = groups_list{grp}{subj};
                input_file_name     = fullfile(project.paths.output_epochs,  [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);
                EEG = pop_loadset(input_file_name);  
                [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
            end
            output_file = [group_name '_group_' cond_name '.set'];
            merged_EEG  = pop_mergeset ( ALLEEG,[1:length(ALLEEG)],0);
            pop_saveset(merged_EEG, 'filepath', project.paths.output_epochs, 'filename', output_file);
            ALLEEG = []; EEG = [];
            eeglab
        end
    end
end

% CHANGE LOG 


    

    