%% look project_define_paths:
%%
function project = define_project_paths(project, varargin)

   project.paths.script.eeg_tools_project = fullfile(project.paths.script.eeg_tools, 'project', '');
   addpath(project.paths.script.eeg_tools_project);

   project = project_define_paths(project);     
end
