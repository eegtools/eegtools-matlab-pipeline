function [] = std_plotcurve_erp_tw_compact(input)


times                                                                      = input.times;
erp                                                                        = input.erp;
plot_dir                                                                   = input.plot_dir; 
roi_name                                                                   = input.roi_name; 
study_ls                                                                   = input.study_ls; 
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pgroup                                                                     = input.pgroup;
pcond                                                                      = input.pcond; 
compact_display_h0                                                                 = input.compact_display_h0;
compact_display_v0                                                         = input.compact_display_v0;
compact_display_sem                                                        = input.compact_display_sem;
compact_display_stats                                                      = input.compact_display_stats;
compact_display_xlim                                                       = input.compact_display_xlim;
compact_display_ylim                                                       = input.compact_display_ylim;
time_windows_design_names                                                  = input.time_windows_design_names;

close all

% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(erp);

% to distinguish curves

% create a list of line stiles
list_stiles=repmat({'-','--',':','-.'},1,10);

% create a list of marker types
Markers=repmat(['o','x','+','*','s','d','v','^','<','>','p','h','.'],1,10);

tlf=max(tlf1,tlf2);
% create a list of colors
%  list_col=hsv(tlf+1);
list_col=repmat(['b','m','g','r','c'],1,10);



if tlf1 < 2 || tlf2 < 2
    
    tlf=max(tlf1,tlf2);
    
    % create a list of colors
    %list_col=hsv(tlf+1);
    fig=figure( 'Visible', 'off');
    
    erp_plot=erp;
    
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
        erp_plot_mat(nlf,:)=mean(erp_plot{nlf},2);
        nsub=size(erp_plot{nlf},2);
        
        if strcmp(compact_display_sem,'on')
            ster_plot_mat(nlf,:)=std(erp_plot{nlf},0,2)/sqrt(nsub);
            down_plot_mat(nlf,:)=erp_plot_mat(nlf,:)-ster_plot_mat(nlf,:);
            up_plot_mat(nlf,:)=erp_plot_mat(nlf,:)+ster_plot_mat(nlf,:);
        end
    end
    
    if strcmp(compact_display_sem,'off')
        ns=1;
        for nlf=1:tlf
            mm=erp_plot_mat(nlf,:);
            plot(times, mm,'col',list_col(nlf),'LineWidth',2,'LineStyle',list_stiles{ns})
            hold on
            if ns < length(list_stiles)
                ns=ns+1;
            else
                ns=1;
            end
        end
        l=legend(levels_f,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%,'YColor',[1 1 1],'XColor',[1 1 1]
        
    end
    
    if strcmp(compact_display_sem,'on')
        dx=0;
        nm=1;
        for nlf=1:tlf
            plot(times+dx, erp_plot_mat(nlf,:),Markers(nlf),'col',list_col(nlf),'LineWidth',2,'MarkerSize',10);
            nm=nm+1;
            if nlf > length(Markers)
                nm=1;
            end
            dx=dx+0.1;
            hold on
        end
        l=legend(levels_f,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%'YColor',[1 1 1],'XColor',[1 1 1],
        dx=0;
        nm=1;
        for nlf=1:tlf
            errorbar(times+dx, erp_plot_mat(nlf,:),ster_plot_mat(nlf,:),Markers(nlf),'col',list_col(nlf),'LineWidth',2,'MarkerSize',10)
            nm=nm+1;
            if nlf > length(Markers)
                nm=1;
            end
            dx=dx+0.1;
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
            plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'*','col','black','MarkerSize', 6,'LineWidth',1)
            
            pvec=p_plot{1};
            %                 for nss=1:length(pvec)
            %                     pstr= ['P=',sprintf('%0.1e',pvec(nss))];
            %                     text(times(nss),(yl1(1)+delta),pstr);
            %                 end
            
            lv=length(pvec);
            sh=delta*repmat([0.75,1],1,round(lv/2));
            sh = yl1(1)+sh(1:lv);
            for nss=1:length(pvec)
                pstr= [sprintf('%0.1e',pvec(nss))];
                text(times(nss),sh(nss),pstr);
            end
            hold on
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
    set(gca,'LineWidth',2, 'FontSize', 15)
    xlabel(['Time window'])
    ylabel(['Amplitude (uV)'])
    
    
    set(gca,'XLim',[0.5 length(time_windows_design_names)+1]);
    set(gca,'XTick',1:(length(time_windows_design_names)))
    set(gca,'XTickLabel',char(time_windows_design_names))
    
    
    
    title(['ERP in ', roi_name,': ', 'within ',name_f], 'FontSize', 20);
    hold off
    fig=gcf;
    
    %          file_fig=['erp_curve_',char(roi_name),'_',char(name_f),'.fig'];
    %          saveas(fig, fullfile(plot_dir,file_fig));
    %          file_tiff=['erp_curve_',char(roi_name),'_',char(name_f),'.tif'];
    %          print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
    %
    %
    %
    %          os = system_dependent('getos');
    %          if ~ strncmp(os,'Linux',2)
    %             print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append','-dwinc')
    %             saveppt2(fullfile(plot_dir,'erp_curve.ppt'),'f',fig);
    %          else
    %             print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append')
    %          end
    %          ps2pdf('psfile',fullfile(plot_dir,'erp_curve.ps'),'pdffile',fullfile(plot_dir,'erp_curve.pdf'))
    %
    
    
    % name_embed=fullfile(plot_dir,'erp_curve');
    % name_plot=[name_embed,'_',char(roi_name),'_',char(name_f)];
    % set(fig, 'renderer', 'painter')
    % modify_plot(fig);
    % saveas(fig, [name_plot,'.fig']);
    % print([name_plot,'.eps'],'-depsc2','-r300');
    % %plot2svg([name_plot,'.svg'])
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
    % close(fig)
    
    
    input_save_fig.plot_dir               = plot_dir;
    input_save_fig.fig                    = fig;
    input_save_fig.name_embed             = 'erp_curve';
    input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f)];
    
    save_figures( input_save_fig )
    
end





if tlf1 > 1 && tlf2 > 1
    % create a list of colors
    %list_col=hsv(tlf2+1);
    for nlf1=1:tlf1
        fig=figure( 'Visible', 'off');
        
        erp_plot=erp(nlf1,:);
        pgroup_plot=pgroup(nlf1);
        
        for nlf2=1:tlf2
            erp_plot_mat(nlf2,:)=mean(erp_plot{nlf2},2);
            nsub=size(erp_plot{nlf2},2);
            
            if strcmp(compact_display_sem,'on')
                ster_plot_mat(nlf2,:)=std(erp_plot{nlf2},0,2)/sqrt(nsub);
                down_plot_mat(nlf2,:)=erp_plot_mat(nlf2,:)-ster_plot_mat(nlf2,:);
                up_plot_mat(nlf2,:)=erp_plot_mat(nlf2,:)+ster_plot_mat(nlf2,:);
            end
            
        end
        
        if strcmp(compact_display_sem,'off')
            ns=1;
            for nlf2=1:tlf2
                mm=erp_plot_mat(nlf2,:);
                plot(times, mm,'col',list_col(nlf2),'LineWidth',2,'LineStyle',list_stiles{ns})
                hold on
                if ns < length(list_stiles)
                    ns=ns+1;
                else
                    ns=1;
                end
            end
            l=legend(levels_f2,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%,'YColor',[1 1 1],'XColor',[1 1 1]
            
        end
        
        if strcmp(compact_display_sem,'on')
            dx=0;
            nm=1;
            for nlf2=1:tlf2
                plot(times+dx, erp_plot_mat(nlf2,:),Markers(nlf2),'col',list_col(nlf2),'LineWidth',2,'MarkerSize',10);
                nm=nm+1;
                if nlf2 > length(Markers)
                    nm=1;
                end
                dx=dx+0.1;
                hold on
            end
            
            l=legend(levels_f2,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%,'YColor',[1 1 1],'XColor',[1 1 1]
            dx=0;
            nm=1;
            for nlf2=1:tlf2
                errorbar(times+dx, erp_plot_mat(nlf2,:),ster_plot_mat(nlf2,:),Markers(nlf2),'col',list_col(nlf2),'LineWidth',2,'MarkerSize',10)
                nm=nm+1;
                if nlf2 > length(Markers)
                    nm=1;
                end
                dx=dx+0.1;
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
                plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'*','col','black','MarkerSize', 6,'LineWidth',1)
                
                
                pvec=pgroup_plot{1};
                %                     for nss=1:length(pvec)
                %                         pstr= ['P=',sprintf('%0.1e',pvec(nss))];
                %                         text(times(nss),(yl1(1)+delta),pstr);
                %                     end
                                     lv=length(pvec);
                sh=delta*repmat([0.75,1],1,round(lv/2));
                sh = yl1(1)+sh(1:lv);
                for nss=1:length(pvec)
                    pstr= [sprintf('%0.1e',pvec(nss))];
                    text(times(nss),sh(nss),pstr);
                end
                hold on
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
        set(gca,'LineWidth',2, 'FontSize', 15)
        xlabel(['Time (ms)'])
        ylabel(['Amplitude (uV)'])
        
        set(gca,'XLim',[0.5 length(time_windows_design_names)+1]);
        set(gca,'XTick',1:(length(time_windows_design_names)))
        set(gca,'XTickLabel',char(time_windows_design_names))
        
        title(['ERP in ', roi_name,': ', 'within ',levels_f1{nlf1}], 'FontSize', 20);
        hold off
        
        fig=gcf;
        %              file_fig=['erp_curve_',char(roi_name),'_',char(levels_f1{nlf1}),'.fig'];
        %              saveas(fig, fullfile(plot_dir,file_fig));
        %
        %               file_tiff=['ersp_curve_',char(roi_name),'_',char(levels_f1{nlf1}),'.tif'];
        %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
        %
        %
        %              os = system_dependent('getos');
        %              if ~ strncmp(os,'Linux',2)
        %                 print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append','-dwinc')
        %                 saveppt2(fullfile(plot_dir,'erp_curve.ppt'),'f',fig);
        %              else
        %                 print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append')
        %              end
        %              ps2pdf('psfile',fullfile(plot_dir,'erp_curve.ps'),'pdffile',fullfile(plot_dir,'erp_curve.pdf'))
        %
        %
        %              close all
        
        
        % name_embed=fullfile(plot_dir,'erp_curve');
        % name_plot=[name_embed,'_',char(roi_name),'_',char(levels_f1{nlf1})];
        % set(fig, 'renderer', 'painter')
        % modify_plot(fig);
        % saveas(fig, [name_plot,'.fig']);
        % print([name_plot,'.eps'],'-depsc2','-r300');
        % %plot2svg([name_plot,'.svg'])
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
        % close(fig)
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'erp_curve';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(levels_f1{nlf1})];
        
        save_figures( input_save_fig )
        
    end
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    % create a list of colors
    %list_col=hsv(tlf1+1);
    for nlf2=1:tlf2
        
       fig=figure( 'Visible', 'off');
        
        erp_plot=erp(:,nlf2);
        pcond_plot=pcond(nlf2);
        
        for nlf1=1:tlf1
            erp_plot_mat(nlf1,:)=mean(erp_plot{nlf1},2);
            nsub=size(erp_plot{nlf1},2);
            
            if strcmp(compact_display_sem,'on')
                ster_plot_mat(nlf1,:)=std(erp_plot{nlf1},0,2)/sqrt(nsub);
                down_plot_mat(nlf1,:)=erp_plot_mat(nlf1,:)-ster_plot_mat(nlf1,:);
                up_plot_mat(nlf1,:)=erp_plot_mat(nlf1,:)+ster_plot_mat(nlf1,:);
            end
            
        end
        
        if strcmp(compact_display_sem,'off')
            ns=1;
            for nlf1=1:tlf1
                mm=erp_plot_mat(nlf1,:);
                plot(times, mm,'col',list_col(nlf1),'LineWidth',2,'LineStyle',list_stiles{ns})
                hold on
                if ns < length(list_stiles)
                    ns=ns+1;
                else
                    ns=1;
                end
            end
            l=legend(levels_f1,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%,'YColor',[1 1 1],'XColor',[1 1 1]
            
        end
        
        if strcmp(compact_display_sem,'on')
            dx=0;
            nm=1;
            for nlf1=1:tlf1
                plot(times+dx, erp_plot_mat(nlf1,:),Markers(nlf1),'col',list_col(nlf1),'LineWidth',2,'MarkerSize',10);
                nm=nm+1;
                if nlf1 > length(Markers)
                    nm=1;
                end
                dx=dx+0.1;
                hold on
            end
            
            l=legend(levels_f1,'box','off', 'FontSize', 15,'EdgeColor',[1 1 1],'Location','NorthEastOutside');%'YColor',[1 1 1],'XColor',[1 1 1],
            
            
            dx=0;
            nm=1;
            for nlf1=1:tlf1
                errorbar(times+dx, erp_plot_mat(nlf1,:),ster_plot_mat(nlf1,:),Markers(nlf1),'col',list_col(nlf1),'LineWidth',2,'MarkerSize',10)
                nm=nm+1;
                if nlf1 > length(Markers)
                    nm=1;
                end
                dx=dx+0.1;
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
            ss=pcond_plot{1}<study_ls;
            if ~isempty(ss)
                ss2=times(ss);
                hold on
                plot(ss2,ones(1,length(ss2))*(yl1(1)+delta/2),'*','col','black','MarkerSize', 6,'LineWidth',1)
                hold on
                
                pvec=pcond_plot{1};
                %                     for nss=1:length(pvec)
                %                         pstr= ['P=',sprintf('%0.1e',pvec(nss))];
                %                         text(times(nss),(yl1(1)+delta),pstr);
                %                     end
                lv=length(pvec);
                sh=delta*repmat([0.75,1],1,round(lv/2));
                sh = yl1(1)+sh(1:lv);
                for nss=1:length(pvec)
                    pstr= [sprintf('%0.1e',pvec(nss))];
                    text(times(nss),sh(nss),pstr);
                end
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
        set(gca,'LineWidth',2, 'FontSize', 15)
        xlabel(['Time (ms)'])
        ylabel(['Amplitude (uV)'])
        
        set(gca,'XLim',[0.5 length(time_windows_design_names)+1]);
        set(gca,'XTick',1:(length(time_windows_design_names)))
        set(gca,'XTickLabel',char(time_windows_design_names))
        
        title(['ERP in ', roi_name,': ','within ',levels_f2{nlf2}], 'FontSize', 20);
        hold off
        
        fig=gcf;
        %              file_fig=['erp_curve_',char(roi_name),'_',char(levels_f2{nlf2}),'.fig'];
        %
        %               file_tiff=['ersp_curve_',char(roi_name),'_',char(levels_f2{nlf2}),'.tif'];
        %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
        
        %              saveas(fig, fullfile(plot_dir,file_fig));
        %              os = system_dependent('getos');
        %              if ~ strncmp(os,'Linux',2)
        %                 print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append','-dwinc')
        %                 saveppt2(fullfile(plot_dir,'erp_curve.ppt'),'f',fig);
        %              else
        %                 print(fig,fullfile(plot_dir,'erp_curve.ps'),'-append')
        %              end
        %              ps2pdf('psfile',fullfile(plot_dir,'erp_curve.ps'),'pdffile',fullfile(plot_dir,'erp_curve.pdf'))
        %
        %              close all
        
        % name_embed=fullfile(plot_dir,'erp_curve');
        % name_plot=[name_embed,'_',char(roi_name),'_',char(levels_f2{nlf2})];
        % set(fig, 'renderer', 'painter')
        % modify_plot(fig);
        % saveas(fig, [name_plot,'.fig']);
        % print([name_plot,'.eps'],'-depsc2','-r300');
        % %plot2svg([name_plot,'.svg'])
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
        % close(fig)
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'erp_curve';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(levels_f2{nlf2})];
        
        save_figures( input_save_fig )
    end
end
end
