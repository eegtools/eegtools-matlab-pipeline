function [] = constant_strings()
%CONSTANT_STRINGS Summary of this function goes here
%   Detailed explanation goes here

    label_project_path = 'Project';
    label_project_path_tooltip = 'B9: folder containing data, epochs, results etc...(not scripts)';

    label_original_data_path = 'Original data';
    label_original_data_path_tooltip = 'B10: folder containing EEG raw data (BDF, vhdr, eeg, etc...)';

    label_input_epochs_path = 'Input epochs';
    label_input_epochs_path_tooltip = 'B11: folder containing EEGLAB EEG input epochs set files';

    label_output_epochs_path = 'Output epochs';
    label_output_epochs_path_tooltip = 'B12: folder containing EEGLAB EEG output condition epochs set files';

    label_results_path = 'Results';
    label_results_path_tooltip = 'B13: folder containing statistical results';

    label_emg_epochs_path = 'Emg epochs';
    label_emg_epochs_path_tooltip = 'B14: folder containing EEGLAB EMG epochs set files';
        
    label_emg_epochs_mat_path = 'Emg epochs mat';
    label_emg_epochs_mat_path_tooltip = 'B15: folder containing EMG data strucuture';
        
    label_tf_path = 'TF';
    label_tf_path_tooltip = 'B16: folder containing ';

    label_cluster_proj_erp_path = 'Cluster projection erp';
    label_cluster_proj_erp_path_tooltip = 'B17: folder containing ';

    label_batches_path = 'Batches';
    label_batches_path_tooltip = 'B18: folder containing bash batches (usually for SPM analysis)';
        
    label_spmsources_path = 'Spmsources';
    label_spmsources_path_tooltip = 'B19:  folder containing sources images exported by brainstorm';
       
    label_spmstats_path = 'Spmstats';
    label_spmstats_path_tooltip = 'B20:  folder containing spm stat files';
            
    label_spm_path = 'Spm';
    label_spm_path_tooltip = 'B21:  folder containing spm toolbox';
               
    label_eeglab_path = 'Eeglab';
    label_eeglab_path_tooltip = 'B22:  folder containing eeglab toolbox';
               
    label_brainstorm_path = 'Brainstorm';
    label_brainstorm_path _tooltip = 'B23:  folder containing brainstorm toolbox';

end

