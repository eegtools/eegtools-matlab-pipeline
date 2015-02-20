function [] = gui()
%TEST Summary of this function goes here
%   Detailed explanation goes here

    % Create the mutex GUI
    bst_mutex('create', 'gui');
    % Release the mutex when the window is closed
    bst_mutex('setReleaseCallback', 'gui', @closeWindowCallback);

    %% Complete the params that will go into the GlobalData variable
    % Initialise the global variable struct.
    global GlobalData;
    GlobalData = initialise_params('GlobalData');

    %template_main_eeglab_subject_processing
    %template_main_eeglab_group_processing
    template_project_structure

    if exist('project', 'var')
        fill_global_data_with_template(project)
    end
 
    %%
    % Create the main frame.
    GlobalData.main_panel = createMainPanel();
    main_panel = GlobalData.main_panel;

    %%
    % create the top panel 
    % Need a top panel to ad the the main frame.
    GlobalData.top_panel = createTopPanel();
    top_panel =  GlobalData.top_panel;

    %% The tabbed panel can only be added to a panel not to the main frame.
    tabbed_panel = addTabbedPanel();
    
    %% Panel with paths.
    get_panel_paths(tabbed_panel);
    
    %%
    % Create now the TABs
    
%     GlobalData.main_tabs = [GlobalData.main_tabs addPanelToTabbedPanel(tabbed_panel, 'Panel 1')];
%     GlobalData.main_tabs = [GlobalData.main_tabs addPanelToTabbedPanel(tabbed_panel, 'Panel 2')];
%     GlobalData.main_tabs = [GlobalData.main_tabs addPanelToTabbedPanel(tabbed_panel, 'Panel 3')];
%     
    % TAB 1 -grid box
%     bf = javax.swing.BorderFactory;
%     border = javax.swing.BorderFactory.createEmptyBorder(5, 5, 5, 5);
%     GlobalData.main_tabs(1).setBorder(border);
%     % 
%     % GridLayout(rows, cols, x_border, y_border)
%     grid = java.awt.GridLayout(10, 4, 10, 10);
%     GlobalData.main_tabs(1).setLayout(grid);
%     buttons = {...
%             'Cls', 'Bck', '', 'Close', '7', '8', '9', '/', '4',...
%             '5', '6', '*', '1', '2', '3', '-', '0', '.', '=', '+'...
%         };
%     for i=1:length(buttons)
%         if i == 2
%             label = javax.swing.JLabel(buttons{i}, javax.swing.SwingConstants.CENTER);
%             GlobalData.main_tabs(1).add(label);
%         else
%             button = javax.swing.JButton(buttons{i});
%             GlobalData.main_tabs(1).add(button);
%         end
%     end
%     
%     % TAB 2
%     GlobalData.main_tabs(2) = addLabelToPanel(GlobalData.main_tabs(2), 'this is a test');
%     GlobalData.main_tabs(2) = addButtonToPanel(GlobalData.main_tabs(2), 'test button');
% 
%     % TEXT FIELD
%     GlobalData.textFields.path = javax.swing.JTextField('default', 50);
%     GlobalData.main_tabs(2).add(GlobalData.textFields.path, java.awt.BorderLayout.CENTER);
%     GlobalData.textFields.path.setText('Control in action: JTextField');
% %     str = GlobalData.textFields.path.getText();
% %     disp(str)
%     
%     % button
%     button = javax.swing.JButton('invio');
%     GlobalData.main_tabs(2).add(button);
%     %set(panel,'UserData',params); 
%     button_handle = handle(button,'CallbackProperties');
%     set(button_handle, 'ActionPerformedCallback', @enterPath);
%     
%     top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
%     
%     %%%%% TAB 3 -box layout
%     Y_AXIS = javax.swing.BoxLayout.Y_AXIS;
%     % We say that GlobalData.main_tabs(3) has vertical box layout.
%     % With this I make tab 3 as a vertical box layout.
%     boxlayout = javax.swing.BoxLayout(GlobalData.main_tabs(3), Y_AXIS);
%     GlobalData.main_tabs(3).setLayout(boxlayout);
%
%     bottom = javax.swing.JPanel(); %java.awt.FlowLayout(java.awt.FlowLayout.LEFT));
%     % The bottom panel is right aligned. 
% %    bottom.setAlignmentX(1);
% %    bottom.setAlignmentX(java.awt.Component.CENTER_ALIGNMENT);
%     X_AXIS = javax.swing.BoxLayout.X_AXIS;
%     % We say that bottom has horizontal box layout
%     boxlayout = javax.swing.BoxLayout(bottom, X_AXIS);
%     bottom.setLayout(boxlayout);
% 
%     % Look at ButtonGroup radioGroup = new ButtonGroup();
%     
%     ok = javax.swing.JButton('OK');
%     close = javax.swing.JButton('Close');
% 
%     bottom.add(ok);
%     %rigidarea1 = javax.swing.Box.createRigidArea(java.awt.Dimension(5, 0));
% %      bottom.add(javax.swing.Box.createRigidArea(java.awt.Dimension(5, 0)));
%     bottom.add(close);
%     %rigidarea2 = javax.swing.Box.createRigidArea(java.awt.Dimension(15, 0));
% %      bottom.add(javax.swing.Box.createRigidArea(java.awt.Dimension(0, 0)));
%     GlobalData.main_tabs(3).add(bottom); %, java.awt.BorderLayout.CENTER);
%                   %rigidarea3 = javax.swing.Box.createRigidArea(java.awt.Dimension(0, 15));
%     GlobalData.main_tabs(3).add(javax.swing.Box.createRigidArea(java.awt.Dimension(0, 0)));
%     %%%%%% END TAB 3
    
    % Display the main frame
    main_panel.setVisible(1);

    hMutex = bst_mutex('get', 'gui');
    set(hMutex, 'Visible', 'off'); 
    %bst_mutex('waitfor', 'gui');
end

function main_panel = createMainPanel()
    % It create the main frame of the GUI
    
    main_panel = javax.swing.JFrame();
    main_panel.setTitle('Project');
    main_panel.setExtendedState(javax.swing.JFrame.MAXIMIZED_BOTH);
    main_panel.setSize(800,600);
    main_panel.setBackground(java.awt.Color.gray);
    
    %%% ####################  java_setcb
    hObj = handle(main_panel, 'callbackProperties');
    set(hObj, 'WindowClosingCallback', @close_window_callback);
    %%% ####################  java_setcb
    % Tested. The following also closes Matlab.
    %main_panel.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE);
end

function top_panel = createTopPanel()
    % The top panel is the panel where all of the other widgets will be
    % laid on.
    global GlobalData
    top_panel = javax.swing.JPanel();
    top_panel.setLayout(java.awt.BorderLayout);
    GlobalData.main_panel.getContentPane().add(top_panel);
end


function [tabbed_panel] = addTabbedPanel()
    % This function creates a tabbed panel object. 
    % It returns such an object.
    tabbed_panel = javax.swing.JTabbedPane();
end

function [panel] = addPanelToTabbedPanel(tabbed_panel, tab_name)
    % This function adds a tab panel to the main frame.
    % It returns the updated tabbed_panel.
    panel = javax.swing.JPanel();
    tabbed_panel.addTab(tab_name, panel);
end

function [panel, button_handle] = addButtonToPanel(panel, button_label)
    % The function adds a label to the panel with the font specified by the
    % input variable.
    button = javax.swing.JButton(button_label);
    button.setBounds(50, 50, 200, 100);
    panel.add(button);
    %set(panel,'UserData',params); 

    button_handle = handle(button,'CallbackProperties');
    set(button_handle, 'ActionPerformedCallback', @mycallbackmethod);
    %set(button_handle, 'ActionPerformedCallback', {@mycallbackmethod, param, output}); 

end

function mycallbackmethod(varargin) %parprojInfo, hNewProjDialog)
    % This is the callback method which is called when the event is raise
    % by pressing the button
    % src is the <1x1 java.awt.event.ActionEvent>
    % evd is the <1x1 javahandle_withcallbacks.javax.swing.JButton>
    
    disp('ciao');
    global GlobalData;
    GlobalData.button_test.value = 10;
end

function enterPath(varargin) %parprojInfo, hNewProjDialog)
    % This is the callback method which is called when the event is raise
    % by pressing the button
    % src is the <1x1 java.awt.event.ActionEvent>
    % evd is the <1x1 javahandle_withcallbacks.javax.swing.JButton>
    global GlobalData
    var = GlobalData.textFields.path.getText();
    disp(var);
end



% function [output] = mycallbackmethod(src, evd, param, output) %parprojInfo, hNewProjDialog)
%     % This is the callback method which is called when the event is raise
%     % by pressing the button
%     % src is the <1x1 java.awt.event.ActionEvent>
%     % evd is the <1x1 javahandle_withcallbacks.javax.swing.JButton>
%     disp('ciao')
%     output = param * param;
% end
