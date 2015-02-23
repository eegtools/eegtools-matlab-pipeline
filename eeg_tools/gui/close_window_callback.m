function close_window_callback(varargin)
    % Wait for mutex (release when window is closed)
    bst_mutex('release', 'gui');
end

