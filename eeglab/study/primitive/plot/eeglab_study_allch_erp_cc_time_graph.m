function [] = eeglab_study_allch_erp_cc_time_graph(input)


% erp_curve                                                                  = input.erp_curve;
% pvalue                                                                     = input.project.stats.erp.pvalue;
pvalue                                                                     = input.study_ls;
allch                                                                      = input.allch;
% cclim                                                                     = input.project.results_display.erp.compact_display_ylim;
cclim                                                                     = input.cclim;
% times                                                                      = input.times;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
% pcond_corr                                                                 = input.pcond_corr;
% pgroup_corr                                                                = input.pgroup_corr;
plot_dir                                                                   = input.plot_dir;

cell_cor_1                                                                 = input.cell_cor_1;
cell_cor_2                                                                 = input.cell_cor_2;
% cell_lag_1                                                                 = input.cell_lag_1;
% cell_lag_2                                                                 = input.cell_lag_2;
cell_stat_1                                                                = input.cell_stat_1;
cell_stat_2                                                                = input.cell_stat_2;
vlag_ms                                                                    = input.vlag_ms;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;


tch = length(allch);


ts1 = length(cell_cor_1);
ts2 = length(cell_cor_2);

% estraggo la matrice: le dimensioni dovrebbero essere tempo x canali x
% soggetti

pvalue_str=num2str(pvalue);

if isempty(cclim)
    cclim = [-2 2]; % tengo conto del caso limite con alta correlazione positiva in un livello ed alta negativa nell'altro
end


% per ogni livello di f1 plotto la correlazione tra i 2 livelli di f2.
% nell'ultimo subplot metto la statistica


if not(isempty(cell_cor_1))
    fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
    for ns1 = 1:ts1
        subplot(1,ts1+1,ns1); % riempo un subplot della figura
        mat_plot = mean(cell_cor_1{ns1},3)';% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
        imagesc(vlag_ms,1:tch,mat_plot);
        title([levels_f1{ns1}])
        caxis(cclim);
        set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
        xlabel('Time lags (ms)');
        if ns1==1 
         ylabel('Channels');   
        end
    end
    
    
    pplot = cell_stat_1{1};
    ss = pplot < pvalue;
    
    if ts2==2
        mat_diff    = mean(cell_cor_1{1},3) - mean(cell_cor_1{2},3);
        mat_pvalue_plot = (ss.*mat_diff)';
        pclim = cclim;
    else
        mat_pvalue_plot = ss';
        pclim = [-1 1];
    end
    
    
    subplot(1,ts1+1,ts1+1); % riempo l'ultimo subplot della figura con le probabilita'
    imagesc(vlag_ms,1:tch,mat_pvalue_plot);%faccio il plot della matrice
    caxis(pclim);
    set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
    line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
    title(['(P<',pvalue_str,')']);
    xlabel('Time lags (ms)');
    
    if ts2==1
        cbar;title('diff(CC)');
    end
    
    suptitle(['CC ', levels_f1{1},'-', levels_f1{2}])
    
    input.plot_dir    = plot_dir;
    input.fig         = fig;
    input.name_embed  = 'cros_cor';
    input.suffix_plot = ['erp_allch_',name_f1];
    save_figures(input);
end

if not(isempty(cell_cor_2))
    fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
    for ns2 = 1:ts2
        subplot(1,ts2+1,ns2); % riempo un subplot della figura
        mat_plot = mean(cell_cor_2{ns2},3)';% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
        imagesc(vlag_ms,1:tch,mat_plot);
        title([levels_f2{ns2}])
        caxis(cclim);
        set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')        
        xlabel('Time lags (ms)');
        if ns2==1 
         ylabel('Channels');   
        end
         
         
    end
    
    
    pplot = cell_stat_2{1};
    ss = pplot < pvalue;
    
    if ts1==2
        mat_diff    = mean(cell_cor_2{1},3) - mean(cell_cor_2{2},3);
        mat_pvalue_plot = (ss.*mat_diff)';
        pclim = cclim;
    else
        mat_pvalue_plot = ss';
        pclim = [-1 1];
    end
    
    
    subplot(1,ts2+1,ts2+1); % riempo l'ultimo subplot della figura con le probabilita'
    imagesc(vlag_ms,1:tch,mat_pvalue_plot);%faccio il plot della matrice
    caxis(pclim);
    set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
    line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
    title(['(P<',pvalue_str,')']);
    xlabel('Time lags (ms)');
    
    if ts2==2
        cbar;title('diff(CC)');
    end
    
    suptitle(['CC ', levels_f1{1},'-', levels_f1{2}])
    
    input.plot_dir    = plot_dir;
    input.fig         = fig;
    input.name_embed  = 'cros_cor';
    input.suffix_plot = ['erp_allch_',name_f2];
    save_figures(input);
end

end


