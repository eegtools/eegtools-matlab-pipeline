% Protocol name has to be a valid folder name (no spaces, no weird characters...)

function iProtocol = brainstorm_protocol_create(ProtocolName,folder_path,default_anatomy)

    if ~brainstorm('status')
        brainstorm nogui
    end
    
    if nargin > 2
        default_anat=1;
    else
        default_anat=0;       
    end
    % Removing existing protocol with the same name
    isUserConfirm = 0;
    isRemoveFiles = 1;
    
    iProtocol = bst_get('Protocol', ProtocolName);
    
    if ~isempty(iProtocol)
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        db_delete_protocol(isUserConfirm, isRemoveFiles);
    end

    % Force to delete pre-existing folders
    if file_exist(folder_path)
        rmdir(folder_path);
    end

    % create protocol folder
    mkdir(folder_path);

    % Get default structure for protocol description
    sProtocol = db_template('ProtocolInfo');
    % Fill with the properties we want to use
    sProtocol.Comment  = ProtocolName;
    sProtocol.SUBJECTS = fullfile(folder_path, 'anat');
    sProtocol.STUDIES  = fullfile(folder_path, 'data');
    sProtocol.UseDefaultAnat    = default_anat;
    sProtocol.UseDefaultChannel = 1;
    % Create the protocol in Brainstorm database
    iProtocol = db_edit_protocol('create', sProtocol);
    % If an error occured in protocol creation (protocol already exists, impossible to create folders...)
    if (iProtocol <= 0)
        error('Could not create protocol.');
    end

    % Set new protocol as current protocol
    gui_brainstorm('SetCurrentProtocol', iProtocol);

    if nargin > 2
        % Set default anatomy
        bst_dir = bst_get('BrainstormHomeDir');
        template_anat_dir = fullfile(bst_dir, 'defaults', 'anatomy', default_anatomy);
        sTemplate.Name=default_anatomy;
        sTemplate.FilePath=template_anat_dir;
        db_set_template(0, sTemplate, 0);
    end
end