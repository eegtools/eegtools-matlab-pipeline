% std_chantopo_erp() - plot ERP/spectral/ERSP topoplot at a specific
%                  latency/frequency. 
% Usage:
%          >> std_chantopo_erp( data, 'key', 'val', ...)
% Inputs:
%  data  -  [cell array] mean data for each subject group and/or data
%           condition. These arrays are usually returned by function
%           std_erspplot and std_erpplot. For example
%
%           >> data = { [1x64x12] [1x64x12 }; % 2 groups of 12 subjects, 64 channels
%           >> std_chantopo(data, 'chanlocs', 'chanlocfile.txt');
%
% Scalp map plotting option (mandatory):
%  'chanlocs'    - [struct] channel location structure
%
% Other scalp map plotting options:
%  'chanlocs'    - [struct] channel location structure
%  'topoplotopt' - [cell] topoplot options. Default is { 'style', 'both', 
%                  'shading', 'interp' }. See topoplot help for details.
%  'ylim'        - [min max] ordinate limits for ERP and spectrum plots
%                  {default: all available data}
%  'caxis'       - [min max] same as above
%
% Optional display parameters:
%  'datatype'    - ['erp'|'spec'] data type {default: 'erp'}
%  'titles'      - [cell array of string] titles for each of the subplots. 
%                  { default: none}
%  'subplotpos'  - [addr addc posr posc] perform ploting in existing figure.
%                  Add "addr" rows, "addc" columns and plot the scalp
%                  topographies starting at position (posr,posc).
%
% Statistics options:
%  'groupstats'  - [cell] One p-value array per group {default: {}}
%  'condstats'   - [cell] One p-value array per condition {default: {}}
%  'interstats'  - [cell] Interaction p-value arrays {default: {}}
%  'threshold'   - [NaN|real<<1] Significance threshold. NaN -> plot the 
%                  p-values themselves on a different figure. When possible, 
%                  significance regions are indicated below the data.
%                  {default: NaN}
%  'binarypval'  - ['on'|'off'] if a threshold is set, show only significant
%                  channels as red dots. Default is 'off'.
%
% Author: Arnaud Delorme, CERCO, CNRS, 2006-
%
% See also: pop_erspparams(), pop_erpparams(), pop_specparams(), statcond()
% Unfortunately in some recent versions of Matlab, saving vectorized version of figures has become difficult (artefacts in STUDY scalp topographies). Let us know if you find better solutions. 

function std_headplot_erp(input, varargin)


data                                                                       = input.data;
plot_dir                                                                   = input.plot_dir;
time_window_name                                                           = input.time_window_name; 
time_window                                                                = input.time_window;
name_f1                                                                    = input.name_f1; 
name_f2                                                                    = input.name_f2; 
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2; 
pmaskcond                                                                  = input.pmaskcond; 
pmaskgru                                                                   = input.pmaskgru; 
pmaskinter                                                                 = input.pmaskinter;
study_ls                                                                   = input.study_ls;

pgroup = [];
pcond  = [];
pinter = [];
if nargin < 2
    help std_chantopo;
    return;
end;

erp_topo_tw_roi_avg                                                        = input.erp_topo_tw_roi_avg;
plot_dir                                                                   = input.plot_dir;
roi_name                                                                   = input.roi_name;
chanlocs                                                                   = input.chanlocs;
time_window_name                                                           = input.time_window_name;
time_window                                                                = input.time_window;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
% pgroup                                                                     = input.pgroup;
% pcond                                                                      = input.pcond;
% study_ls                                                                   = input.study_ls;
% roi_mask                                                                   = input.roi_mask;
% compcond                                                                   = input.compcond;
% compgroup                                                                  = input.compgroup;
% show_head                                                                  = input.show_head;
compact_display_ylim                                                       = input.compact_display_ylim;
show_text                                                                  = input.show_text;
z_transform                                                                = input.z_transform;

%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');




colbk='white';


% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(erp_topo_tw_roi_avg);

% Markers=['o','x','+','*','s','d','v','^','<','>','p','h','.'];


% create a list of marker types
Markers=repmat(['o','x','+','*','s','d','v','^','<','>','p','h','.'],1,10);

tlf=max(tlf1,tlf2);
% create a list of colors
% list_col=hsv(tlf+1);
% list_col=repmat(hsv(5),10,1);
list_col=repmat(['b','m','g','r','c'],1,10);


erp_measure='uV';

if strcmp(z_transform,'on')
    erp_meaure='Z(ERP)';
end

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
%         pcomp=pgroup; % pgroup has for each condition (row), the comparison between groups (columns)
        levels_f=levels_f2;
        name_f=name_f2;
%         comp=compgroup;
    end
    if tlf1>1 % only one column (group), compare rows (conditions)
%         pcomp=pcond; % pcond has for each group (column), the comparison between conditions (rows)
        levels_f=levels_f1;
        name_f=name_f1;
        comp=compcond;
    end
    comparisons=comp{1};
    pcomparisons=pcomp{1};
  
    
    cell_error_bar = cell(tlf,1);
    
    for nlf=1:tlf
        cell_error_bar(nlf)=erp_topo_tw_roi_avg(nlf);
    end
    mm = mean([cell_error_bar{:}]);
    ss = std([cell_error_bar{:}]);
    
    if strcmp(z_transform,'on')
        for nlf=1:tlf
            cell_error_bar{nlf}=(cell_error_bar{nlf}-mm)/ss;
        end
        
        compact_display_ylim = [-1 1];
    end
    
    
    vec_mean=cellfun(@mean,cell_error_bar);
    vec_ster=cellfun(@std,cell_error_bar)./sqrt(cellfun(@length,cell_error_bar));
    %
    
    
    
    
    xlab=name_f;
    ylab=erp_measure;
    
    %comparisons = combn_all(1:tot_topo,2);
    num_comparisons = size(comparisons,2);
    signif_vec = pcomparisons < study_ls;
    signif_pairs = comparisons(:,signif_vec);
    
    % create figure
    fig=figure( 'Visible', 'off');
    if strcmp(show_head,'on')
        
        % create topo plots
        set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2], 'Visible', 'off');
        
        topoplot(roi_mask,chanlocs,'style','blank');set(fig, 'Visible', 'off');
        set(gca,'color',colbk);set(fig, 'Visible', 'off');
        set(gca,'FontSize',10);set(fig, 'Visible', 'off');
        
        set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6], 'Visible', 'off');set(fig, 'Visible', 'off');
        set(gca, 'LineWidth', 1.2);set(fig, 'Visible', 'off');
        %         nm=1;
        %         for nlf=1:tlf
        %             if nm > length(Markers)
        %                 nm=1;
        %             end
        %             errorbar(nlf,vec_mean(nlf),vec_ster(nlf),Markers(nm),'col',list_col(nlf),'LineWidth',2,'MarkerSize',10)
        %             nm=nm+1;
        %             hold on
        %         end
    end
    % CLA old version with only one color
    %     errorbar(vec_mean,vec_ster,'d','MarkerSize',10);set(gcf, 'Visible', 'off');
    
    % CLA new version with different colors for different bars
    for nn=1:length(vec_mean)
        plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
        hold on
        errorbar(nn,vec_mean(nn),vec_ster(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(fig, 'Visible', 'off');
        hold on
    end
    
    
    
    set(gca,'XTick',1:(length(levels_f)));set(fig, 'Visible', 'off');
    set(gca,'XTickLabel',levels_f);set(fig, 'Visible', 'off');
    set(gca,'FontSize',10);set(fig, 'Visible', 'off');
    
    xlabel(xlab)
    ylabel(ylab)
    
    hold on
    
    upbar=max(vec_mean+vec_ster);
    dowbar=min(vec_mean-vec_ster);
    
    range_error_bar=[upbar dowbar];
    deltay=abs(diff(range_error_bar))/4;
    
    
    % CLA old version with stars and horizontal lines denoting significant differences
    
    %     if ~ isempty(signif_pairs)
    %         yval_min=dowbar-deltay/2;
    %         yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
    %         ylim([yval_min yval_max]);
    %
    %
    %
    %         for i  = 1:size(signif_pairs,2)
    %             offset_segment=upbar+(i)*deltay;
    %             offset_star=offset_segment+deltay*0.2;
    %             plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
    %             plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
    %             plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
    %             text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
    %         end
    %     end
    %
    %     if ~isempty(compact_display_ylim)
    %         ylim(compact_display_ylim)
    %     end
    
    % CLA new version with only horizontal lines denoting significant
    % differences
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
    %         suptitle({['ERP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });
    set(fig, 'Visible', 'off');
    
    hold off
    if (strcmp(show_text,'on'))
        suptitle({['ERP in ',roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms):'],   name_f });
    end
    
    if (strcmp(show_text,'off'))
        fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
        
    end
    
    % %          set(fig, 'paperpositionmode', 'auto');
    % %          setfont(fig, 'fontsize', 16);
    % set(fig, 'renderer', 'zbuffer')
    %           name_plot=fullfile(plot_dir,['erp_topo_tw_',char(roi_name),'_',char(name_f),'_',char(time_window_name)]);
    %              saveas(fig, [name_plot,'.fig']);
    %              saveas(fig,[name_plot,'.eps'],'epsc');
    %              plot2svg([name_plot,'.svg'])
    %
    %
    %
    %          os = system_dependent('getos');
    %          if ~ strncmp(os,'Linux',2)
    %             print(fig,fullfile(plot_dir,'erp_topo_tw.ps'),'-append','-dwinc')
    %            saveppt2(fullfile(plot_dir,'erp_topo_tw.ppt'),'f',fig);
    %          else
    %             print(fig,fullfile(plot_dir,'erp_topo_tw.ps'),'-append')
    %          end
    %          ps2pdf('psfile',fullfile(plot_dir,'erp_topo_tw.ps'),'pdffile',fullfile(plot_dir,'erp_topo_tw.pdf'))
    % %          file_tiff=['erp_topo_tw_',char(roi_name),'_',char(name_f),'_',char(time_window_name),'.tif'];
    % %          print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
    
    
    % name_embed=fullfile(plot_dir,'erp_topo_tw');
    % name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',char(time_window_name)];
    % set(fig, 'renderer', 'painter');set(gcf, 'Visible', 'off');
    % modify_plot(fig);set(gcf, 'Visible', 'off');
    % saveas(fig, [name_plot,'.fig']);
    % print([name_plot,'.eps'],'-depsc2','-r300');
    % plot2svg([name_plot,'.svg'])
    % os = system_dependent('getos');
    % if ~ strncmp(os,'Linux',2)
    %     print(fig,[name_embed,'.ps'],'-append','-dwinc')
    %     saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
    % else
    %     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
    % end
    % export_fig(fig,[name_embed,'.pdf'], '-pdf', '-append')
    %
    %
    %          close(fig)
    
    
    input_save_fig.plot_dir               = plot_dir;
    input_save_fig.fig                    = fig;
    input_save_fig.name_embed             = 'erp_topo_tw';
    input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(time_window_name)];
    
    save_figures( input_save_fig )
    
end


if tlf1 > 1 && tlf2 > 1
    tlf_within=tlf1; % fix the row (condition) and tlf_within2>1 (compare columns, i.e. groups)
    tlf_between=tlf2;
    %     list_col=hsv(tlf_between+1);
    
    for nlf_within=1:tlf_within
        pcomp=pgroup(nlf_within); % pgroup has for each condition (row), the comparison between groups (columns)
        levels_f=levels_f2;
        name_f=name_f2;
        name_ff=levels_f1{nlf_within};
        comp=compgroup(nlf_within);
        comparisons=comp{1};
        pcomparisons=pcomp{1};
        
        
        
        %         mat_error_bar=[];
        %         for nlf=1:tlf_between
        %             mat_error_bar(:,nlf)=erp_topo_tw_roi_avg{nlf_within,nlf};
        %         end
        %
        %         if strcmp(z_transform,'on')
        %             mat_error_bar=(mat_error_bar-mean(mean(mat_error_bar)))/std(mat_error_bar(:));
        %             compact_display_ylim = [-1 1];
        %         end
        %
        %
        %         vec_mean=mean(mat_error_bar,1);
        %         vec_ster=std(mat_error_bar,0,1)/sqrt(size(mat_error_bar,1));
        
        
        cell_error_bar = cell(tlf_between,1);
        
        for nlf=1:tlf_between
            cell_error_bar(nlf)=erp_topo_tw_roi_avg(nlf_within,nlf);
        end
        mm = mean([cell_error_bar{:}]);
        ss = std([cell_error_bar{:}]);
        
        if strcmp(z_transform,'on')
            for nlf=1:tlf
                cell_error_bar{nlf}=(cell_error_bar{nlf}-mm)/ss;
            end
            
            compact_display_ylim = [-1 1];
        end
        
        
        vec_mean=cellfun(@mean,cell_error_bar);
        vec_ster=cellfun(@std,cell_error_bar)./sqrt(cellfun(@length,cell_error_bar));
        
        
        xlab=name_f;
        ylab=erp_measure;
        
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec = pcomparisons < study_ls;
        signif_pairs = comparisons(:,signif_vec);
        
        % create figure
        % create figure
        fig=figure( 'Visible', 'off');
        if strcmp(show_head,'on')
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2], 'Visible', 'off');set(fig, 'Visible', 'off');
            
            topoplot(roi_mask,chanlocs,'style','blank');set(fig, 'Visible', 'off');
            set(gca,'color',colbk);set(fig, 'Visible', 'off');
            set(gca,'FontSize',10);set(fig, 'Visible', 'off');
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6], 'Visible', 'off');set(fig, 'Visible', 'off');
            set(gca, 'LineWidth', 1.2);set(fig, 'Visible', 'off');
            %         nm=1;
            %         for nlf=1:tlf
            %             if nm > length(Markers)
            %                 nm=1;
            %             end
            %             errorbar(nlf,vec_mean(nlf,:),vec_ster(nlf,:),Markers(nm),'col',list_col(nlf),'LineWidth',2,'MarkerSize',10)
            %             nm=nm+1;
            %             hold on
            %         end
        end
        %         errorbar(vec_mean,vec_ster,'d','MarkerSize',10);set(gcf, 'Visible', 'off');
        
        for nn=1:length(vec_mean)
            plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
            hold on
            errorbar(nn,vec_mean(nn),vec_ster(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(fig, 'Visible', 'off');
            hold on
        end
        
        
        
        
        set(gca,'XTick',1:(length(levels_f)));set(fig, 'Visible', 'off');
        set(gca,'XTickLabel',levels_f);set(fig, 'Visible', 'off');
        set(gca,'FontSize',10);set(fig, 'Visible', 'off');
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        
        upbar=max(vec_mean+vec_ster);
        dowbar=min(vec_mean-vec_ster);
        
        range_error_bar=[upbar dowbar];
        deltay=abs(diff(range_error_bar))/4;
        
        %         if ~ isempty(signif_pairs)
        %             yval_min=dowbar-deltay/2;
        %             yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
        %             ylim([yval_min yval_max]);
        %
        %
        %             for i  = 1:size(signif_pairs,2)
        %                 offset_segment=upbar+(i)*deltay;
        %                 offset_star=offset_segment+deltay*0.2;
        %                 plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
        %                 plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
        %                 plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
        %                 text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
        %             end
        %         end
        %         if ~isempty(compact_display_ylim)
        %             ylim(compact_display_ylim)
        %         end
        
        
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
        %             hold off
        %             suptitle({['ERP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});
        %
        %              fig=gcf;
        
        hold off
        if (strcmp(show_text,'on'))
            suptitle({['ERP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f, ' within ', name_ff ]});
        end
        
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
            
        end
        
        
        %             set(fig, 'paperpositionmode', 'auto');
        %          setfont(fig, 'fontsize', 16);
        
        % set(fig, 'renderer', 'painter')
        %              name_plot=fullfile(plot_dir,['erp_topo_tw_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name)]);
        %              saveas(fig, [name_plot,'.fig']);
        %              saveas(fig,[name_plot,'.eps'],'epsc');
        %              plot2svg([name_plot,'.svg'])
        %
        %
        %
        %              os = system_dependent('getos');
        %              if ~ strncmp(os,'Linux',2)
        %                 print(fig,fullfile(plot_dir,'erp_topo_tw.ps'),'-append','-dwinc')
        %                saveppt2(fullfile(plot_dir,'erp_topo_tw.ppt'),'f',fig);
        %              else
        %                 print(fig,fullfile(plot_dir,'erp_topo_tw.ps'),'-append')
        %              end
        %              ps2pdf('psfile',fullfile(plot_dir,'erp_topo_tw.ps'),'pdffile',fullfile(plot_dir,'erp_topo_tw.pdf'))
        % %              file_tiff=['erp_topo_tw_',char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name),'.tif'];
        % %              print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
        
        
        % name_embed=fullfile(plot_dir,'erp_topo_tw');
        % name_plot=[name_embed,'_', char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name)];
        % set(fig, 'renderer', 'painter')
        % modify_plot(fig);
        % saveas(fig, [name_plot,'.fig']);
        % print([name_plot,'.eps'],'-depsc2','-r300');
        % plot2svg([name_plot,'.svg'])
        % os = system_dependent('getos');
        % if ~ strncmp(os,'Linux',2)
        %     print(fig,[name_embed,'.ps'],'-append','-dwinc')
        %     saveppt2(fullfile(plot_dir,'ersp_tf.ppt'),'f',fig);
        % else
        %     print(fig,[name_embed,'.ps'],'-append','-painter','-r300')
        % end
        % export_fig([name_embed,'.pdf'], '-pdf', '-append')
        %
        %              close(fig)
        
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'erp_topo_tw';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name)];
        
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
        
        %         mat_error_bar=[];
        %         for nlf=1: tlf_between
        %             mat_error_bar(:,nlf)=erp_topo_tw_roi_avg{nlf,nlf_within};
        %         end
        %
        %         if strcmp(z_transform,'on')
        %             mat_error_bar=(mat_error_bar-mean(mean(mat_error_bar)))/std(mat_error_bar(:));
        %             compact_display_ylim = [-1 1];
        %         end
        %
        %         vec_mean=mean(mat_error_bar,1);
        %         vec_ster=std(mat_error_bar,0,1)/sqrt(size(mat_error_bar,1));
        %
        
        cell_error_bar = cell(tlf_between,1);
        
        for nlf=1:tlf_between
            cell_error_bar(nlf)=erp_topo_tw_roi_avg(nlf,nlf_within);
        end
        mm = mean([cell_error_bar{:}]);
        ss = std([cell_error_bar{:}]);
        
        if strcmp(z_transform,'on')
            for nlf=1:tlf
                cell_error_bar{nlf}=(cell_error_bar{nlf}-mm)/ss;
            end
            
            compact_display_ylim = [-1 1];
        end
        
        
        vec_mean=cellfun(@mean,cell_error_bar);
        vec_ster=cellfun(@std,cell_error_bar)./sqrt(cellfun(@length,cell_error_bar));
        
        
        xlab=name_f;
        ylab=erp_measure;
        
        %comparisons = combn_all(1:tot_topo,2);
        num_comparisons = size(comparisons,2);
        signif_vec = pcomparisons < study_ls;
        signif_pairs = comparisons(:,signif_vec);
        
        % create figure
        fig=figure( 'Visible', 'off');
        
        if strcmp(show_head,'on')
            
            % create topo plots
            set(subplot(2,1,1), 'Position',[0.4, 0.75, 0.2, 0.2], 'Visible', 'off');
            
            topoplot(roi_mask,chanlocs,'style','blank');set(fig, 'Visible', 'off');
            set(gca,'color',colbk);set(fig, 'Visible', 'off');
            set(gca,'FontSize',10);set(fig, 'Visible', 'off');
            
            set(subplot(2,1,2), 'Position', [0.1, 0.1, 0.8, 0.6], 'Visible', 'off');set(fig, 'Visible', 'off');
            set(gca, 'LineWidth', 1.2);set(fig, 'Visible', 'off');
            %         nm=1;
            %         for nlf=1:tlf
            %             if nm > length(Markers)
            %                 nm=1;
            %             end
            %             errorbar(nlf,vec_mean(nlf,:),vec_ster(nlf,:),Markers(nm),'col',list_col(nlf),'LineWidth',2,'MarkerSize',10)
            %             nm=nm+1;
            %             hold on
            %         end
        end
        %         errorbar(vec_mean,vec_ster,'d','MarkerSize',10);set(gcf, 'Visible', 'off');
        
        
        for nn=1:length(vec_mean)
            plot(nn, vec_mean(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);
            hold on
            errorbar(nn,vec_mean(nn),vec_ster(nn),Markers(nn),'col',list_col(nn),'LineWidth',2,'MarkerSize',10);set(fig, 'Visible', 'off');
            hold on
        end
        
        set(gca,'XTick',1:(length(levels_f)));set(fig, 'Visible', 'off');
        set(gca,'XTickLabel',levels_f);set(fig, 'Visible', 'off');
        set(gca,'FontSize',10);set(fig, 'Visible', 'off');
        
        xlabel(xlab)
        ylabel(ylab)
        
        hold on
        upbar=max(vec_mean+vec_ster);
        dowbar=min(vec_mean-vec_ster);
        
        range_error_bar=[upbar dowbar];
        deltay=abs(diff(range_error_bar))/4;
        
        %         if ~ isempty(signif_pairs)
        %             yval_min=dowbar-deltay/2;
        %             yval_max=upbar+1.1*deltay*(size(signif_pairs,2)+0.5)    ;
        %             ylim([yval_min yval_max]);
        %
        %
        %             for i  = 1:size(signif_pairs,2)
        %                 offset_segment=upbar+(i)*deltay;
        %                 offset_star=offset_segment+deltay*0.2;
        %                 plot([signif_pairs(1,i) signif_pairs(2,i)], [offset_segment offset_segment],'col','black','LineWidth',1.5)
        %                 plot([signif_pairs(1,i) signif_pairs(1,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
        %                 plot([signif_pairs(2,i) signif_pairs(2,i)], [offset_segment offset_segment-deltay*0.2],'col','black','LineWidth',1.5)
        %                 text(mean([signif_pairs(2,i),signif_pairs(1,i)]), offset_star,'*','FontSize',15,'LineWidth',2)
        %             end
        %         end
        %         if ~isempty(compact_display_ylim)
        %             ylim(compact_display_ylim)
        %         end
        
        
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
        %             hold off
        %             suptitle({['ERP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});
        %
        %              fig=gcf;
        
        hold off
        if (strcmp(show_text,'on'))
            suptitle({['ERP in ' ,roi_name,' during ',time_window_name,' time-window ','([',num2str(time_window),']ms): '],   [name_f , ' within ', name_ff ]});
        end
        
        if (strcmp(show_text,'off'))
            fig=modify_plot(fig, 'new_xticklab',[], 'new_yticklab',[],'new_xlab',[],'new_ylab','','new_title',[]);
            
        end
        
       
        
        
        input_save_fig.plot_dir               = plot_dir;
        input_save_fig.fig                    = fig;
        input_save_fig.name_embed             = 'erp_headplot_tw';
        input_save_fig.suffix_plot            = [ char(roi_name),'_',char(name_f),'_',char(name_ff),'_',char(time_window_name)];
        
        save_figures( input_save_fig )
        
        
    end
    
    
    
    
    
end
end
