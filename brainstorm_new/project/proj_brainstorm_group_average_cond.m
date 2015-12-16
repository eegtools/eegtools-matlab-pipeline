
function sFiles = proj_brainstorm_group_average_cond(project, varargin) ... protocol_name, subjects_list, cond_list, input_file_name)

    protocol_name = project.brainstorm.db_name;
    
    % default
    subjects_list   = project.subjects.list;
    cond_list       = project.epoching.condition_names;
    input_suffix    = project.brainstorm.average_file_name;
    
    for v=1:2:length(varargin)
       if ~isempty(varargin{v+1})
           switch varargin{v}
               case 'input_suffix'
                   input_suffix = varargin{v+1};
               case 'cond_list'
                   cond_list = varargin{v+1};
               case 'subjects_list'
                   subjects_list = varargin{v+1};
           end
       end
    end
    
    sFiles = brainstorm_group_average_cond_results(protocol_name, subjects_list, cond_list, input_suffix); 
end
