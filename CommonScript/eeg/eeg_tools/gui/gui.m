function [] = gui()
%GUI Summary of this function goes here
%   Detailed explanation goes here

    javaj_jar_path = '\eeggui\dist\eeggui.jar';
    javaaddpath(javaj_jar_path)

    global gg  % Make the handle to the main panel global

    fig = figure('visible', 'on', 'units','normalized','outerposition',[0 0 1 1]);
    drawnow
    gg = GImport(fig, gui.basePanel());
    gg.getHandles();

    newButton = gg.getHandles().New;
    gg.setCallback(newButton, 'ActionPerformedCallback', @print_string, 'marcello')
    
%      if exist('gg', 'var')
%         javarmpath(javaj_jar_path)
%     end
end

