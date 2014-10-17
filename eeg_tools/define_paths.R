#script to define paths

# require R packages mostly needed  
require(reshape)
require(ez)
require(multcomp)
require(gplots)
require(matlab) 
require(XLConnect)


# PATHS



# project script path
projects_scripts_path=fullfile(svn_local_path, project_folder);
# difference compared to matlab: to execute a script it is not enough to type the name of the scrupt: it needs source(filename)
setwd(projects_scripts_path);

# load configuration file
project_settings=fullfile(projects_scripts_path, conf_file_name);
source(project_settings);


# global script path
global_scripts_path=fullfile(svn_local_path, 'global_scripts');

# project path
project_path=fullfile(local_projects_data_path,project_folder, '');

# vhdr files exported from brain vision
vhdr_path=fullfile(project_path,'brainvision_data','Export', analysis_name, '');

# exported time frequency representations
tf_path=fullfile(project_path,'timefrequency',analysis_name, '');

# exported erp to be processed in R
erp_path=fullfile(project_path,'erp',analysis_name, '');      

# let functions in the EEG tooblox to be availlable
sourceDirectory(global_scripts_path, modifiedOnly=TRUE)