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
 
    project.name = 'gigi';
    template_project_structure

    if exist('project', 'var')
        fill_global_data_with_template(project);
    end

    %%
    % Create the main frame and the related TABs.
    GlobalData.main_panel = createMainPanel();
    GlobalData.top_panel = createTopPanel();
    GlobalData.tabbed_panel = addTabbedPanel();
    GlobalData.top_panel.add(GlobalData.tabbed_panel);

    button_panel = addPanelToTabbedPanel(GlobalData.tabbed_panel, 'Start');
    GlobalData.tabbed_panel.addTab('Start', button_panel);

    %%%%% NEW PROJECT TAB
    % Add the button 'NEW PROJECT'
    jbutton = javax.swing.JButton('NEW PROJECT');
    button_handle = handle(jbutton,'CallbackProperties');
    set(button_handle, 'ActionPerformedCallback', @new_project);
    
    Y_AXIS = javax.swing.BoxLayout.Y_AXIS;
    boxlayout = javax.swing.BoxLayout(button_panel, Y_AXIS);
    verticalGlue = javax.swing.Box.createVerticalGlue();

    button_panel.setLayout(boxlayout);
    button_panel.add(verticalGlue);
    button_panel.add(jbutton);
    % Add later so that the content will always appear in the panel.
    button_panel.add(javax.swing.Box.createRigidArea(java.awt.Dimension(200, 400)));
    
    % Display the main frame
    GlobalData.main_panel.setVisible(1);

    hMutex = bst_mutex('get', 'gui');
    set(hMutex, 'Visible', 'off'); 
end

%%
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

%%
function top_panel = createTopPanel()
    % The top panel is the panel where all of the other widgets will be
    % laid on.
    global GlobalData
    top_panel = javax.swing.JPanel();
    top_panel.setLayout(java.awt.BorderLayout);
    GlobalData.main_panel.getContentPane().add(top_panel);
end

%%
function [tabbed_panel] = addTabbedPanel()
    % This function creates a tabbed panel object. 
    % It returns such an object.
    tabbed_panel = javax.swing.JTabbedPane();
end

%%
function [panel] = addPanelToTabbedPanel(tabbed_panel, tab_name)
    % This function adds a tab panel to the main frame.
    % It returns the updated tabbed_panel.
    panel = javax.swing.JPanel();
    tabbed_panel.addTab(tab_name, panel);
end

function new_project(varargin)
    % This is the callback method which is called when the nre project event 
    % is raised by pressing the related button.

    %% The tabbed panel can only be added to a panel not to the main frame.
    %% Panel with paths.
    global GlobalData
    % If the tab is already open send a warning to the user.
    num_open_tabs = GlobalData.tabbed_panel.getTabCount();
    if num_open_tabs > 1
        string = 'A project is already open. Do you want to close the open project?';
        %javax.swing.JOptionPane.showMessageDialog(GlobalData.main_panel, string);
        not_close_it = javax.swing.JOptionPane.showConfirmDialog(GlobalData.main_panel, string, ...
            'Warning', ...
            javax.swing.JOptionPane.YES_NO_OPTION);
        
        % if user wants to close kill all the tabs except the first one.
        if not_close_it == 0
            for i=2:num_open_tabs
                GlobalData.tabbed_panel.remove(i-1)
            end
        end
        return
    end

    get_panel_paths(GlobalData.tabbed_panel);
    % The following index is the number of the panel we would like to open
    % afer the new peoject button has been pressed.
    index = 1;
    GlobalData.tabbed_panel.setSelectedIndex(index); 
    %GlobalData.main_panel.setVisible(1);
end
