function [] = eeglab_study_allch_erp_time_dd_grand_average_graph(input)


erp_grand_average                                                          = input.erp_grand_average;
p_grand_average                                                            = input.p_grand_average;
erp_avgsub                                                                 = input.erp_avgsub;
pvalue                                                                     = input.pvalue;
allch                                                                      = input.allch;
xlim                                                                       = input.xlim;
amplim                                                                     = input.amplim;
times                                                                      = input.times;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
plot_dir                                                                   = input.plot_dir;

transpose                                                   = 'on';


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





%% grand average

fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore

mat_erp_plot = erp_grand_average .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
% imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
pcolor(times(sel_times),1:tch,mat_erp_plot(:,sel_times));shading flat; grid on

caxis(amplim);
line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
xlabel('Times (ms)');
set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
ylabel('Channels');
title('grand average')
cbar;title('uV');

input.plot_dir    = plot_dir;
input.fig         = fig;
input.name_embed  = 'erp_grand_average';
input.suffix_plot = ['erp_grand_average_global'];
save_figures(input);






%% single cell of the design
if strcmp(transpose,'off')
    
    for ns1 = 1:s1 % per ciascun livello del primo fattore
        for ns2 = 1:s2 % per ogni livello del secondo fattore
            fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
            mat_erp_plot = erp_avgsub{ns1,ns2} .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
            
            
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
            input.name_embed  = 'erp_grand_average';
            input.suffix_plot = ['erp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
            
        end
        
      
       
        
        
    end
    
    
else
    
    for ns2 = 1:s2 % per ciascun livello del primo fattore
        for ns1 = 1:s1 % per ogni livello del secondo fattore
            fig=figure('color','w'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore

%             subplot(1,s1,ns1); % riempo un subplot della figura
            mat_erp_plot = erp_avgsub{ns1,ns2} .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
            
            
           
            
            
%             imagesc(times(sel_times),1:tch,mat_erp_plot(:,sel_times));%faccio il plot della matrice
pcolor(times(sel_times),1:tch,mat_erp_plot(:,sel_times));shading flat;grid on
 

            caxis(amplim);
            title([levels_f1{ns1},'__', levels_f2{ns2}])
            line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
            xlabel('Times (ms)');
            %         if not(s2==2)
            %             if ns2 ==1
            set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            ylabel('Channels');
            %             end
            %         else
            %             set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            %         end
            
            
             cbar;title('uV');
        %     end
        
        %     suptitle(levels_f1{ns1})
        
        input.plot_dir    = plot_dir;
        input.fig         = fig;
        input.name_embed  = 'erp_grand_average';
        input.suffix_plot = ['erp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
        save_figures(input);
            
        end
        
      
       
        
        
    end
    
end
end