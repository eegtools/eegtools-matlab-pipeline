function [] = get_panel_paths(tabbed_panel)
% It displays all the function related to the panl of paths.
% The default paths are displayed but the user can choose a different path
% is he/she wants.
    global GlobalData
    
    import javax.swing.JPanel
    % The path of the icon "open folder"
    %icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');

    panel = JPanel();
    tabbed_panel.addTab('input paths', panel);

    % Panel boxlayout.
    % The panel will have a vertical box layout.
    border = javax.swing.BorderFactory.createEmptyBorder(5, 5, 5, 5);
    panel.setBorder(border);
    % GridLayout(rows, cols, x_border, y_border)
    num_fiels = length(fieldnames(GlobalData.project.paths));
    grid = java.awt.GridLayout(num_fiels, 3, 10, 10);
    panel.setLayout(grid);

    %% Set project path widgets.
    label = 'Project';
    label_tooltip = 'B9: folder containing data, epochs, results etc...(not scripts)';
    [panel, GlobalData.textFields.project.paths.project] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.project, {@searchPath, label});
        
    label = 'Original data';
    label_tooltip = 'B10: folder containing EEG raw data (BDF, vhdr, eeg, etc...)';
    [panel, GlobalData.textFields.project.paths.original_data] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.original_data, {@searchPath, label});

    label = 'Input epochs';
    label_tooltip = 'B11: folder containing EEGLAB EEG input epochs set files';
    [panel, GlobalData.textFields.project.paths.input_epochs] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.input_epochs, {@searchPath, label});

    label = 'Output epochs';
    label_tooltip = 'B12: folder containing EEGLAB EEG output condition epochs set files';
    [panel, GlobalData.textFields.project.paths.output_epochs] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.output_epochs, {@searchPath, label});

    label = 'Results';
    label_tooltip = 'B13: folder containing statistical results';
    [panel, GlobalData.textFields.project.paths.results] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.results, {@searchPath, label});

    label = 'Emg epochs';
    label_tooltip = 'B14: folder containing EEGLAB EMG epochs set files';
    [panel, GlobalData.textFields.project.paths.emg_epochs] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.emg_epochs, {@searchPath, label});
        
    label = 'Emg epochs mat';
    label_tooltip = 'B15: folder containing EMG data strucuture';
    [panel, GlobalData.textFields.project.paths.emg_epochs_mat] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.emg_epochs_mat, {@searchPath, label});
        
    label = 'TF';
    label_tooltip = 'B16: folder containing ';
    [panel, GlobalData.textFields.project.paths.tf] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.tf, {@searchPath, label});

    label = 'Cluster projection erp';
    label_tooltip = 'B17: folder containing ';
    [panel, GlobalData.textFields.project.paths.cluster_projection_erp] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.cluster_projection_erp, {@searchPath, label});

    label = 'Batches';
    label_tooltip = 'B18: folder containing bash batches (usually for SPM analysis)';
    [panel, GlobalData.textFields.project.paths.batches] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.batches, {@searchPath, label});
        
    label = 'Spmsources';
    label_tooltip = 'B19:  folder containing sources images exported by brainstorm';
    [panel, GlobalData.textFields.project.paths.spmsources] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.spmsources, {@searchPath, label});
       
    label = 'Spmstats';
    label_tooltip = 'B20:  folder containing spm stat files';
    [panel, GlobalData.textFields.project.paths.spmstats] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.spmstats, {@searchPath, label});
            
    label = 'Spm';
    label_tooltip = 'B21:  folder containing spm toolbox';
    [panel, GlobalData.textFields.project.paths.spm] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.spm, {@searchPath, label});
               
    label = 'Eeglab';
    label_tooltip = 'B22:  folder containing eeglab toolbox';
    [panel, GlobalData.textFields.project.paths.eeglab] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.eeglab, {@searchPath, label});
               
    label = 'Brainstorm';
    label_tooltip = 'B23:  folder containing brainstorm toolbox';
    [panel, GlobalData.textFields.project.paths.brainstorm] = ...
    add_path_widget(panel, label, label_tooltip, ...
            GlobalData.project.paths.brainstorm, {@searchPath, label});
    
    GlobalData.top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
    GlobalData.main_tabs.paths = panel;

end

function [panel, path_text_field]  = add_path_widget(panel, label_txt, label_tooltip_text, path_data, function_handle)
    global GlobalData

    % LABEL
    label_string = strcat(label_txt, ' path:');
    label = getLabel(label_string);
    label.setToolTipText(label_tooltip_text);
    
    % TEXT FIELD
    path_text_field = javax.swing.JTextField(path_data, 50);

    %BUTTON WITH ICON
    %With the button the user can choose a different folder.
    icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');
    button = getButtonWithIcon(icon_folder_path, 0.25, 'ActionPerformedCallback', function_handle);
    button.setToolTipText('Choose the path');
    panel.add(label);
    panel.add(path_text_field);
    
    panel.add(button); 
    
end

function [dir] = searchPath(varargin)
    dir = uigetdir('c:\', 'Please select the path');
    global GlobalData
    
    if nargin == 3 % the 3rd argument is the path_type.
        path_type = varargin{3};
        
        switch path_type
            case 'Project'
                GlobalData.textFields.project.paths.project.setText(dir);
                GlobalData.project.paths.project = dir;
            case 'Original data'
                GlobalData.textFields.project.paths.original_data.setText(dir);
                GlobalData.project.paths.original_data = dir;
            case 'Input epochs'
                GlobalData.textFields.project.paths.input_epochs.setText(dir);
                GlobalData.project.paths.input_epochs = dir;
            case 'Output epochs'
                GlobalData.textFields.project.paths.output_epochs.setText(dir);
                GlobalData.project.paths.output_epochs = dir;
            case 'Results'
                GlobalData.textFields.project.paths.results.setText(dir);
                GlobalData.project.paths.results = dir;                
            case 'Emg epochs'
                GlobalData.textFields.project.paths.emg_epochs.setText(dir);
                GlobalData.project.paths.emg_epochs = dir;                
            case 'Emg epochs mat'
                GlobalData.textFields.project.paths.emg_epochs_mat.setText(dir);
                GlobalData.project.paths.emg_epochs_mat = dir;                
            case 'TF'
                GlobalData.textFields.project.paths.tf.setText(dir);
                GlobalData.project.paths.tf = dir;                
            case 'Cluster projection erp'
                GlobalData.textFields.project.paths.cluster_projection_erp.setText(dir);
                GlobalData.project.paths.cluster_projection_erp = dir;                
            case 'Batches'
                GlobalData.textFields.project.paths.batches.setText(dir);
                GlobalData.project.paths.batches = dir;                
            case 'Spmsources'
                GlobalData.textFields.project.paths.spmsources.setText(dir);
                GlobalData.project.paths.spmsources = dir;                
            case 'Spmstats'
                GlobalData.textFields.project.paths.spmstats.setText(dir);
                GlobalData.project.paths.spmstats = dir;                
            case 'Spm'
                GlobalData.textFields.project.paths.spm.setText(dir);
                GlobalData.project.paths.spm = dir;                
            case 'Eeglab'
                GlobalData.textFields.project.paths.eeglab.setText(dir);
                GlobalData.project.paths.eeglab = dir;                
            case 'Brainstorm'
                GlobalData.textFields.project.paths.brainstorm.setText(dir);
                GlobalData.project.paths.brainstorm = dir;                
        end
    end
end

