function [] = eeglab_study_allch_ersp_time_dd_grand_average_graph(input)


ersp_grand_average                                                          = input.ersp_grand_average;
p_grand_average                                                            = input.p_grand_average;
ersp_avgsub                                                                 = input.ersp_avgsub;
pvalue                                                                     = input.pvalue;
allch                                                                      = input.allch;
xlim                                                                       = input.xlim;
amplim                                                                     = input.amplim;
times                                                                      = input.times;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
plot_dir                                                                   = input.plot_dir;
ersp_measure                                                               = input.ersp_measure;
transpose                                                   = 'on';
select_tw_des                                                              = input.select_tw_des;


% input_ga.ersp_grand_average = mean_collapsed_cell_all_sub;
% input_ga.p_grand_average  = output_dd_grand_average;
% input_ga.ersp_avgsub = ersp_curve_allch_collsub_grand_average;

% input_ga.study_ls = pvalue;
% input_ga.allch = allch;
% input_ga.xlim = xlim;
% input_ga.amplim = amplim;
% input_ga.times = times;
% input_ga.levels_f1 = levels_f1(sel_levels_f1_grand_average_dd);
% input_ga.levels_f2 = levels_f2 (sel_levels_f2_grand_average_dd);
% input_ga.plot_dir = plot_dir;





tch = length(allch);

% dimensioni del cell array con gli ersp mediati sui soggetti
[s1 s2] = size(ersp_avgsub);

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

fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore

mat_ersp_plot = ersp_grand_average .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)

if not(isempty(select_tw_des{1,1}))
    
    tt1 = select_tw_des{1,1}(1);
    tt2 = select_tw_des{1,1}(2);
    sel_tt = times <tt1 | times > tt2;
    mat_ersp_plot(:,sel_tt)=0;
    
end

imagesc(times(sel_times),1:tch,mat_ersp_plot(:,sel_times),'AlphaData',~isnan(mat_ersp_plot(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
% pcolor(times(sel_times),1:tch,mat_ersp_plot(:,sel_times));shading flat; grid on

caxis(amplim);
line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
xlabel('Times (ms)');
set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
ylabel('Channels');
title('grand average')
cbar;
if strcmp(ersp_measure, 'Pfu')
    title(['Delta %'])
else
    title(['dB'])
end


input.plot_dir    = plot_dir;
input.fig         = fig;
input.name_embed  = 'masked_ersp_grand_average';
input.suffix_plot = ['masked_ersp_grand_average_global'];
save_figures(input);



fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore

mat_ersp_plot = ersp_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)





imagesc(times(sel_times),1:tch,mat_ersp_plot(:,sel_times),'AlphaData',~isnan(mat_ersp_plot(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
% pcolor(times(sel_times),1:tch,mat_ersp_plot(:,sel_times));shading flat; grid on

caxis(amplim);
line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
xlabel('Times (ms)');
set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
ylabel('Channels');
title('grand average')
cbar;
if strcmp(ersp_measure, 'Pfu')
    title(['Delta %'])
else
    title(['dB'])
end


input.plot_dir    = plot_dir;
input.fig         = fig;
input.name_embed  = 'raw_ersp_grand_average';
input.suffix_plot = ['raw_ersp_grand_average_global'];
save_figures(input);




%% single cell of the design
if strcmp(transpose,'off')
    
    for ns1 = 1:s1 % per ciascun livello del primo fattore
        for ns2 = 1:s2 % per ogni livello del secondo fattore
            
            mat_ersp_plot = ersp_avgsub{ns1,ns2} .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
            
            
            if not(isempty(select_tw_des_stat{ns1,ns2}))
                
                tt1 = select_tw_des_stat{ns1,ns2}(1);
                tt2 = select_tw_des_stat{ns1,ns2}(2);
                sel_tt = times <tt1 | times > tt2;
                mat_ersp_plot(:,sel_tt)=0; % prima nan ma per problemi di rendering devo usare zeri che diventano verdi, anche se meno belli
                
            end
            
            
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
                        imagesc(times(sel_times),1:tch,mat_ersp_plot(:,sel_times),'AlphaData',~isnan(mat_ersp_plot(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
%             pcolor(times(sel_times),1:tch,mat_ersp_plot(:,sel_times));shading flat; grid on
            caxis(amplim);
            title([levels_f1{ns1},'__', levels_f2{ns2}])
            line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
            xlabel('Times (ms)');
            set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            ylabel('Channels');
            cbar;%title('uV');
            if strcmp(ersp_measure, 'Pfu')
                title(['Delta %'])
            else
                title(['dB'])
            end
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'masked_ersp_grand_average';
            input.suffix_plot = ['masked_ersp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
            
            
            
            
            
            
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
                        imagesc(times(sel_times),1:tch,ersp_avgsub{ns1,ns2}(:,sel_times),'AlphaData',~isnan(ersp_avgsub{ns1,ns2}(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
%             pcolor(times(sel_times),1:tch,ersp_avgsub{ns1,ns2}(:,sel_times));shading flat; grid on
            caxis(amplim);
            title([levels_f1{ns1},'__', levels_f2{ns2}])
            line('XData', [0 0], 'YData', [1 tch], 'LineStyle', '--','LineWidth', 2, 'Color','k')
            xlabel('Times (ms)');
            set(gca,'YTick',1:tch,'YTicklabel',allch,'FontSize', 8)
            ylabel('Channels');
            cbar;%title('uV');
            if strcmp(ersp_measure, 'Pfu')
                title(['Delta %'])
            else
                title(['dB'])
            end
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'raw_ersp_grand_average';
            input.suffix_plot = ['raw_ersp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
            
            
            
            
        end
        
        
        
        
        
    end
    
    
else
    
    for ns2 = 1:s2 % per ciascun livello del primo fattore
        for ns1 = 1:s1 % per ogni livello del secondo fattore
            
            %             subplot(1,s1,ns1); % riempo un subplot della figura
            mat_ersp_plot = ersp_avgsub{ns1,ns2} .* p_grand_average;% calcolo la matrice che media sui soggetti(lascia x=tempi, y=canali)
            
            
            if not(isempty(select_tw_des{ns1,ns2}))
                
                tt1 = select_tw_des{ns1,ns2}(1);
                tt2 = select_tw_des{ns1,ns2}(2);
                sel_tt = times <tt1 | times > tt2;
                mat_ersp_plot(:,sel_tt)=0;
                
            end
            
            
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
                        imagesc(times(sel_times),1:tch,mat_ersp_plot(:,sel_times),'AlphaData',~isnan(mat_ersp_plot(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
%             pcolor(times(sel_times),1:tch,mat_ersp_plot(:,sel_times));shading flat;grid on
            
            
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
            
            
            cbar;%title('uV');
            if strcmp(ersp_measure, 'Pfu')
                title(['Delta %'])
            else
                title(['dB'])
            end
            %     end
            
            %     suptitle(levels_f1{ns1})
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'masked_ersp_grand_average';
            input.suffix_plot = ['masked_ersp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
            
            
            
            
            
            
            
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            
                        imagesc(times(sel_times),1:tch,ersp_avgsub{ns1,ns2}(:,sel_times),'AlphaData',~isnan(ersp_avgsub{ns1,ns2}(:,sel_times)));shading flat; grid on;%faccio il plot della matrice
%             pcolor(times(sel_times),1:tch,ersp_avgsub{ns1,ns2}(:,sel_times));shading flat;grid on
            
            
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
            
            
            cbar;%title('uV');
            if strcmp(ersp_measure, 'Pfu')
                title(['Delta %'])
            else
                title(['dB'])
            end
            %     end
            
            %     suptitle(levels_f1{ns1})
            
            input.plot_dir    = plot_dir;
            input.fig         = fig;
            input.name_embed  = 'raw_ersp_grand_average';
            input.suffix_plot = ['raw_ersp_grand_average_',levels_f1{ns1},'__',levels_f2{ns2}];
            save_figures(input);
            
            
        end
        
        
        
        
        
    end
    
end
end