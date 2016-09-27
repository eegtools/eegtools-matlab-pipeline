function startProcess(analysis, action_name, varargin)


    switch action_name
        case 'do_study_plot_roi_erp_curve_tw_individual_noalign'
            proj_eeglab_study_plot_roi_erp_curve(analysis, analysis.name, analysis.erp.dataprocess.mode.tw_individual_noalign);
        case 'do_study_plot_roi_erp_curve_tw_individual_align'
            proj_eeglab_study_plot_roi_erp_curve(analysis, analysis.name, analysis.erp.dataprocess.mode.tw_individual_align);
                
    end
end
