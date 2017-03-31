
function iProtocol = brainstorm_protocol_open(protocol_name)

    if ~brainstorm('status')
        brainstorm nogui
    end
    iProtocol = bst_get('Protocol', protocol_name);
    gui_brainstorm('SetCurrentProtocol', iProtocol);
    
end

