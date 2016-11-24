function [] = eeglab_study_allch_ersp_curve_fb_time_graph(input)


ersp_curve_fb                                                              = input.ersp_curve_fb;
pvalue                                                                     = input.project.stats.erp.pvalue;
allch                                                                      = input.allch;
amplim                                                                     = input.project.results_display.ylim_plot;
times                                                                      = input.times;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pcond_corr                                                                 = input.pcond_corr;
pgroup_corr                                                                = input.pgroup_corr;
plot_dir                                                                   = input.plot_dir;
frequency_band_name                                                        = input.frequency_band_name;



% dimensioni del cell array con gli erp grezzi
[s1 s2] = size(ersp_curve_fb);

% estraggo la matrice: le dimensioni dovrebbero essere tempo x canali x
% soggetti

pvalue_str=num2str(pvalue);

if isempty(amplim)
    amplim = [-5 5];
end


for ns1 = 1:s1 % per ciascun livello del primo fattore
    fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
    for ns2 = 1:s2 % per ogni livello del secondo fattore
        subplot(1,s2+1,ns2); % riempo un subplot della figura
        mat_erp_plot = mean(ersp_curve_fb{ns1,ns2},3)';% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
        imagesc(times,1:tch,mat_erp_plot);%faccio il plot della matrice
        caxis(amplim);
        title([levels_f2{ns2}])
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidpvalue', 2, 'Color','k')
        xlabel('Times (ms)');
        if not(s2==2)
            if ns2 ==1
                set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
                ylabel('Channels');
            end
        end
        
    end
    
    pplot = pgroup_corr(nlf1);
    ss = pplot{1} < pvalue;
    
    if s2==2
        mat_diff_erp    = mean(ersp_curve_fb{ns1,1},3)' - mean(ersp_curve_fb{ns1,1},3)';
        mat_pvalue_plot = (ss.*mat_diff_erp)';
        pclim = amplim;
    else
        mat_pvalue_plot = ss';
        pclim = [-1 1];
    end
    
    
    subplot(1,s2+1,s2+1); % riempo l'ultimo subplot della figura con le probabilita'
    imagesc(times,1:tch,mat_pvalue_plot);%faccio il plot della matrice
    caxis(pclim);
    set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
    
    if s2==2
        cbar;title('uV');
    end
    
    suptitle(levels_f1{ns1})
    
    input.plot_dir    = plot_dir;
    input.fig         = fig;
    input.name_embed  = 'cros_cor';
    input.suffix_plot = ['erp_allch_',levels_f1{ns1}];
    save_figures(input);
    
    
end







for ns2 = 1:s2 % per ciascun livello del primo fattore
    fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
    for ns1 = 1:s1 % per ogni livello del secondo fattore
        subplot(1,s1+1,ns1); % riempo un subplot della figura
        mat_erp_plot = mean(ersp_curve_fb{ns2,ns1},3)';% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
        imagesc(times,1:tch,mat_erp_plot);%faccio il plot della matrice
        caxis(amplim);
        title([levels_f2{ns1}])
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidpvalue', 2, 'Color','k')
        xlabel('Times (ms)');
        if not(s1==2)
            if ns1 ==1
                set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
                ylabel('Channels');
            end
        end
        
    end
    
    pplot = pcond_corr(nlf1);
    ss = pplot{1} < pvalue;
    
    if s1==2
        mat_diff_erp    = mean(ersp_curve_fb{1,ns2},3)' - mean(ersp_curve_fb{1,ns2},3)';
        mat_pvalue_plot = (ss.*mat_diff_erp)';
        pclim = amplim;
    else
        mat_pvalue_plot = ss';
        pclim = [-1 1];
    end
    
    
    subplot(1,s1+1,s1+1); % riempo l'ultimo subplot della figura con le probabilita'
    imagesc(times,1:tch,mat_pvalue_plot);%faccio il plot della matrice
    caxis(pclim);
    set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
    
    if s1==2
        cbar;title('uV');
    end
    
    suptitle(levels_f1{ns2})
    
    input.plot_dir    = plot_dir;
    input.fig         = fig;
    input.name_embed  = 'cros_cor';
    input.suffix_plot = ['erp_allch_',levels_f1{ns2}];
    save_figures(input);
    
    
end


end