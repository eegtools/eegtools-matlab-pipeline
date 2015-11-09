function button = getButtonWithIcon(path_icon_image, ...
    scale, ...
    property_name, ...
    callback_func)
% It returns a button which displays an Icon on top of it.
% It needs as input: 
% - the path of the input image
% - the resize scale of the icon image 
% - the name of the property associated to that button (e.g. 'ActionPerformedCallback')
% - the callback function

    button = javax.swing.JButton();
    % load the image of the button
    set_button_icon(button, path_icon_image, scale);
    button_handle = handle(button, 'CallbackProperties');
    set(button_handle, property_name, callback_func);

end