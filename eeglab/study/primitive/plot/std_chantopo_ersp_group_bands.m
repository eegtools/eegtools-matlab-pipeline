function std_chantopo_ersp_group_bands(params)

% params.dir                   = '/media/Elements/Projects/PAP/moving_scrambled_walker/results/OCICA_250c/finalizzazione3/pozzo-20141103T163729/all-ersp_topo_tw_fb_compact-errorbar-individual_align_20141103T163740';
% params.roi_list              = {'STS','Parietal','Centro-Parietal','Fronto-Central','IFG'};
% params.roi_list_labels              = {'STS','Parietal','Centro-Parietal','Fronto-Central','IFG'};
% params.band_list             = {'teta','mu','beta1','beta2'};      
% params.band_list_labels      = {'theta','mu','beta1','beta2'};      
% params.tw_name               = 'global';
% params.factor_name           = 'condition';
% params.mode                  = 'roi_rows';
% 
% 
% std_chantopo_ersp_group_bands(params)


dir                  = params.dir;
roi_list             = params.roi_list;
roi_list_labels      = params.roi_list_labels;
band_list            = params.band_list;
band_list_labels     = params.band_list_labels;
tw_name              = params.tw_name;
factor_name          = params.factor_name;
mode                 = params.mode;

% strfname = char([ name_f1, '_', name_f2]);


if strcmp(mode,'roi_rows')
    
    analysis_prefix = 'ersp_topo_tw_fb_';
    subfig_width = 375;
    merged_fig_width   = length(band_list)*subfig_width;
    merged_plot_fname = fullfile(dir,[analysis_prefix,tw_name,'_',factor_name]);
    
    tot_roi=length(roi_list);
    tot_band=length(band_list);
    
    
    for nroi = 1:tot_roi
        
        fig_list = cell(length(tot_band),1);
        plot_fname = fullfile(dir,[analysis_prefix,tw_name,'_',roi_list{nroi} ,'_',factor_name]);
        
        for nband = 1:tot_band
            subplot_name = [analysis_prefix,tw_name,'_',roi_list{nroi} ,'_',factor_name,'_',tw_name,'_',band_list{nband}];
            fig_list{nband} = fullfile(dir,[subplot_name,'.fig']);            
        end
        
        [merged_fig,merged_subfig]=figmerge(fig_list,[0 tot_band]);
        
        axes=findobj(merged_fig, 'Type', 'Axes');
        
        
        for nband = 1:tot_band
            np=tot_band-nband+1;
            title(axes(np),band_list_labels{nband})
        end
        
        suptitle(roi_list_labels{nroi})
        
        set(merged_fig,'Position',[ 1120         524 merged_fig_width 300])
        set(merged_fig,'Color','white')
        set(merged_fig, 'renderer', 'painter')
        modify_plot(merged_fig,'new_fontsize',8);
        
        
        saveas(merged_fig, [plot_fname,'.fig']);
        print([plot_fname,'.eps'],'-depsc2','-r300');
        
        
        %plot2svg([name_plot,'.svg'])
        os = system_dependent('getos');
        if ~ strncmp(os,'Linux',2)
            print(merged_fig,[merged_plot_fname,'.ps'],'-append','-dwinc')
            saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',merged_fig);
        else
            print(merged_fig,[merged_plot_fname,'.ps'],'-append','-painter','-r300')
        end
        export_fig([merged_plot_fname,'.pdf'], '-pdf', '-append')
        
        
        close(merged_fig)
    end
end

end