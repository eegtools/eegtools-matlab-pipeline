function std_chantopo_ersp_compact_errorbar(ersp_topo_tw_fb_roi_avg, ...
    plot_dir, roi_name, ...
    chanlocs,...
    time_window_name, time_window, ...
    frequency_band_name, ...
    name_f1, name_f2, levels_f1,levels_f2,...
    pgroup,  pcond, study_ls, ...
    roi_mask, compcond, compgroup, ersp_mode,show_head,compact_display_ylim,show_text,z_transform,which_error_measure)

%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');


% z_transform='on';




% Markers=['o','x','+','*','s','d','v','^','<','>','p','h','.'];




% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(ersp_topo_tw_fb_roi_avg);


% create a list of marker types
Markers=repmat(['o','x','+','*','s','d','v','^','<','>','p','h','.'],1,10);

tlf=max(tlf1,tlf2);
% create a list of colors
% list_col=hsv(tlf+1);
% list_col=repmat(hsv(5),10,1);
list_col=repmat(['b','m','g','r','c'],1,10);


switch ersp_mode
    case 'dB'
        ersp_meaure='dB';
    case 'Pfu'
        ersp_meaure='Delta %';
end

if strcmp(z_transform,'on')
    ersp_meaure='Z(ERSP)';
end

colbk='white';



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
    
    % create a list of colors
%     list_col=hsv(tlf+1);
    
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
    mat_error_bar=[];
    for nlf=1:tlf
        mat_error_bar(:,nlf)=ersp_topo_tw_fb_roi_avg{nlf};
    end
    
    if strcmp(z_transform,'on')
        mat_error_bar=(mat_error_bar-mean(mean(mat_error_bar)))/std(mat_error_bar(:));
        compact_display_ylim = [-1 1];
    end
    
    vec_mean=mean(mat_error_bar,1);
    
    vec_err=std(mat_error_bar,0,1);
    if strcmp(which_error_measure,'sem')
        vec_err=vec_err/sqrt(size(mat_error_bar,1));
    end
    
    xlab=name_f;
    ylab=ersp_meaure;
    
    %comparisons = combn_all(1:tot_topo,2);
    num_comparisons = size(comparisons,2);
    signif_vec = pcomparisons < study_ls;
    signif_pairs = comparisons(:,signif_vec);
    
    % create figure
     fig=figure( 'color', 'w', 'Visible', 'off');
    if strcmp(show_head,'on')
        % create topo plots
        set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);
        
        topoplot(roi_mask,chanlocs,'style','blank');
        set(gca,'color',colbk);set(gcf, 'Visible', 'off');
        set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
        
        set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);set(gcf, 'Visible', 'off');
        set(gca, 'LineWidth', 1.2) ;set(gcf, 'Visible', 'off');
        
    end
    
    for nn=1:length(vec_mean)
        plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
        hold on
        errorbar(nn,vec_mean(nn),vec_err(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(gcf, 'Visible', 'off');
        hold on
    end
    
    
    set(gca,'XTick',1:(length(levels_f)));set(gcf, 'Visible', 'off');
    set(gca,'XTickLabel',levels_f);set(gcf, 'Visible', 'off');
    set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
    
    xlabel(xlab)
    ylabel(ylab)
    
    hold on
    
    upbar=max(vec_mean+vec_err);
    dowbar=min(vec_mean-vec_err);
    
    range_error_bar=[upbar dowbar];
    deltay=abs(diff(range_error_bar))/4;
    
    if isempty(compact_display_ylim)
        deltay=deltay/4;
        yval_min=dowbar-deltay/2;
        yval_max=upbar+1*deltay*(size(signif_pairs,2)+0.5)    ;
        ylim([yval_min yval_max]);
        
        for i  = 1:size(signif_pairs,2)
            offset_segment=upbar+(i)*deltay;
            %offset_star=offset_segment+deltay*0.2;
            plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
            
        end
    end
    
    if ~isempty(compact_display_ylim)
        ylim(compact_display_ylim)
        if ~ isempty(signif_pairs)
            space_sig=compact_display_ylim(2)-upbar;
            delta_y = space_sig/(size(signif_pairs,2)+2);
            for i = 1 : size(signif_pairs,2)
                offset_segment=upbar+(i)*delta_y;
                plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
            end
        end
    end
    
    
    
    set(fig,'color',colbk)
    %         hold off
    if (strcmp(show_text,'on'))
        suptitle({[frequency_band_name, ' ERSP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });
    end    
    if (strcmp(show_text,'off'))
        fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
        
    end
    %          set(fig, 'renderer', 'painter')
    % %          set(fig, 'paperpositionmode', 'auto');
    % % setfont(fig, 'fontsize', 16);
    %             name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)]);
    %             saveas(fig, [name_plot,'.fig']);
    %             saveas(fig,[name_plot,'.eps'],'epsc');
    %             plot2svg([name_plot,'.svg'])
    %
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
    
%     name_embed=fullfile(plot_dir,['ersp_topo_tw_fb','_',time_window_name]);
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
%     export_fig([name_embed,'.pdf'], '-pdf', '-append')
%     
%     
%     
%     close(fig)

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = 'ersp_topo_tw_fb';
input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )
    
end


if tlf1 > 1 && tlf2 > 1
    tlf_within=tlf1; % fix the row (condition) and tlf_within2>1 (compare columns, i.e. groups)
    tlf_between=tlf2;
%     list_col=hsv(tlf_between+1);
    for nlf_within=1:tlf_within % for each row
        pcomp=pgroup(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
        levels_f=levels_f2;
        name_f=name_f2;
        name_ff=levels_f1{nlf_within};
        comp=compgroup(nlf_within);
        comparisons=comp{1};
        pcomparisons=pcomp{1};
        mat_error_bar=[];
        for nlf=1: tlf_between
            mat_error_bar(:,nlf)=ersp_topo_tw_fb_roi_avg{nlf,nlf_within};
        end
        
        if strcmp(z_transform,'on')
            mat_error_bar=(mat_error_bar-mean(mean(mat_error_bar)))/std(mat_error_bar(:));
        end
        
        vec_mean=mean(mat_error_bar,1);
        
        vec_err=std(mat_error_bar,0,1);
        if strcmp(which_error_measure,'sem')
            vec_err=vec_err/sqrt(size(mat_error_bar,1));
        end
        
        xlab=name_f;
        ylab=ersp_meaure;
        
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec = pcomparisons < study_ls;
        signif_pairs = comparisons(:,signif_vec);
        
        % create figure
        % create figure
        figure();set(gcf, 'Visible', 'off');
        if strcmp(show_head,'on')
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);
            
            topoplot(roi_mask,chanlocs,'style','blank');
            set(gca,'color',colbk);set(gcf, 'Visible', 'off');
            set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);
            set(gca, 'LineWidth', 1.2);set(gcf, 'Visible', 'off');
            
        end
        %         errorbar(vec_mean,vec_err,'d','MarkerSize',10);set(gcf, 'Visible', 'off');
        for nn=1:length(vec_mean)
            plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
            hold on
            errorbar(nn,vec_mean(nn),vec_err(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(gcf, 'Visible', 'off');
            hold on
        end
        
        set(gca,'XTick',1:(length(levels_f))) ;set(gcf, 'Visible', 'off');
        set(gca,'XTickLabel',levels_f);set(gcf, 'Visible', 'off');
        set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        
        upbar=max(vec_mean+vec_err);
        dowbar=min(vec_mean-vec_err);
        
        range_error_bar=[upbar dowbar];
        deltay=abs(diff(range_error_bar))/4;
        
        if isempty(compact_display_ylim)
            deltay=deltay/4;
            yval_min=dowbar-deltay/2;
            yval_max=upbar+1*deltay*(size(signif_pairs,2)+0.5)    ;
            ylim([yval_min yval_max]);
            
            for i  = 1:size(signif_pairs,2)
                offset_segment=upbar+(i)*deltay;
                %offset_star=offset_segment+deltay*0.2;
                plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                
            end
        end
        
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
            if ~ isempty(signif_pairs)
                space_sig=compact_display_ylim(2)-upbar;
                delta_y = space_sig/(size(signif_pairs,2)+2);
                for i = 1 : size(signif_pairs,2)
                    offset_segment=upbar+(i)*delta_y;
                    plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                end
            end
            
        end
        
        set(gcf,'color',colbk)
        %         hold off
        if (strcmp(show_text,'on'))
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});
        end
        
        fig=gcf;
        
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
        end
        
        
%         name_embed=fullfile(plot_dir,['ersp_topo_tw_fb','_',time_window_name]);
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
input_save_fig.name_embed             = 'ersp_topo_tw_fb';
input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )
        
    end
    
    
    tlf_within=tlf2; % fix the column (group) and tlf_within2>1 (compare rows, i.e. conditions)
    tlf_between=tlf1;
%     list_col=hsv(tlf_between+1);
    for nlf_within=1:tlf_within
        pcomp=pcond(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
        levels_f=levels_f1;
        name_f=name_f1;
        name_ff=levels_f2{nlf_within};
        comp=compcond(nlf_within);
        comparisons=comp{1};
        pcomparisons=pcomp{1};
        
        mat_error_bar=[];
        for nlf=1:tlf_between
            mat_error_bar(:,nlf)=ersp_topo_tw_fb_roi_avg{nlf,nlf_within};
        end
        
        
        if strcmp(z_transform,'on')
            mat_error_bar=(mat_error_bar-mean(mean(mat_error_bar)))/std(mat_error_bar(:));
        end
        
        vec_mean=mean(mat_error_bar,1);
        
        vec_err=std(mat_error_bar,0,1);
        if strcmp(which_error_measure,'sem')
            vec_err=vec_err/sqrt(size(mat_error_bar,1));
        end
        
        xlab=name_f;
        ylab=ersp_meaure;
        
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec = pcomparisons < study_ls;
        signif_pairs = comparisons(:,signif_vec);
        
        % create figure
        figure();set(gcf, 'Visible', 'off');
        
        if strcmp(show_head,'on')
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2]);
            
            topoplot(roi_mask,chanlocs,'style','blank');
            set(gca,'color',colbk);set(gcf, 'Visible', 'off');
            set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6]);
            set(gca, 'LineWidth', 1.2)
            
        end
        %          errorbar(vec_mean,vec_err,'d','MarkerSize',10);set(gcf, 'Visible', 'off');
        for nn=1:length(vec_mean)
            plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
            hold on
            errorbar(nn,vec_mean(nn),vec_err(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(gcf, 'Visible', 'off');
            hold on
        end
        
        set(gca,'XTick',1:(length(levels_f)));set(gcf, 'Visible', 'off');
        set(gca,'XTickLabel',levels_f);set(gcf, 'Visible', 'off');
        set(gca,'FontSize',10);set(gcf, 'Visible', 'off');
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        upbar=max(vec_mean+vec_err);
        dowbar=min(vec_mean-vec_err);
        
        range_error_bar=[upbar dowbar];
        deltay=abs(diff(range_error_bar))/4;
        
        if isempty(compact_display_ylim)
            deltay=deltay/4;
            yval_min=dowbar-deltay/2;
            yval_max=upbar+1*deltay*(size(signif_pairs,2)+0.5)    ;
            ylim([yval_min yval_max]);
            
            for i  = 1:size(signif_pairs,2)
                offset_segment=upbar+(i)*deltay;
                %offset_star=offset_segment+deltay*0.2;
                plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                
            end
        end
        
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
            if ~ isempty(signif_pairs)
                space_sig=compact_display_ylim(2)-upbar;
                delta_y = space_sig/(size(signif_pairs,2)+2);
                for i = 1 : size(signif_pairs,2)
                    offset_segment=upbar+(i)*delta_y;
                    plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
                end
            end
        end
        
        set(gcf,'color',colbk)
        %             hold off
        if (strcmp(show_text,'on'))
            suptitle({[frequency_band_name, ' ERSP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});
        end
        fig=gcf;
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
            
        end
        
        
        % %                set(fig, 'paperpositionmode', 'auto');
        % % setfont(fig, 'fontsize', 16);
        % set(fig, 'renderer', 'painter')
        %                 name_plot=fullfile(plot_dir,['ersp_topo_tw_fb_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)]);
        %             saveas(fig, [name_plot,'.fig']);
        %             saveas(fig,[name_plot,'.eps'],'epsc');
        %             plot2svg([name_plot,'.svg'])
        %
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
        
        
%         name_embed=fullfile(plot_dir,['ersp_topo_tw_fb','_',time_window_name]);
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
%         
%         close(fig)
        
input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = 'ersp_topo_tw_fb';
input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'_',char(frequency_band_name)];

save_figures( input_save_fig )
        
        
    end
    
    
    
    
    
end
end
