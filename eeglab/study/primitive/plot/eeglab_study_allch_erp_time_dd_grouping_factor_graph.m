function [] = eeglab_study_allch_erp_time_dd_grouping_factor_graph(input)


% erp_grand_average                                                          = input.erp_grand_average;
p_grouping_factor                                                            = input.p_grouping_factor;
erp_gf = input.erp_gf;

erp_avgsub                                                                 = input.erp_avgsub;
pvalue                                                                     = input.pvalue;
allch                                                                      = input.allch;
xlim                                                                       = input.xlim;
amplim                                                                     = input.amplim;
times                                                                      = input.times;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
plot_dir                                                                   = input.plot_dir;


levels_grouping_factor=   input.levels_grouping_factor  ;
name_grouping_factor=        input.name_grouping_factor   ;
levels_comparing_factor=      input.levels_comparing_factor  ;
name_comparing_factor=   input.name_comparing_factor   ;

lgf = length(levels_grouping_factor);


% input_ga.erp_grand_average = mean_collapsed_cell_all_sub;
% input_ga.p_grand_average  = output_dd_grand_average;
% input_ga.erp_avgsub = erp_curve_allch_collsub_grand_average;

% input_ga.study_ls = pvalue;
% input_ga.allch = allch;
% input_ga.xlim = xlim;
% input_ga.amplim = amplim;
% input_ga.times = times;
% input_ga.levels_f1 = levels_f1(sel_levels_f1_grand_average_dd);
% input_ga.levels_f2 = levels_f2 (sel_levels_f2_grand_average_dd);
% input_ga.plot_dir = plot_dir;





tch = length(allch);

% dimensioni del cell array con gli erp mediati sui soggetti
[s1 s2] = size(erp_avgsub);




% estraggo la matrice: le dimensioni dovrebbero essere tempo x canali x
% soggetti

pvalue_str=num2str(pvalue);

if isempty(amplim)
    amplim = [-5 5];
end

sel_times = true(1,length(times));

if not(isempty(xlim))
    sel_times = times >= xlim(1) & times <= xlim(2);
end










if lgf == s1
    
    for ns1 = 1:s1 % per ciascun livello del primo fattore
        mat_erp_plot = erp_gf{ns1} .* p_grouping_factor{ns1};% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
        imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
        caxis(amplim);
        title(['grouped by ' levels_f1{ns1}])
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
        xlabel('Times (ms)');
        set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
        ylabel('Channels');
        cbar;title('uV');
        
        
        input.plot_dir    = plot_dir;
        input.fig         = fig;
        input.name_embed  = 'erp_grouping_factor';
        input.suffix_plot = ['erp_grouped_',levels_f1{ns1}];
        save_figures(input);
        
        for ns2 = 1:s2 % per ogni livello del secondo fattore
            fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
            mat_erp_plot = erp_avgsub{ns1,ns2} .* p_grouping_factor{ns1};% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
%             imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
pcolor(times(sel_times),1:tch,mat_erp_plot(:,sel_times));shading flat; grid on


            caxis(amplim);
            title([levels_f1{ns1}, '__',levels_f2{ns2}])
            line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
            xlabel('Times (ms)');
            set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            ylabel('Channels');
            cbar;title('uV');
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'erp_grouping_factor';
            input.suffix_plot = ['erp_grouped_',levels_f1{ns1}, '__',levels_f2{ns2}];
            save_figures(input);
        end
    end
    
    
else
    
    
    
    for ns2 = 1:s2 % per ciascun livello del primo fattore
        fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
        
        mat_erp_plot = erp_gf{ns2} .* p_grouping_factor{ns2};% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
%         imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
pcolor(times(sel_times),1:tch,mat_erp_plot(:,sel_times));shading flat; grid on


        caxis(amplim);
        title(['grouped by ' levels_f2{ns2}])
        line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
        xlabel('Times (ms)');
        set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
        ylabel('Channels');
        cbar;title('uV');
        
        input.plot_dir    = plot_dir;
        input.fig         = fig;
        input.name_embed  = 'erp_grouping_factor';
        input.suffix_plot = ['erp_grouped_',levels_f2{ns2}];
        save_figures(input);
        
        for ns1 = 1:s1 % per ogni livello del secondo fattore
            fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
            mat_erp_plot = erp_avgsub{ns1,ns2} .* p_grouping_factor{ns2};% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
%             imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
pcolor(times(sel_times),1:tch,mat_erp_plot(:,sel_times));shading flat; grid on


            caxis(amplim);
            title([levels_f1{ns1},'__', levels_f2{ns2}])
            line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
            xlabel('Times (ms)');
            set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            ylabel('Channels');
            cbar;title('uV');
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'erp_grouping_factor';
            input.suffix_plot = ['erp_grouped_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
        end
    end
    
    
    
end
end