function [button] = set_button_icon(button, icon_folder_path, scale)
%Given a button, this function leads an image and applies the image to the
%button. If the image is too big the user can also choose a scale factor to
%resize the image.

    % load the image of the button
    imgData = imread(icon_folder_path);
    imgData = image_3ch_resize(imgData, scale, scale);
    jimage = im2java(imgData);
    button.setIcon(javax.swing.ImageIcon(jimage));

end

