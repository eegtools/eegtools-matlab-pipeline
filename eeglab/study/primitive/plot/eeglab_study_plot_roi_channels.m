%% function [STUDY, EEG] = eeglab_study_plot_roi_channels(project,mode,plotted_roi_names,plot_dir)
% given a list of rois, plot the topographical distribution (in red) of the channels in each roi. 
function [STUDY, EEG] = eeglab_study_plot_roi_channels(project,mode,plotted_roi_names,plot_dir)

   if nargin < 4
        help eeglab_study_plot_roi_channels;
        return;    
   end;

    if strcmp(mode,'ERP')
       roi_list=project.postprocess.erp.roi_list;
       roi_names=project.postprocess.erp.roi_names;
    elseif strcmp(mode,'ERSP')
       roi_list=project.postprocess.ersp.roi_list;
       roi_names=project.postprocess.ersp.roi_names;
    else
        display('ERROR: select ERP or ERSP mode');
    end
    
    study_path                  = fullfile(project.paths.output_epochs, project.study.filename);
    
    if isempty(plotted_roi_names)   
        plotted_roi_list=roi_list;
        plotted_roi_names=roi_names;       
   end
    
     %% =================================================================================================================================================================
    [study_path,study_name_noext,study_ext] = fileparts(study_path);
    
    %% start EEGLab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    %% load the study and working with the study structure
    [STUDY ALLEEG] = pop_loadstudy( 'filename',[study_name_noext study_ext],'filepath',study_path);
    
    all_channels={STUDY.changrp.name};
    chanlocs=ALLEEG(1).chanlocs;
    
    vec_roi=find(ismember(roi_names,plotted_roi_names));
    
    for nroi = vec_roi
        roi_channels=roi_list{nroi};
        roi_name=roi_names{nroi};        
        name_plot=roi_name;          
        sel_chan=ismember(all_channels,roi_channels);
        figure();
        topoplot(sel_chan,chanlocs,'style','blank');
        print(fullfile(plot_dir,[name_plot,'.eps']),'-depsc2','-r300');
        plot2svg(fullfile(plot_dir,[name_plot,'.svg']));
    end
    

end