function [] =  std_plotcurve_ersp_fb_compact(input)

times                                                                      = input.times;
ersp_curve_fb                                                              = input.ersp_curve_fb;
plot_dir                                                                   = input.plot_dir;
roi_name                                                                   = input.roi_name;
study_ls                                                                   = input.study_ls;
frequency_band_name                                                        = input.frequency_band_name;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pgroup                                                                     = input.pgroup;
pcond                                                                      = input.pcond;
compact_display_h0                                                         = input.compact_display_h0;
compact_display_v0                                                         = input.compact_display_v0;
compact_display_sem                                                        = input.compact_display_sem;
compact_display_stats                                                      = input.compact_display_stats;
compact_display_xlim                                                       = input.compact_display_xlim;
compact_display_ylim                                                       = input.compact_display_ylim;
ersp_measure                                                               = input.ersp_measure;

close all

% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(ersp_curve_fb);

% to distinguish curves

% create a list of line stiles
%list_stiles={'-','--',':','-.'};
%       list_stiles={'-','-','-','-'};


% to distinguish curves

% create a list of line stiles
list_stiles=repmat({'-','--','-.'},1,10);

% create a list of marker types
Markers=repmat(['o','x','+','*','s','d','v','^','<','>','p','h','.'],1,10);

tlf=max(tlf1,tlf2);
% create a list of colors
% list_col=hsv(tlf+1);
% list_col=repmat(hsv(5),10,1);
list_col=repmat(['b','m','g','r','c'],1,10);


if tlf1 < 2 || tlf2 < 2
    
    tlf=max(tlf1,tlf2);
    
    % create a list of colors
    %list_col=hsv(tlf+1);
    fig=figure( 'color', 'w', 'Visible', 'off');
    
    ersp_curve_plot=ersp_curve_fb;
    
    if tlf2>1
        p_plot=pgroup;
        levels_f=levels_f2;
        name_f=name_f2;
    end
    if tlf1>1
        p_plot=pcond;
        levels_f=levels_f1;
        name_f=name_f1;
    end
    
    for nlf=1:tlf
        ersp_curve_fb_plot_mat(nlf,:)=mean(ersp_curve_plot{nlf},2);
        nsub=size(ersp_curve_plot{nlf},2);
        
        if strcmp(compact_display_sem,'on')
            ster_plot_mat(nlf,:)=std(ersp_curve_plot{nlf},0,2)/sqrt(nsub);
            down_plot_mat(nlf,:)=ersp_curve_fb_plot_mat(nlf,:)-ster_plot_mat(nlf,:);
            up_plot_mat(nlf,:)=ersp_curve_fb_plot_mat(nlf,:)+ster_plot_mat(nlf,:);
        end
        
    end
    
    ns=1;
    for nlf=1:tlf
        mm=ersp_curve_fb_plot_mat(nlf,:);
        plot(times, mm,'col',list_col(nlf),'LineWidth',3,'LineStyle',list_stiles{1})
        hold on
        if ns < length(list_stiles)
            ns=ns+1;
        else
            ns=1;
        end
    end
    
    if strcmp(compact_display_sem,'on')
        for nlf=1:tlf
%             BX=[times,fliplr(times)];
%             BY=[down_plot_mat(nlf,:),fliplr(up_plot_mat(nlf,:))];
%             fill(BX, BY,list_col(nlf),'FaceAlpha', 0.2)
plot(times, down_plot_mat(nlf,:),'col',list_col(nlf),'LineWidth',0.5,'LineStyle',list_stiles{2});
hold on
plot(times, up_plot_mat(nlf,:),'col',list_col(nlf),'LineWidth',0.5,'LineStyle',list_stiles{2});
            hold on
        end
    end
    
    if ~isempty(compact_display_xlim)
        xlim(compact_display_xlim)
    end
    if ~isempty(compact_display_ylim)
        ylim(compact_display_ylim)
    end
    
    yl1=get(gca,'ylim');
    delta=abs(diff(yl1))*0.1;
    yylim=[(yl1(1)-delta) yl1(2)];
    ylim(yylim);
    yl1=get(gca,'ylim');
    
    if strcmp(compact_display_stats,'on')
        hold on
        ss=p_plot{1}<study_ls;
        if ~isempty(ss)
            ss2=times(ss);
            hold on
            plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'s','LineWidth',3,'MarkerEdgeColor','black','MarkerSize', 5,'MarkerFaceColor', 'black')
        end
    end
    
    if strcmp(compact_display_h0,'on')
        line(get(gca,'XLim'),[0 0],'LineWidth',1,'LineStyle','--','col','black')
    end
    
    if strcmp(compact_display_v0,'on')
        line([0 0],get(gca,'XLim'),'LineWidth',1,'LineStyle','--','col','black')
    end
    
    xxlim=get(gca,'xlim');
    xlim(xxlim)
    set(gcf,'color','w');
    box off
    set(gca,'LineWidth',3, 'FontSize', 15)
    xlabel(['Time (ms)'])
    if strcmp(ersp_measure, 'Pfu')
        ylabel(['Delta %'])
    else
        ylabel(['Power (dB)'])
    end
    
    legend(levels_f,'box','off', 'FontSize', 13,'EdgeColor',[1 1 1],'Location','NorthEastOutside')%,'YColor',[1 1 1],'XColor',[1 1 1]
    title([frequency_band_name, ' ersp in ', roi_name,': ', 'within ',name_f], 'FontSize', 20);
    hold off
    
    
    
    
    %          set(fig, 'paperpositionmode', 'auto');
    % setfont(fig, 'fontsize', 16);
    %          name_plot=fullfile(plot_dir,['ersp_curve_fb_',char(roi_name),'_',char(name_f),'_',frequency_band_name]);
    %         saveas(fig, [name_plot,'.fig']);
    %         saveas(fig,[name_plot,'.eps'],'epsc');
    %         plot2svg([name_plot,'.svg'])
    %
    %
    %
    %
    %
    %
    %
    %          os = system_dependent('getos');
    %          if ~ strncmp(os,'Linux',2)
    %             print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append','-dwinc')
    %             saveppt2(fullfile(plot_dir,'ersp_curve_fb.ppt'),'f',fig);
    %          else
    %             print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append')
    %          end
    %          ps2pdf('psfile',fullfile(plot_dir,'ersp_curve_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_curve_fb.pdf'))
    % %          file_tiff=['ersp_curve_fb_',char(roi_name),'_',char(name_f),'_',frequency_band_name,'.tif'];
    % %          print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
    
    
    %     name_embed=fullfile(plot_dir,'ersp_curve_fb');
    %     name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',frequency_band_name];
    %     % set(fig, 'renderer', 'painter')
    %     modify_plot(fig);
    %     saveas(fig, [name_plot,'.fig']);
    %     print([name_plot,'.eps'],'-depsc2','-r300');
    %     plot2svg([name_plot,'.svg'])
    %     os = system_dependent('getos');
    %     if ~ strncmp(os,'Linux',2)
    %         print(fig,[name_embed,'.ps'],'-append','-dwinc')
    %         saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
    %     else
    %         %     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
    %         print(fig,[name_embed,'.ps'],'-append','-r300')
    %     end
    %     %  set(fig, 'renderer', 'painter')
    %     % export_fig([name_embed,'.pdf'], '-pdf', '-append')
    %     ps2pdf('psfile',[name_embed,'.ps'],'pdffile',[name_embed,'.pdf'])
    %
    %
    %     close(fig)
    
    
    input_save_fig.plot_dir               = plot_dir;
    input_save_fig.fig                    = fig;
    input_save_fig.name_embed             = 'ersp_curve_fb';
    input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(frequency_band_name)];
    
    if strcmp(compact_display_sem,'on')
        save_figures( input_save_fig );%save_figures( input_save_fig ,'renderer','opengl','pdf_mode','ps2pdf');
    else
        save_figures( input_save_fig )
    end
    
    
end





if tlf1 > 1 && tlf2 > 1
    % create a list of colors
    %list_col=hsv(tlf2+1);
    for nlf1=1:tlf1
        fig=figure( 'color', 'w', 'Visible', 'off');
        
        ersp_curve_plot=ersp_curve_fb(nlf1,:);
        pgroup_plot=pgroup(nlf1);
        
        for nlf2=1:tlf2
            ersp_curve_fb_plot_mat(nlf2,:)=mean(ersp_curve_plot{nlf2},2);
            nsub=size(ersp_curve_plot{nlf2},2);
            
            if strcmp(compact_display_sem,'on')
                ster_plot_mat(nlf2,:)=std(ersp_curve_plot{nlf2},0,2)/sqrt(nsub);
                down_plot_mat(nlf2,:)=ersp_curve_fb_plot_mat(nlf2,:)-ster_plot_mat(nlf2,:);
                up_plot_mat(nlf2,:)=ersp_curve_fb_plot_mat(nlf2,:)+ster_plot_mat(nlf2,:);
            end
            
        end
        
        ns=1;
        for nlf2=1:tlf2
            mm=ersp_curve_fb_plot_mat(nlf2,:);
            plot(times, mm,'col',list_col(nlf2),'LineWidth',3,'LineStyle',list_stiles{1})
            hold on
            if ns < length(list_stiles)
                ns=ns+1;
            else
                ns=1;
            end
        end
        
        if strcmp(compact_display_sem,'on')
            for nlf2=1:tlf2
%                 BX=[times,fliplr(times)];
%                 BY=[down_plot_mat(nlf2,:),fliplr(up_plot_mat(nlf2,:))];
%                 fill(BX, BY,list_col(nlf2),'FaceAlpha', 0.2)
%                 hold on
plot(times, down_plot_mat(nlf2,:),'col',list_col(nlf2),'LineWidth',0.5,'LineStyle',list_stiles{2});
hold on
plot(times, up_plot_mat(nlf2,:),'col',list_col(nlf2),'LineWidth',0.5,'LineStyle',list_stiles{2});
hold on
            end
        end
        
        if ~isempty(compact_display_xlim)
            xlim(compact_display_xlim)
        end
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
        end
        
        yl1=get(gca,'ylim');
        delta=abs(diff(yl1))*0.1;
        yylim=[(yl1(1)-delta) yl1(2)];
        ylim(yylim);
        yl1=get(gca,'ylim');
        
        if strcmp(compact_display_stats,'on')
            hold on
            ss=pgroup_plot{1}<study_ls;
            if ~isempty(ss)
                ss2=times(ss);
                hold on
                plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'s','LineWidth',3,'MarkerEdgeColor','black','MarkerSize', 5,'MarkerFaceColor', 'black')
            end
        end
        
        if strcmp(compact_display_h0,'on')
            line(get(gca,'XLim'),[0 0],'LineWidth',1,'LineStyle','--','col','black')
        end
        
        if strcmp(compact_display_v0,'on')
            line([0 0],get(gca,'XLim'),'LineWidth',1,'LineStyle','--','col','black')
        end
        
        xxlim=get(gca,'xlim');
        xlim(xxlim)
        set(gcf,'color','w');
        box off
        set(gca,'LineWidth',3, 'FontSize', 15)
        xlabel(['Time (ms)'])
        if strcmp(ersp_measure, 'Pfu')
            ylabel(['Delta %'])
        else
            ylabel(['Power (dB)'])
        end
        
        legend(levels_f2,'box','off', 'FontSize', 13,'EdgeColor',[1 1 1],'Location','NorthEastOutside')%,'YColor',[1 1 1],'XColor',[1 1 1]
        title([frequency_band_name, ' ersp in ', roi_name,': ', 'within ',levels_f1{nlf1}], 'FontSize', 20);
        hold off
        
        
        
        
        
        
        
        %              set(fig, 'paperpositionmode', 'auto');
        % setfont(fig, 'fontsize', 16);
        %                 name_plot=fullfile(plot_dir,['ersp_curve_fb_',char(roi_name),'_',char(levels_f1{nlf1}),'_',frequency_band_name]);
        %         saveas(fig, [name_plot,'.fig']);
        %         saveas(fig,[name_plot,'.eps'],'epsc');
        %         plot2svg([name_plot,'.svg'])
        %
        %
        %
        %
        %              os = system_dependent('getos');
        %              if ~ strncmp(os,'Linux',2)
        %                 print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append','-dwinc')
        %                 saveppt2(fullfile(plot_dir,'ersp_curve_fb.ppt'),'f',fig);
        %              else
        %                 print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append')
        %              end
        %              ps2pdf('psfile',fullfile(plot_dir,'ersp_curve_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_curve_fb.pdf'))
        % %              file_tiff=['ersp_curve_fb_',char(roi_name),'_',char(levels_f1{nlf1}),'_',frequency_band_name,'.tif'];
        % %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
        
        %         name_embed=fullfile(plot_dir,'ersp_curve_fb');
        %         name_plot=[name_embed,'_', char(roi_name),'_',char(levels_f1{nlf1}),'_',frequency_band_name];
        %         % set(fig, 'renderer', 'painter')
        %         modify_plot(fig);
        %         saveas(fig, [name_plot,'.fig']);
        %         print([name_plot,'.eps'],'-depsc2','-r300');
        %         plot2svg([name_plot,'.svg'])
        %         os = system_dependent('getos');
        %         if ~ strncmp(os,'Linux',2)
        %             print(fig,[name_embed,'.ps'],'-append','-dwinc')
        %             saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
        %         else
        %             %     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
        %             print(fig,[name_embed,'.ps'],'-append','-r300')
        %         end
        %         %  set(fig, 'renderer', 'painter')
        %         % export_fig([name_embed,'.pdf'], '-pdf', '-append')
        %         ps2pdf('psfile',[name_embed,'.ps'],'pdffile',[name_embed,'.pdf'])
        %
        %
        %         close(fig)
        
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'ersp_curve_fb';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(levels_f1{nlf1}),'_',char(frequency_band_name)];
        
        if strcmp(compact_display_sem,'on')
            save_figures( input_save_fig );%save_figures( input_save_fig ,'renderer','opengl','pdf_mode','ps2pdf');
        else
            save_figures( input_save_fig )
        end
        
        
    end
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    % create a list of colors
    %list_col=hsv(tlf1+1);
    for nlf2=1:tlf2
        
        fig=figure( 'color', 'w', 'Visible', 'off');
        
        ersp_curve_plot=ersp_curve_fb(:,nlf2);
        pcond_plot=pcond(nlf2);
        
        for nlf1=1:tlf1
            ersp_curve_fb_plot_mat(nlf1,:)=mean(ersp_curve_plot{nlf1},2);
            nsub=size(ersp_curve_plot{nlf1},2);
            
            if strcmp(compact_display_sem,'on')
                ster_plot_mat(nlf1,:)=std(ersp_curve_plot{nlf1},0,2)/sqrt(nsub);
                down_plot_mat(nlf1,:)=ersp_curve_fb_plot_mat(nlf1,:)-ster_plot_mat(nlf1,:);
                up_plot_mat(nlf1,:)=ersp_curve_fb_plot_mat(nlf1,:)+ster_plot_mat(nlf1,:);
            end
            
        end
        
        ns=1;
        for nlf1=1:tlf1
            mm=ersp_curve_fb_plot_mat(nlf1,:);
            plot(times, mm,'col',list_col(nlf1),'LineWidth',3,'LineStyle',list_stiles{1})
            hold on
            if ns < length(list_stiles)
                ns=ns+1;
            else
                ns=1;
            end
        end
        if strcmp(compact_display_sem,'on')
            for nlf1=1:tlf1
%                 BX=[times,fliplr(times)];
%                 BY=[down_plot_mat(nlf1,:),fliplr(up_plot_mat(nlf1,:))];
%                 fill(BX, BY,list_col(nlf1),'FaceAlpha', 0.2)
%                 hold on
plot(times, down_plot_mat(nlf1,:),'col',list_col(nlf1),'LineWidth',0.5,'LineStyle',list_stiles{2});
hold on
plot(times, up_plot_mat(nlf1,:),'col',list_col(nlf1),'LineWidth',0.5,'LineStyle',list_stiles{2});
            end
        end
        
        if ~isempty(compact_display_xlim)
            xlim(compact_display_xlim)
        end
        if ~isempty(compact_display_ylim)
            ylim(compact_display_ylim)
        end
        
        yl1=get(gca,'ylim');
        delta=abs(diff(yl1))*0.1;
        yylim=[(yl1(1)-delta) yl1(2)];
        ylim(yylim);
        yl1=get(gca,'ylim');
        
        if strcmp(compact_display_stats,'on')
            hold on
            ss=pcond_plot{1}<study_ls;
            if ~isempty(ss)
                ss2=times(ss);
                hold on
                plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'s','LineWidth',3,'MarkerEdgeColor','black','MarkerSize', 5,'MarkerFaceColor', 'black')
            end
        end
        
        
        if strcmp(compact_display_h0,'on')
            line(get(gca,'XLim'),[0 0],'LineWidth',1,'LineStyle','--','col','black')
        end
        
        if strcmp(compact_display_v0,'on')
            line([0 0],get(gca,'XLim'),'LineWidth',1,'LineStyle','--','col','black')
        end
        
        xxlim=get(gca,'xlim');
        xlim(xxlim);
        set(gcf,'color','w');
        box off
        set(gca,'LineWidth',3, 'FontSize', 15)
        xlabel(['Time (ms)'])
        if strcmp(ersp_measure, 'Pfu')
            ylabel(['Delta %'])
        else
            ylabel(['Power (dB)'])
        end
        
        legend(levels_f1,'box','off', 'FontSize', 13,'EdgeColor',[1 1 1],'Location','NorthEastOutside')%,'YColor',[1 1 1],'XColor',[1 1 1]
        
        title([frequency_band_name, ' ersp in ', roi_name,': ','within ',levels_f2{nlf2}], 'FontSize', 20);
        hold off
        
        
        
        
        
        %              set(fig, 'paperpositionmode', 'auto');
        % setfont(fig, 'fontsize', 16);
        %              file_fig=['_ersp_curve_fb_',char(roi_name),'_',char(levels_f2{nlf2}),'_',frequency_band_name,'.fig'];
        %              saveas(fig, fullfile(plot_dir,file_fig));
        %              os = system_dependent('getos');
        %              if ~ strncmp(os,'Linux',2)
        %                 print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append','-dwinc')
        %                 saveppt2(fullfile(plot_dir,'ersp_curve_fb.ppt'),'f',fig);
        %              else
        %                 print(fig,fullfile(plot_dir,'ersp_curve_fb.ps'),'-append')
        %              end
        %              ps2pdf('psfile',fullfile(plot_dir,'ersp_curve_fb.ps'),'pdffile',fullfile(plot_dir,'ersp_curve_fb.pdf'))
        %              file_tiff=['_ersp_curve_',char(roi_name),'_',char(levels_f2{nlf2}),'_',frequency_band_name,'.tif'];
        %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
        
        
        %         name_embed=fullfile(plot_dir,'ersp_curve_fb');
        %         name_plot=[name_embed,'_', char(roi_name),'_',char(levels_f2{nlf2}),'_',frequency_band_name];
        %         % set(fig, 'renderer', 'painter')
        %         % set(fig, 'renderer', 'painter')
        %         modify_plot(fig);
        %         saveas(fig, [name_plot,'.fig']);
        %         print([name_plot,'.eps'],'-depsc2','-r300');
        %         plot2svg([name_plot,'.svg'])
        %         os = system_dependent('getos');
        %         if ~ strncmp(os,'Linux',2)
        %             print(fig,[name_embed,'.ps'],'-append','-dwinc')
        %             saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
        %         else
        %             %     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
        %             print(fig,[name_embed,'.ps'],'-append','-r300')
        %         end
        %         %  set(fig, 'renderer', 'painter')
        %         % export_fig([name_embed,'.pdf'], '-pdf', '-append')
        %         ps2pdf('psfile',[name_embed,'.ps'],'pdffile',[name_embed,'.pdf'])
        %
        %         close(fig)
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'ersp_curve_fb';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(levels_f2{nlf2}),'_',char(frequency_band_name)];
        
        if strcmp(compact_display_sem,'on')
            save_figures( input_save_fig );%save_figures( input_save_fig ,'renderer','opengl','pdf_mode','ps2pdf');
        else
            save_figures( input_save_fig )
        end
        
    end
end
end
