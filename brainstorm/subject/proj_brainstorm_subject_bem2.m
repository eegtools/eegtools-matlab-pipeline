... model_type 1: surface, 2: vol
function proj_brainstorm_subject_bem2(project, subj_name, varargin)

    subj_file_name = fullfile(subj_name, project.epoching.condition_names{1}, 'data_average.mat'); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
    brainstorm_subject_bem2(project.brainstorm.db_name, subj_file_name, varargin{:});
    
end

