function [] = gui()
%GUI Summary of this function goes here
%   Detailed explanation goes here
%
     % MATLAB_JAVA
     % C:\Program Files (x86)\Java\jdk1.8.0_40\jre

    javaaddpath('/data/behavior_lab_svn/behaviourPlatform/CommonScript/eeg/eeg_tools/gui/eeggui/dist/eeggui.jar')
    ...javaaddpath('\\VBOXSVR\data\behavior_lab_svn\behaviourPlatform\CommonScript\eeg\eeg_tools\gui\eeggui\dist\eeggui.jar')
%    javaaddpath('C:\Users\goccia\Documents\NetBeansProjects\eeggui\dist\eeggui.jar')
%    javaaddpath([pwd filesep 'eeggui.jar'])
    global gg  % Make the handle to the main panel global

    %fig = figure('visible', 'on');
    fig = figure('visible', 'on', 'units','normalized','outerposition',[0 0 1 1]);
    drawnow
    %frame = GXJFrame(fig);
    gg = GImport(fig, gui.basePanel());

% %    g = GImport(frame, gui.basePanel(), false);
%     %gg=GImport(figure(1), gui.basePanel());
    gg.getHandles();
%     
%     %a = g.getComponents();
%     %jbutton = a{10};  % More complicated
%     %g.setCallback(jbutton, 'ActionPerformedCallback', @callback_print)
%     %textfield = jbutton.name;
%     
%
     newButton = gg.getHandles().New;
%     newButton = gg.find('New');   % Much easier to access the button.
     gg.setCallback(newButton, 'ActionPerformedCallback', @print_string, 'marcello')

    
%      if exist('gg', 'var')
%         javarmpath(javaj_jar_path)
%     end
end

