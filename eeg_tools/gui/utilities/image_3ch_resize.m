function scaled = image_3ch_resize(image, scale_x, scale_y)
    % Given a 3 channel image in input, it resizes the image accroding the the
    % x and y scale factor passed.

    a = imageresize(image(:,:,1), scale_x, scale_y);
    b = imageresize(image(:,:,2), scale_x, scale_y);
    c = imageresize(image(:,:,3), scale_x, scale_y);
    scaled = cat(3, a, b, c );
    
end

