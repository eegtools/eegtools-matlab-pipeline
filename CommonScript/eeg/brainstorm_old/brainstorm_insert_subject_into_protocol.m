function brainstorm_insert_subject_into_protocol(subj_name, protocol_name)

    if ~brainstorm('status')
        brainstorm nogui
    end
    
    iProtocol = bst_get('Protocol', protocol_name);
    gui_brainstorm('SetCurrentProtocol', iProtocol);
    
    UseDefaultAnat = 0;
    UseDefaultChannel = 0;
    [sSubject, iSubject] = db_add_subject(subj_name, [], UseDefaultAnat, UseDefaultChannel);
    % If an error occured in subject creation (subject already exists, impossible to create folders...)
    if isempty(sSubject)
        error('Could not create subject.');
    end

end