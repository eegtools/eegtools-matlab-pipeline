function [] = gui()

    % MATLAB_JAVA

    javaj_jar_path = '/data/behavior_lab_svn/behaviourPlatform/CommonScript/eeg/eeg_tools/gui/eeggui/dist/eeggui.jar';
    ...javaj_jar_path = '\\VBOXSVR\data\behavior_lab_svn\behaviourPlatform\CommonScript\eeg\eeg_tools\gui\eeggui\dist\eeggui.jar';
    
    
    javaaddpath(javaj_jar_path);
    global gg  % Make the handle to the main panel global

    fig = figure('visible', 'on', 'units','normalized','outerposition',[0 0 1 1]);
    drawnow
    gg = GImport(fig, gui.JTPMain());

    handles = gg.getHandles();
    newButton = gg.getHandles().btNewProject;  % this is the NAME in Properties, not VARIABLE NAME in code
    gg.setCallback(newButton, 'ActionPerformedCallback', @print_string, 'marcello')

    
%      if exist('gg', 'var')
%         javarmpath(javaj_jar_path)
%     end

end
