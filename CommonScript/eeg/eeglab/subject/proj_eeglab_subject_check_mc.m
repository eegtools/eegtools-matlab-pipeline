function EEG  =  proj_eeglab_subject_check_mc(project, varargin)

list_select_subjects    = project.subjects.list;
custom_suffix           = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);



for subj=1:numsubj
    
    subj_name                   = list_select_subjects{subj};
    input_file_name             = proj_eeglab_subject_get_filename(project, subj_name,'input_epoching','custom_suffix', custom_suffix);
    EEG                         = pop_loadset(input_file_name);
    
    EEG                         = eeglab_subject_check_mc(EEG);
    
end



end