function eeglab_study_erp_headplot_graph(input)


set_caxis                                                                  = input.set_caxis;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
time_window_name                                                           = input.time_window_name;
plot_dir                                                                   = input.plot_dir;
erp_headplot_tw                                                            = input.erp_headplot_tw;
z_transform                                                                = input.z_transform;
file_spline                                                                = input.file_spline; % '/home/campus/behaviourPlatform/VisuoHaptic/ABBI_EEG/ABBI_EEG_st/af_AS_mc_s-s1-1sc-1tc.spl'
view_list                                                                       = input.view_list; %[0 45]




input_plot.plot_dir                                            = plot_dir;
input_plot.time_window_name                                    = time_window_name;
input_plot.name_f1                                             = name_f1;
input_plot.name_f2                                             = name_f2;
input_plot.levels_f1                                           = levels_f1;
input_plot.levels_f2                                           = levels_f2;
input_plot.erp_headplot_tw                                     = erp_headplot_tw;
input_plot.clim                                                = set_caxis;
input_plot.z_transform                                         = z_transform;
input_plot.file_spline                                         = file_spline;
input_plot.view_list                                           = view_list;






std_headplot_erp_compact(input_plot);

end
