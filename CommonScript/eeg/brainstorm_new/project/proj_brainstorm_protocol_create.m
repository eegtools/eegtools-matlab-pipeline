% Protocol name has to be a valid folder name (no spaces, no weird characters...)

function iProtocol = proj_brainstorm_protocol_create(project) ... ProtocolName,folder_path,default_anatomy)

    iProtocol = brainstorm_protocol_create(project.brainstorm.db_name, fullfile(project.paths.project, project.brainstorm.db_name, '') , project.brainstorm.default_anatomy);

end