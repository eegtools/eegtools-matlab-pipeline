function [] = display_panel_paths(tabbed_panel)
% It displays, as labels, the paths of the project.
%
    global GlobalData

    import javax.swing.JPanel
    import javax.swing.BorderFactory
    import javax.swing.border.EtchedBorder

    % The path of the icon "open folder"
    %icon_folder_path = strcat(GlobalData.path_icons, 'iconFolderOpen.jpg');

    panel = JPanel();
    panel_paths = JPanel();

%     Y_AXIS = javax.swing.BoxLayout.Y_AXIS;
%     boxlayout = javax.swing.BoxLayout(panel, Y_AXIS);
%     verticalGlue = javax.swing.Box.createVerticalGlue();
%     panel.setLayout(boxlayout);
%     panel.add(verticalGlue);    

    panel.add(panel_paths);
    tabbed_panel.addTab('paths', panel);
    GlobalData.top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
    
    % Panel boxlayout.
    % The panel will have a vertical box layout.
    border = javax.swing.BorderFactory.createEmptyBorder(5, 5, 5, 5);
    panel_paths.setBorder(border);
    % GridLayout(rows, cols, x_border, y_border)
    num_fiels = length(fieldnames(GlobalData.project.paths));
    grid = java.awt.GridLayout(num_fiels, 1, 5, 5);
    panel_paths.setLayout(grid);
    panel.add(javax.swing.Box.createRigidArea(java.awt.Dimension(1100, 400)));
    
    titled_border = BorderFactory.createTitledBorder(...
        BorderFactory.createEtchedBorder(EtchedBorder.RAISED), ...
        'paths');
    panel_paths.setBorder(titled_border);

    %%
    %%%%%%%%%%%%%%%%%%
    %% Set project path widgets.
    label = 'Project';
    label_tooltip = 'B9: folder containing data, epochs, results etc...(not scripts)';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.project);
        
    label = 'Original data';
    label_tooltip = 'B10: folder containing EEG raw data (BDF, vhdr, eeg, etc...)';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.original_data);

    label = 'Input epochs';
    label_tooltip = 'B11: folder containing EEGLAB EEG input epochs set files';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.input_epochs);

    label = 'Output epochs';
    label_tooltip = 'B12: folder containing EEGLAB EEG output condition epochs set files';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.output_epochs);

    label = 'Results';
    label_tooltip = 'B13: folder containing statistical results';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.results);

    label = 'Emg epochs';
    label_tooltip = 'B14: folder containing EEGLAB EMG epochs set files';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.emg_epochs);
        
    label = 'Emg epochs mat';
    label_tooltip = 'B15: folder containing EMG data strucuture';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.emg_epochs_mat);
        
    label = 'TF';
    label_tooltip = 'B16: folder containing ';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.tf);

    label = 'Cluster projection erp';
    label_tooltip = 'B17: folder containing ';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.cluster_projection_erp);

    label = 'Batches';
    label_tooltip = 'B18: folder containing bash batches (usually for SPM analysis)';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.batches);
        
    label = 'Spm sources';
    label_tooltip = 'B19:  folder containing sources images exported by brainstorm';
     add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.spmsources);
       
    label = 'Spm stats';
    label_tooltip = 'B20:  folder containing spm stat files';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.spmstats);
            
    label = 'Spm';
    label_tooltip = 'B21:  folder containing spm toolbox';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.spm);
               
    label = 'Eeglab';
    label_tooltip = 'B22:  folder containing eeglab toolbox';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.eeglab);

    label = 'Brainstorm';
    label_tooltip = 'B23:  folder containing brainstorm toolbox';
    add_path_label(panel_paths, label, label_tooltip, GlobalData.project.paths.brainstorm);
    
    GlobalData.top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
 %   GlobalData.main_tabs.paths = panel_paths;

end

%function [panel, path_text_field]  = add_path_widget(panel, label_txt, label_tooltip_text, path_data, function_handle)
function add_path_label(panel, label_txt, label_tooltip_text, path_data)
    % LABEL
    label_string = strcat(label_txt, ' path: ', path_data);
    label = getLabel(label_string);
    label.setToolTipText(label_tooltip_text);
    panel.add(label);
 end
