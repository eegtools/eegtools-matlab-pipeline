function [pgroup, pcond, pinter] = std_plottf_ersp_compact(input,varargin)

times                                                                      = input.times;
freqs                                                                      = input.freqs;
data                                                                       = input.data;
plot_dir                                                                   = input.plot_dir;
roi_name                                                                   = input.roi_name;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pmaskcond                                                                  = input.pmaskcond;
pmaskgru                                                                   = input.pmaskgru;
pmaskinter                                                                 = input.pmaskinter;
ersp_measure                                                               = input.ersp_measure;
% group_time_windows_list                                                    = input.group_time_windows_list;
frequency_bands_list                                                       = input.frequency_bands_list;
display_pmode                                                              = input.display_pmode;
set_caxis                                                                  = input.set_caxis;
study_ls                                                                   = input.study_ls;


strfname = char([ name_f1, '_', name_f2]);

if isempty(set_caxis)
    set_caxis = [-1 1];
end

pgroup = [];
pcond  = [];
pinter = [];

% cla
close all


[tlf1, tlf2]=size(data); % f1 sono le righe ed il fattore 1 (e' lungo quanto pmask group), f2 sono le colonne ed il fattore 2 (e' lungo quanto pmaskcond),


if tlf1 < 6    
    for nlf2 = 1:tlf2
        fig=figure( 'color', 'w', 'Visible', 'off');        
        for nlf1 = 1:tlf1            
            str1 = [levels_f1{nlf1}];            
            subplot(1,tlf1+1,nlf1);            
            imagesc(times,freqs,mean(data{nlf1,nlf2},3));%faccio il plot della matrice
            set(gca,'YDir','normal');            
            title(str1);
            xlabel('Time (ms)');
            ylabel('Freq (Hz)');            
            caxis(set_caxis);
            line('XData', [0 0], 'YData', [1 max(freqs)], 'LineStyle', '--','LineWidth', 2, 'Color','k');            
            for nfb = 1:length(frequency_bands_list)
                current_band  = frequency_bands_list{nfb};
                for nf = 1:2
                    line('XData', [times(1) times(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                    
                end
            end
        end
        cbar;        
        if tlf1 == 2
            mat_diff    = mean(data{1,nlf2},3) - mean(data{2,nlf2},3);
            mat_pvalue_plot = pmaskcond{nlf2}.*mat_diff;
        else
            mat_pvalue_plot = pmaskcond{nlf2};
        end        
        subplot(1,tlf1+1,tlf1+1);        
        imagesc(times,freqs,mat_pvalue_plot);%faccio il plot della matrice
        set(gca,'YDir','normal');
        pclim = [-1 1];        
        xlabel('Time (ms)');
        ylabel('Freq (Hz)');
        title(['P<',num2str(study_ls)]);   
        line('XData', [0 0], 'YData', [1 max(freqs)], 'LineStyle', '--','LineWidth', 2, 'Color','k');            
            for nfb = 1:length(frequency_bands_list)
                current_band  = frequency_bands_list{nfb};
                for nf = 1:2
                    line('XData', [times(1) times(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                    
                end
            end
        caxis(pclim);
        cbar;
        str2 = [char(roi_name),'_' ,levels_f2{nlf2}];
        suptitle(str2);
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = [strfname,'_','ersp_curve_tf'];
        input_save_fig.suffix_plot            = [char(roi_name),'_',str2];
        save_figures( input_save_fig );
        
    end
end




if tlf2 < 6    
    for nlf1 = 1:tlf1
        fig=figure( 'color', 'w', 'Visible', 'off');        
        for nlf2 = 1:tlf2            
            str1 = [levels_f2{nlf2}];            
            subplot(1,tlf2+1,nlf2);            
            imagesc(times,freqs,mean(data{nlf1,nlf2},3));%faccio il plot della matrice
            set(gca,'YDir','normal');            
            title(str1);
            xlabel('Time (ms)');
            ylabel('Freq (Hz)');            
            caxis(set_caxis);
            line('XData', [0 0], 'YData', [1 max(freqs)], 'LineStyle', '--','LineWidth', 2, 'Color','k');            
            for nfb = 1:length(frequency_bands_list)
                current_band  = frequency_bands_list{nfb};
                for nf = 1:2
                    line('XData', [times(1) times(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                    
                end
            end
        end
        cbar;        
        if tlf2 == 2
            mat_diff    = mean(data{nlf1,1},3) - mean(data{nlf1,2},3);
            mat_pvalue_plot = pmaskcond{nlf1}.*mat_diff;
        else
            mat_pvalue_plot = pmaskcond{nlf1};
        end        
        subplot(1,tlf2+1,tlf2+1);        
        imagesc(times,freqs,mat_pvalue_plot);%faccio il plot della matrice
        set(gca,'YDir','normal');
        pclim = [-1 1];        
        xlabel('Time (ms)');
        ylabel('Freq (Hz)');
        title(['P<',num2str(study_ls)]); 
        line('XData', [0 0], 'YData', [1 max(freqs)], 'LineStyle', '--','LineWidth', 2, 'Color','k');            
            for nfb = 1:length(frequency_bands_list)
                current_band  = frequency_bands_list{nfb};
                for nf = 1:2
                    line('XData', [times(1) times(end)], 'YData', [current_band(nf) current_band(nf)], 'LineStyle', '--','LineWidth', 2, 'Color','k')
                    
                end
            end
        
        caxis(pclim);
        cbar;
        str2 = [char(roi_name),'_' ,levels_f2{nlf1}];
        suptitle(str2);
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = [strfname,'_','ersp_curve_tf'];
        input_save_fig.suffix_plot            = str2;
        save_figures( input_save_fig );
        
    end
end
