function std_chantopo_ersp_compact_boxplot(input)

                                       
ersp_topo_tw_fb_roi_avg                                                    = input.ersp_topo_tw_fb_roi_avg;
plot_dir                                                                   = input.plot_dir;
roi_name                                                                   = input.roi_name;
chanlocs                                                                   = input.chanlocs;
time_window_name                                                           = input.time_window_name;
time_window                                                                = input.time_window;
frequency_band_name                                                        = input.frequency_band_name;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pgroup                                                                     = input.pgroup;
pcond                                                                      = input.pcond;
study_ls                                                                   = input.study_ls;
roi_mask                                                                   = input.roi_mask;
compcond                                                                   = input.compcond;
compgroup                                                                  = input.compgroup;
ersp_measure                                                               = input.ersp_measure;
show_head                                                                  = input.show_head;
compact_display_ylim                                                       = input.compact_display_ylim;
show_text                                                                  = input.show_text;                                 



strfname = char([ name_f1, '_', name_f2]);

                                       
%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');





switch ersp_measure
    case 'dB'
        ersp_meaure='dB';
    case 'Pfu'
        ersp_meaure='Delta %';
end

colbk='white';


% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(ersp_topo_tw_fb_roi_avg);

if tlf1 >1
    levels_f=levels_f1;
    for nl=1:length(levels_f)
        level_f=levels_f{nl};
        if iscell(level_f)
            str=level_f{1};
            for nls=2:length(level_f)
                str=[str,'-' ,level_f{nls}];
            end
        else
            str=level_f;
        end
        merged_levels{nl}=str;
    end
    levels_f1=merged_levels;
end

if tlf2 >1
    levels_f=levels_f2;
    for nl=1:length(levels_f)
        level_f=levels_f{nl};
        if iscell(level_f)
            str=level_f{1};
            for nls=2:length(level_f)
                str=[str,'-' ,level_f{nls}];
            end
        else
            str=level_f;
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
    
    
%     mat_box=[];
%     
%     for nlf=1:tlf
%         mat_box(:,nlf)=ersp_topo_tw_fb_roi_avg{nlf};
%     end
%     


 cell_error_bar = cell(tlf,1);
    lv = nan(tlf,1);
    
    for nlf=1:tlf
        cell_error_bar(nlf)=ersp_topo_tw_fb_roi_avg(nlf);
        lv(nlf) = length(cell_error_bar{nlf});
    end
    
    mv =max(lv);
    
    mm = mean([cell_error_bar{:}]);
    ss = std([cell_error_bar{:}]);
    
%     if strcmp(z_transform,'on')
%         for nlf=1:tlf
%             cell_error_bar{nlf}=(cell_error_bar{nlf}-mm)/ss;
%         end
%         
%         compact_display_ylim = [-1 1];
%     end
    

    mat_box=nan(mv,tlf);
    
    for nlf=1:tlf
        mat_box(1:lv(nlf),nlf)=cell_error_bar{nlf};
    end



    xlab=name_f;
    ylab=ersp_meaure;
    
    num_comparisons = size(comparisons,2);
    signif_vec      = pcomparisons < study_ls;
    signif_pairs    = comparisons(:,signif_vec);
    psignif_vec     = pcomparisons(signif_vec);    
    
    % create figure
     fig=figure( 'color', 'w', 'Visible', 'off');
    % create topo plots
    set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);set(gcf, 'Visible', 'off');
    
    topoplot(roi_mask,chanlocs,'style','blank'); ;set(gcf, 'Visible', 'off');
    set(gca,'color',colbk);set(gcf, 'Visible', 'off');
    set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
    
    set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);set(gcf, 'Visible', 'off');
    set(gca, 'LineWidth', 1.2);set(gcf, 'Visible', 'off');
    % end
    
    aboxplot_raw(mat_box,'plot_raw','on','Colorgrad','orange_down');
    set(gca,'XTickLabel',levels_f)
    set(gca,'FontSize',10)
    
    xlabel(xlab)
    ylabel(ylab)
    
    hold on
    
    upbar=max(max(mat_box));
    dowbar=min(min(mat_box));
    
    range_box=[upbar dowbar];
    deltay=abs(diff(range_box))/4;
    
    if ~ isempty(signif_pairs)
        yval_min=dowbar-deltay/2;
        yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
        ylim([yval_min yval_max]);
        
        
        for i  = 1:size(signif_pairs,2)
            offset_segment=upbar+(i)*deltay;
            offset_star=offset_segment+deltay*0.2;
            plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
            plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
            plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
%             text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
            text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,num2str(psignif_vec(i)),'FontSize',15,'LineWidth',2)
            
        end
    end
    if ~isempty(compact_display_ylim)
        ylim(compact_display_ylim)
    end
    
    set(gcf,'color',colbk)
    %         hold off
    %         suptitle({[frequency_band_name, ' ERSP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });
    %
    %          fig=gcf;set(gcf, 'Visible', 'off');set(fig, 'Visible', 'off');
    
    hold off
    if (strcmp(show_text,'on'))
        suptitle({[frequency_band_name, ' ERSP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });
    end
  
    if (strcmp(show_text,'off'))
        fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
        
    end
    
    
    % %          set(fig, 'paperpositionmode', 'auto');
    % % setfont(fig, 'fontsize', 16);
    %         name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)]);
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
    
    
%     name_embed=fullfile(plot_dir,'ersp_topo_tw_fb');
%     name_plot=[name_embed,'_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)];
%     set(fig, 'renderer', 'painter')
%     modify_plot(fig);
%     saveas(fig, [name_plot,'.fig']);
%     print([name_plot,'.eps'],'-depsc2','-r300');
%     plot2svg([name_plot,'.svg'])
%     os = system_dependent('getos');
%     if ~ strncmp(os,'Linux',2)
%         print(fig,[name_embed,'.ps'],'-append','-dwinc')
%         saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
%     else
%         print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
%     end
%     export_fig(fig,[name_embed,'.pdf'], '-pdf', '-append')
%     
%     close(fig)
    

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
        
%         mat_box=[];
%         for nlf_between=1:tlf_between
%             mat_box(:,nlf_between)=ersp_topo_tw_fb_roi_avg{nlf_within,nlf_between};
%         end



cell_error_bar = cell(tlf_between,1);
    lv = nan(tlf_between,1);
    
    for nlf_between=1:tlf_between
        cell_error_bar(nlf_between)=ersp_topo_tw_fb_roi_avg(nlf_within,nlf_between);
        lv(nlf_between) = length(cell_error_bar{nlf_between});
    end
    
    mv =max(lv);
    
    mm = mean([cell_error_bar{:}]);
    ss = std([cell_error_bar{:}]);
    
%     if strcmp(z_transform,'on')
%         for nlf_between=1:tlf_between
%             cell_error_bar{nlf_between}=(cell_error_bar{nlf_between}-mm)/ss;
%         end
%         
%         compact_display_ylim = [-1 1];
%     end
    

    mat_box=nan(mv,tlf_between);
    
    for nlf_between=1:tlf_between
        mat_box(1:lv(nlf_between),nlf_between)=cell_error_bar{nlf_between};
    end


        
        xlab=name_f;
        ylab=ersp_meaure;
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec      = pcomparisons < study_ls;
        signif_pairs    = comparisons(:,signif_vec);
        psignif_vec     = pcomparisons(signif_vec);        
        
        % create figure
          fig=figure( 'color', 'w', 'Visible', 'off');
        if strcmp(show_head,'on')
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);
            
            topoplot(roi_mask,chanlocs,'style','blank');
            set(gca,'color',colbk);
            set(gca,'FontSize',10)
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);
            set(gca, 'LineWidth', 1.2)
        end
        
        aboxplot_raw(mat_box,'plot_raw','on','Colorgrad','orange_down');
        set(gca,'XTickLabel',levels_f)
        set(gca,'FontSize',10)
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        
        upbar=max(max(mat_box));
        dowbar=min(min(mat_box));
        
        range_box=[upbar dowbar];
        deltay=abs(diff(range_box))/4;
        
        if ~ isempty(signif_pairs)
            yval_min=dowbar-deltay/2;
            yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
            ylim([yval_min yval_max]);
            
            
            for i  = 1:size(signif_pairs,2)
                offset_segment=upbar+(i)*deltay;
                offset_star=offset_segment+deltay*0.2;
                plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
%                 text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
                text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,num2str(psignif_vec(i)),'FontSize',15,'LineWidth',2)
                
            end
        end
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
        end
        
        set(gcf,'color',colbk)
        %             hold off
        %             suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});
        %
        %              fig=gcf;
        
        hold off
        if (strcmp(show_text,'on'))
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});
        end
        
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
            
        end
        
        
        
        %              file_fig=['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name),'.fig'];
        %              saveas(fig, fullfile(plot_dir,file_fig));
        %
        %              set(fig, 'paperpositionmode', 'auto');
        % setfont(fig, 'fontsize', 16);
        %               name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)]);
        %             saveas(fig, [name_plot,'.fig']);
        %             saveas(fig,[name_plot,'.eps'],'epsc');
        %             plot2svg([name_plot,'.svg'])
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
        
        
%         name_embed=fullfile(plot_dir,'ersp_topo_tw_fb');
%         name_plot=[name_embed,'_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];
%         set(fig, 'renderer', 'painter')
%         modify_plot(fig);
%         saveas(fig, [name_plot,'.fig']);
%         print([name_plot,'.eps'],'-depsc2','-r300');
%         plot2svg([name_plot,'.svg'])
%         os = system_dependent('getos');
%         if ~ strncmp(os,'Linux',2)
%             print(fig,[name_embed,'.ps'],'-append','-dwinc')
%             saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
%         else
%             print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
%         end
%         export_fig([name_embed,'.pdf'], '-pdf', '-append')
%         
%         close(fig)
        

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','ersp_topo_tw_fb'];
input_save_fig.suffix_plot            = [char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )     



    end
    
    
    tlf_within=tlf2; % fix the column (group) and tlf_within2>1 (compare rows, i.e. conditions)
    tlf_between=tlf1;
    
    
    for nlf_within=1:tlf_within
        pcomp=pcond(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
        levels_f=levels_f1;
        name_f=name_f1;
        name_ff=levels_f2{nlf_within};
        comp=compcond(nlf_within);
        comparisons=comp{1};
        pcomparisons=pcomp{1};
        
%         mat_box=[];
%         for nlf_between=1:tlf_between
%             mat_box(:,nlf_between)=ersp_topo_tw_fb_roi_avg{nlf_between,nlf_within};
%         end




 cell_error_bar = cell(tlf_between,1);
    lv = nan(tlf_between,1);
    
    for nlf_between=1:tlf_between
        cell_error_bar(nlf_between)=ersp_topo_tw_fb_roi_avg(nlf_between,nlf_within);
        lv(nlf_between) = length(cell_error_bar{nlf_between});
    end
    
    mv =max(lv);
    
    mm = mean([cell_error_bar{:}]);
    ss = std([cell_error_bar{:}]);
    
%     if strcmp(z_transform,'on')
%         for nlf_between=1:tlf_between
%             cell_error_bar{nlf_between}=(cell_error_bar{nlf_between}-mm)/ss;
%         end
%         
%         compact_display_ylim = [-1 1];
%     end
    

    mat_box=nan(mv,tlf_between);
    
    for nlf_between=1:tlf_between
        mat_box(1:lv(nlf_between),nlf_between)=cell_error_bar{nlf_between};
    end


        
        xlab=name_f;
        ylab=ersp_meaure;
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec      = pcomparisons < study_ls;
        signif_pairs    = comparisons(:,signif_vec);
        psignif_vec     = pcomparisons(signif_vec);
        % create figure
         fig=figure( 'color', 'w', 'Visible', 'off');
        if strcmp(show_head,'on')
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);
            
            topoplot(roi_mask,chanlocs,'style','blank');
            set(gca,'color',colbk);
            set(gca,'FontSize',10)
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);
            set(gca, 'LineWidth', 1.2)
        end
        aboxplot_raw(mat_box,'plot_raw','on','Colorgrad','orange_down');
        set(gca,'XTickLabel',levels_f)
        set(gca,'FontSize',10)
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        
        upbar=max(max(mat_box));
        dowbar=min(min(mat_box));
        
        range_box=[upbar dowbar];
        deltay=abs(diff(range_box))/4;
        
        if ~ isempty(signif_pairs)
            yval_min=dowbar-deltay/2;
            yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
            ylim([yval_min yval_max]);
            
            
            
            
            for i  = 1:size(signif_pairs,2)
                offset_segment=upbar+(i)*deltay;
                offset_star=offset_segment+deltay*0.2;
                plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
                plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
%                 text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
                text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,num2str(psignif_vec(i)),'FontSize',15,'LineWidth',2)
                
            end
        end
        
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
            
        end
        set(gcf,'color',colbk)
        %             hold off
        %             suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});
        
        hold off
        if (strcmp(show_text,'on'))
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});
        end
       
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
            
        end
        
        
        
        %              fig=gcf;set(fig, 'Visible', 'off');
        % % set(fig, 'paperpositionmode', 'auto');
        % % setfont(fig, 'fontsize', 16);
        %             name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)]);
        %             saveas(fig, [name_plot,'.fig']);
        %             saveas(fig,[name_plot,'.eps'],'epsc');
        %             plot2svg([name_plot,'.svg'])
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
        
        
%         name_embed=fullfile(plot_dir,'ersp_topo_tw_fb');
%         name_plot=[name_embed,'_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];
%         set(fig, 'renderer', 'painter');set(fig, 'Visible', 'off');
%         modify_plot(fig);set(fig, 'Visible', 'off');
%         saveas(fig, [name_plot,'.fig']);
%         print([name_plot,'.eps'],'-depsc2','-r300');
%         plot2svg([name_plot,'.svg'])
%         os = system_dependent('getos');
%         if ~ strncmp(os,'Linux',2)
%             print(fig,[name_embed,'.ps'],'-append','-dwinc')
%             saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
%         else
%             print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
%         end
%         export_fig(fig,[name_embed,'.pdf'], '-pdf', '-append')
%         
%         close(fig)
        
input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','ersp_topo_tw_fb'];
input_save_fig.suffix_plot            = [char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )   
        
    end
    
end
end
