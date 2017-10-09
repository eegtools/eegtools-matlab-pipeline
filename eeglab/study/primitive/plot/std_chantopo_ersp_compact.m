function std_chantopo_ersp_compact(ersp_topo_tw_fb_sub_avg, ersp_topo_tw_fb_roi_avg, ... rispettivamente: per ogni soggetto, la media di ogni canale; per ogni soggetto, la media di tutti i canali nella roi 
                                   plot_dir, roi_name, ...
                                   chanlocs,set_caxis,...
                                   time_window_name, time_window, ...
                                   frequency_band_name, ...
                                   name_f1, name_f2, levels_f1,levels_f2,... 
                                   pgroup,  pcond, study_ls, ...
                                   roi_mask, compcond, compgroup, ersp_measure)

%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');




             strfname = char([ name_f1, '_', name_f2]);
                  
    switch ersp_measure     
     case 'dB'
         ersp_meaure='dB';
     case 'Pfu'
         ersp_meaure='Delta %';     
    end                        
                               
    colbk='white';
      

    % total levels of factor 1 (e.g conditions) and 2 (e.g groups)     
    [tlf1 tlf2]=size(ersp_topo_tw_fb_sub_avg);

    if tlf1 >1
       levels_f=levels_f1;
        for nl=1:length(levels_f)
            tlf=levels_f{nl};   
            if iscell(tlf)    
                str=tlf{1};
                for nls=2:length(tlf)
                    str=[str,'-' ,tlf{nls}];       
                end
            else
                str=tlf;       
            end
            merged_levels{nl}=str;
        end
        levels_f1=merged_levels;    
    end

    if tlf2 >1
       levels_f=levels_f2;
        for nl=1:length(levels_f)
            tlf=levels_f{nl};   
            if iscell(tlf)    
                str=tlf{1};
                for nls=2:length(tlf)
                    str=[str,'-' ,tlf{nls}];       
                end
            else
                str=tlf;       
            end
            merged_levels{nl}=str;
        end
        levels_f2=merged_levels;    
    end



    
    
    
    
    if tlf1 < 2 || tlf2 < 2
          
        tlf=max(tlf1,tlf2);
        
        if tlf2>1 % only one row (condition), compare columns (groups)
                pcomp=pgroup; % pgroup has for each condition (row), the comparison between groups (columns)  
                levels_f=levels_f2;
                name_f=name_f2;
                comp=compgroup;                
        end
        if tlf1>1 % only one column (group), compare rows (conditions)
                pcomp=pcond; % pcond has for each group (column), the comparison between conditions (rows)
                levels_f=levels_f1;
                name_f=name_f1;
                comp=compcond;               
        end
        comparisons=comp{1};
        pcomparisons=pcomp{1};
     
        
        mat_topo=[];
        mat_box=[];
        
        for nlf=1:tlf             
            mat_topo(:,nlf)=ersp_topo_tw_fb_sub_avg{nlf};
            mat_box(:,nlf)=ersp_topo_tw_fb_roi_avg{nlf};
        end
        
        range_topo=[ min(min(mat_topo)) max(max(mat_topo))];        
        extr_topo=max(abs(range_topo));
        
        if isempty(set_caxis)
            set_caxis=[-extr_topo, extr_topo];  
        end
        
                
        tot_topo=size(mat_topo,2); % number of topo plots
        tot_row=3; % leave one row for the topo plots and two for the boxplot        
        xlab=name_f;
        ylab=ersp_meaure;
        
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec = pcomparisons < study_ls;        
        signif_pairs = comparisons(:,signif_vec);        
        x_boxs=1:tot_topo;
        
        % create figure
        fig=figure( 'color', 'w', 'Visible', 'off');
        
        % create topo plots
        for ntopo = 1:tot_topo
            subplot(tot_row,tot_topo,ntopo);
            topoplot(mat_topo(:,ntopo).*roi_mask',chanlocs,'whitebk','on');
            caxis(set_caxis);
            set(gca,'color',colbk);
            set(gca,'FontSize',14)
            title(levels_f{ntopo});     
        end
        cbar;title(ylab,'FontSize',14)

        subplot(tot_row,tot_topo,(tot_topo+1:(tot_topo*tot_row)))
        set(gca, 'LineWidth', 1.2)
        
        aboxplot_raw(mat_box,'plot_raw','on');
        set(gca,'XTickLabel',levels_f)
        set(gca,'FontSize',14)
        
        xlabel(xlab)
        ylabel(ylab)

        hold on

        range_box=[max(max(mat_box)) min(min(mat_box))];
        deltay=abs(diff(range_box))/4;
        
        if ~ isempty(signif_pairs)    
            yval_min=min(min(mat_box))-3*deltay;
            yval_max=max(max(mat_box))+1.1*deltay*(size(signif_pairs,2)+3)    ;
            ylim([yval_min yval_max]);

            for i  = 1:size(signif_pairs,2)
                offset_segment=max(max(mat_box))+(2+i)*deltay;
                offset_star=offset_segment+deltay*0.2;        
                plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(1,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                plot([x_boxs(signif_pairs(2,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                text(mean([x_boxs(signif_pairs(2,i)),x_boxs(signif_pairs(1,i))]), offset_star,'*','FontSize',15,'LineWidth',2)
            end
        end
       
        set(gcf,'color',colbk)
        hold off        
        suptitle({[frequency_band_name, ' ERSP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });             
    
        
%          set(fig, 'paperpositionmode', 'auto');
% setfont(fig, 'fontsize', 16);
%          
%          name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)]);
%         saveas(fig, [name_plot,'.fig']);
%         saveas(fig,[name_plot,'.eps'],'epsc');
%         plot2svg([name_plot,'.svg']) 
%          
%          
%          os = system_dependent('getos');
%          if ~ strncmp(os,'Linux',2) 
%             print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append','-dwinc')
%            saveppt2(fullfile(plot_dir,'ersp_topo_tw_fb.ppt'),'f',fig);
%          else
%             print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append')
%          end
%          ps2pdf('psfile',fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_topo_tw_fb.pdf'))
% %          file_tiff=['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name),'.tif'];
% %          print(fig,fullfile(plot_dir,file_tiff),'-dtiff')


% name_embed=fullfile(plot_dir,'ersp_topo_tw_fb'); 
% name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)];
% set(fig, 'renderer', 'painter')
% modify_plot(fig)
% saveas(fig, [name_plot,'.fig']);
% print([name_plot,'.eps'],'-depsc2','-r300');
% plot2svg([name_plot,'.svg'])
% os = system_dependent('getos');
% if ~ strncmp(os,'Linux',2) 
%     print(fig,[name_embed,'.ps'],'-append','-dwinc')
%     saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);   
% else
%     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
% end
% export_fig([name_embed,'.pdf'], '-pdf', '-append')
% 
% 
%          close(fig)

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','ersp_topo_tw_fb'];
input_save_fig.suffix_plot            = [char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )
    
    end
    
    
    if tlf1 > 1 && tlf2 > 1 
        tlf_within=tlf1; % fix the row (condition) and tlf_within2>1 (compare columns, i.e. groups)         
        tlf_between=tlf2;
        for nlf_within=1:tlf_within
            pcomp=pgroup(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
            levels_f=levels_f2;
            name_f=name_f2;
            name_ff=levels_f1{nlf_within};
            comp=compgroup(nlf_within);                         
            comparisons=comp{1};
            pcomparisons=pcomp{1};
            
           
            
            mat_topo=[];
            mat_box=[];
            for nlf_between=1:tlf_between             
                mat_topo(:,nlf_between)=ersp_topo_tw_fb_sub_avg{nlf_within,nlf_between};
                mat_box(:,nlf_between)=ersp_topo_tw_fb_roi_avg{nlf_within,nlf_between};
            end        
            range_topo=[min(min(mat_topo)) max(max(mat_topo))];        
            extr_topo=max(abs(range_topo));
            if isempty(set_caxis)
                set_caxis=[-extr_topo, extr_topo];  
            end
            tot_topo=size(mat_topo,2); % number of topo plots
            tot_row=3; % leave one row for the topo plots and two for the boxplot        
            xlab=name_f;
            ylab=ersp_meaure;
            %comparisons = combn_all(1:tot_topo,2);
            num_comparisons = size(comparisons,2);
            signif_vec = pcomparisons < study_ls;        
            signif_pairs = comparisons(:,signif_vec);                
            x_boxs=1:tot_topo;
            % create figure
             fig=figure( 'color', 'w', 'Visible', 'off');
            % create topo plots
            for ntopo = 1:tot_topo
                subplot(tot_row,tot_topo,ntopo);
                topoplot(mat_topo(:,ntopo).*roi_mask',chanlocs,'whitebk','on');
                caxis(set_caxis);
                set(gca,'color',colbk);
                set(gca,'FontSize',14)
                title(levels_f{ntopo});     
            end
            cbar;title(ylab,'FontSize',14)

            subplot(tot_row,tot_topo,(tot_topo+1:(tot_topo*tot_row)))
            set(gca, 'LineWidth', 1.2)

            aboxplot_raw(mat_box,'plot_raw','on');
            set(gca,'XTickLabel',levels_f)
            set(gca,'FontSize',14)

            xlabel(xlab)
            ylabel(ylab)

            hold on

            range_box=[max(max(mat_box)) min(min(mat_box))];
            deltay=abs(diff(range_box))/4;

            if ~ isempty(signif_pairs)    
                yval_min=min(min(mat_box))-3*deltay;
                yval_max=max(max(mat_box))+1.1*deltay*(size(signif_pairs,2)+3)    ;
                ylim([yval_min yval_max]);

                for i  = 1:size(signif_pairs,2)
                    offset_segment=max(max(mat_box))+(2+i)*deltay;
                    offset_star=offset_segment+deltay*0.2;   
                    plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                    plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(1,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                    plot([x_boxs(signif_pairs(2,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                    text(mean([x_boxs(signif_pairs(2,i)),x_boxs(signif_pairs(1,i))]), offset_star,'*','FontSize',15,'LineWidth',2)
                end
            end

            set(gcf,'color',colbk)
            hold off        
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});    
        
            
%              set(fig, 'paperpositionmode', 'auto');
% setfont(fig, 'fontsize', 16);
%              
%              name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)]);
%         saveas(fig, [name_plot,'.fig']);
%         saveas(fig,[name_plot,'.eps'],'epsc');
%         plot2svg([name_plot,'.svg']) 
%              
%              
%              os = system_dependent('getos');
%              if ~ strncmp(os,'Linux',2) 
%                 print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append','-dwinc')
%                saveppt2(fullfile(plot_dir,'ersp_topo_tw_fb.ppt'),'f',fig);
%              else
%                 print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append')
%              end
%              ps2pdf('psfile',fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_topo_tw_fb.pdf'))
% %              file_tiff=['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name),'.tif'];
% %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')

% name_embed=fullfile(plot_dir,'ersp_topo_tw_fb'); 
% name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];
% set(fig, 'renderer', 'painter')
% modify_plot(fig)
% saveas(fig, [name_plot,'.fig']);
% print([name_plot,'.eps'],'-depsc2','-r300');
% plot2svg([name_plot,'.svg'])
% os = system_dependent('getos');
% if ~ strncmp(os,'Linux',2) 
%     print(fig,[name_embed,'.ps'],'-append','-dwinc')
%     saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);   
% else
%     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
% end
% export_fig([name_embed,'.pdf'], '-pdf', '-append')
% 
%              close(fig)

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','ersp_topo_tw_fb'];
input_save_fig.suffix_plot            = [char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )
        
        end

        
        tlf_within=tlf2; % fix the column (group) and tlf_within2>1 (compare rows, i.e. conditions)         
        tlf_between=tlf1;
        for nlf_within=1:tlf_within
            pcomp=pgroup(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
            levels_f=levels_f1;            
            name_f=name_f1;
            name_ff=levels_f2{nlf_within};
            comp=compgroup(nlf_within);                         
            comparisons=comp{1};
            pcomparisons=pcomp{1};
            
            mat_topo=[];
            mat_box=[];
            for nlf_between=1:tlf_between             
                mat_topo(:,nlf_between)=ersp_topo_tw_fb_sub_avg{nlf_between,nlf_within};
                mat_box(:,nlf_between)=ersp_topo_tw_fb_roi_avg{nlf_between,nlf_within};
            end        
            range_topo=[min(min(mat_topo)) max(max(mat_topo))];        
            extr_topo=max(abs(range_topo));
            if isempty(set_caxis)
                set_caxis=[-extr_topo, extr_topo];  
            end
            tot_topo=size(mat_topo,2); % number of topo plots
            tot_row=3; % leave one row for the topo plots and two for the boxplot        
            xlab=name_f;
            ylab=ersp_meaure;
            %comparisons = combn_all(1:tot_topo,2);
            num_comparisons = size(comparisons,2);
            signif_vec = pcomparisons < study_ls;        
            signif_pairs = comparisons(:,signif_vec);        
            x_boxs=1:tot_topo;
            % create figure
             fig=figure( 'color', 'w', 'Visible', 'off');
            % create topo plots
            for ntopo = 1:tot_topo
                subplot(tot_row,tot_topo,ntopo);
                topoplot(mat_topo(:,ntopo).*roi_mask',chanlocs,'whitebk','on');
                caxis(set_caxis);
                set(gca,'color',colbk);
                set(gca,'FontSize',14)
                title(levels_f{ntopo});     
            end
            cbar;title(ylab,'FontSize',14)

            subplot(tot_row,tot_topo,(tot_topo+1:(tot_topo*tot_row)))
            set(gca, 'LineWidth', 1.2)
            
            
            aboxplot_raw(mat_box,'plot_raw','on');
            set(gca,'XTickLabel',levels_f)
            set(gca,'FontSize',14)

            xlabel(xlab)
            ylabel(ylab)

            hold on

            range_box=[max(max(mat_box)) min(min(mat_box))];
            deltay=abs(diff(range_box))/4;

            if ~ isempty(signif_pairs)    
                yval_min=min(min(mat_box))-3*deltay;
                yval_max=max(max(mat_box))+1.1*deltay*(size(signif_pairs,2)+3)    ;
                ylim([yval_min yval_max]);
            
                
                
                for i  = 1:size(signif_pairs,2)
                    offset_segment=max(max(mat_box))+(2+i)*deltay;
                    offset_star=offset_segment+deltay*0.2;        
                    plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                    plot([x_boxs(signif_pairs(1,i)) x_boxs(signif_pairs(1,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                    plot([x_boxs(signif_pairs(2,i)) x_boxs(signif_pairs(2,i))], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                    text(mean([x_boxs(signif_pairs(2,i)),x_boxs(signif_pairs(1,i))]), offset_star,'*','FontSize',15,'LineWidth',2)
                end
            end

            set(gcf,'color',colbk)
            hold off        
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});      
        
            
%              set(fig, 'paperpositionmode', 'auto');
% setfont(fig, 'fontsize', 16);
%              
%               name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)]);
%         saveas(fig, [name_plot,'.fig']);
%         saveas(fig,[name_plot,'.eps'],'epsc');
%         plot2svg([name_plot,'.svg']) 
%              
%              os = system_dependent('getos');
%              if ~ strncmp(os,'Linux',2) 
%                 print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append','-dwinc')
%                saveppt2(fullfile(plot_dir,'ersp_topo_tw_fb.ppt'),'f',fig);
%              else
%                 print(fig,fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'-append')
%              end
%              ps2pdf('psfile',fullfile(plot_dir,'ersp_topo_tw_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_topo_tw_fb.pdf'))
% %              file_tiff=['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name),'.tif'];
% %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')


% name_embed=fullfile(plot_dir,'ersp_topo_tw_fb'); 
% name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];
% set(fig, 'renderer', 'painter')
% modify_plot(fig)
% saveas(fig, [name_plot,'.fig']);
% print([name_plot,'.eps'],'-depsc2','-r300');
% plot2svg([name_plot,'.svg'])
% os = system_dependent('getos');
% if ~ strncmp(os,'Linux',2) 
%     print(fig,[name_embed,'.ps'],'-append','-dwinc')
%     saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);   
% else
%     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
% end
% export_fig([name_embed,'.pdf'], '-pdf', '-append')
% 
%              close(fig)
         
input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','ersp_topo_tw_fb'];
input_save_fig.suffix_plot            = [char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )        
        
        end

        
        
        
         
    end
end
