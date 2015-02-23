function [] = get_panel_paths(tabbed_panel)
% It displays all the function related to the panl of paths.
% The default paths are displayed but the user can choose a different path
% is he/she wants.
    global GlobalData
    
    import javax.swing.JPanel
    % The path of the icon "open folder"
    icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');

    panel = JPanel();
    tabbed_panel.addTab('paths', panel);

    % Panel boxlayout.
    % The panel will have a vertical box layout.
    border = javax.swing.BorderFactory.createEmptyBorder(5, 5, 5, 5);
    panel.setBorder(border);
    % GridLayout(rows, cols, x_border, y_border)
    num_fiels = length(fieldnames(GlobalData.project.paths));
    grid = java.awt.GridLayout(num_fiels, 3, 10, 10);
    panel.setLayout(grid);

    %% Set project path widgets.
    tooltip_text = 'B9:   folder containing data, epochs, results etc...(not scripts)';
    panel = add_path_project_widgets(panel, icon_folder_path, tooltip_text);
    %% Set the original data path
    tooltip_text = 'B10:  folder containing EEG raw data (BDF, vhdr, eeg, etc...)';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B11:  folder containing EEGLAB EEG input epochs set files';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B12:  folder containing EEGLAB EEG output condition epochs set files';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B13:  folder containing statistical results';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B14:  folder containing EEGLAB EMG epochs set files';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B15:  folder containing EMG data strucuture';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B16:  folder containing ';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B17:  folder containing ';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B18:  folder containing bash batches (usually for SPM analysis)';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B19:  folder containing sources images exported by brainstorm';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B20:  folder containing spm stat files';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B21:  folder containing spm toolbox';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B22:  folder containing eeglab toolbox';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    tooltip_text = 'B23:  folder containing brainstorm toolbox';
    panel = add_path_original_data_widgets(panel, icon_folder_path, tooltip_text);
    
    GlobalData.top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
    GlobalData.main_tabs.paths = panel;

end

function panel = add_path_project_widgets(panel, icon_folder_path, label_tooltip_text)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global GlobalData

    % LABEL
    label = getLabel('Project path: ');
    label.setToolTipText(label_tooltip_text);
    
    % TEXT FIELD
    GlobalData.textFields.project.path.project = javax.swing.JTextField(...
                        GlobalData.project.paths.project, 50);

    %BUTTON WITH ICON
    %With the button the user can choose a different folder.
    icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');
    button = getButtonWithIcon(icon_folder_path, 0.25, 'ActionPerformedCallback', @searchProjectPath);
    button.setToolTipText('Choose the path');
    panel.add(label);
    panel.add(GlobalData.textFields.project.path.project);
    panel.add(button);   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function panel = add_path_original(panel, label_string, icon_folder_path, label_tooltip_text)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global GlobalData

    % LABEL
    label = getLabel(label_string);
    label.setToolTipText(label_tooltip_text);
    
    % TEXT FIELD
    GlobalData.textFields.project.paths.original_data = javax.swing.JTextField(...
                        GlobalData.project.paths.original_data, 50);

    %BUTTON WITH ICON
    %With the button the user can choose a different folder.
    icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');
    button = getButtonWithIcon(icon_folder_path, 0.25, 'ActionPerformedCallback', @searchOriginalDataPath);
    button.setToolTipText('Choose the path');
    panel.add(label);
    panel.add(GlobalData.textFields.project.paths.original_data);
    
    panel.add(button);   
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function panel = add_path_original_data_widgets(panel, icon_folder_path, label_tooltip_text)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global GlobalData

    % LABEL
    label = getLabel('Original Data: ');
    label.setToolTipText(label_tooltip_text);
    
    % TEXT FIELD
    GlobalData.textFields.project.paths.original_data = javax.swing.JTextField(...
                        GlobalData.project.paths.original_data, 50);

    %BUTTON WITH ICON
    %With the button the user can choose a different folder.
    icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');
    button = getButtonWithIcon(icon_folder_path, 0.25, 'ActionPerformedCallback', @searchOriginalDataPath);
    button.setToolTipText('Choose the path');
    panel.add(label);
    panel.add(GlobalData.textFields.project.paths.original_data);
    
    panel.add(button);   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function searchProjectPath(varargin)
    global GlobalData
    GlobalData.project.paths.project = uigetdir('c:\', 'Please select the path');  % String
    GlobalData.textFields.project.path.project.setText(GlobalData.project.paths.project);  % widget
    disp(GlobalData.project.paths.project)
end

function searchOriginalDataPath(varargin)
    global GlobalData
    GlobalData.project.paths.original_data = uigetdir('c:\', 'Please select the path');
    GlobalData.textFields.project.path.original_data.setText(GlobalData.project.paths.original_data);
    disp(GlobalData.project.paths.original_data)
end
