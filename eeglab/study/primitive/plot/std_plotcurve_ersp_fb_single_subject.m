
function [] = std_plotcurve_ersp_fb_single_subject(input)

list_design_subjects                                                       = input.list_design_subjects;
times                                                                      = input.times;
ersp_curve_fb                                                              = input.ersp_curve_fb;
plot_dir                                                                   = input.plot_dir;
roi_name                                                                   = input.roi_name;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
frequency_band_name                                                        = input.frequency_band_name;


set(0,'defaulttextinterpreter','none')
% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1, tlf2]=size(ersp_curve_fb);

% to distinguish curves
% list_col=repmat(hsv(5),10,1);
list_col=repmat(['b','m','g','r','c'],1,10);

% create a list of line stiles
list_stiles=repmat({'-','--','-.',':'},1,10);

list_width=repmat([0.5,1.5,2.5,3.5],1,20);

for nlf1 =1:tlf1
    for nlf2 =1:tlf2
        close all
        ersp_curve_fb_plot = ersp_curve_fb{nlf1,nlf2};
        tsub=size(ersp_curve_fb_plot,2);
        fig=figure( 'color', 'w', 'Visible', 'off');
        %                     fig=figure( 'Visible', 'off');
        
        %         fig=figure( 'color', 'w');
        for nsub = 1:tsub
            plot(times, ersp_curve_fb_plot(:,nsub),'col',list_col(nsub),'LineWidth',list_width(nsub),'LineStyle',list_stiles{nsub});... plot(times, mm,'col',list_col(nlf+1,:),'LineWidth',2,'LineStyle',list_stiles{ns})
                % plot(times, ersp_curve_fb_plot(:,nsub));... plot(times, mm,'col',list_col(nlf+1,:),'LineWidth',2,'LineStyle',list_stiles{ns})
            
            hold on
        end
        
        line(get(gca,'XLim'),[0 0],'LineWidth',1,'LineStyle','--','col','black')
                hold on

    
        line([0 0],get(gca,'YLim'),'LineWidth',1,'LineStyle','--','col','black')
                hold on

        
        %         set(fig,'color','w');
        box off
        set(gca,'LineWidth',2, 'FontSize', 10)
        xlabel(['Time (ms)'])
        ylabel(['Amplitude (uV)'])
        set(0,'defaulttextinterpreter','none') ;
        l = legend(list_design_subjects{nlf1,nlf2},'box','off', 'FontSize', 10,'EdgeColor',[1 1 1],'Location','NorthEastOutside');
        set(l,'interpreter','none');
        title([frequency_band_name, ' ersp_curve_fb in ', roi_name,': ', levels_f1{nlf1},'_',levels_f2{nlf2} ], 'FontSize', 10);
%         hold off
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'ersp_curve_fb_curve';
        input_save_fig.suffix_plot            = [frequency_band_name, '_',char(roi_name),'_',char(levels_f1{nlf1}),'_',char(levels_f2{nlf2})];
        %         set(fig, 'PaperPositionMode', 'auto');
        save_figures( input_save_fig , 'res', '-r100')
    end
end
end



















