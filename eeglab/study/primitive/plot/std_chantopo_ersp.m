% std_chantopo_ersp() - plot ERP/spectral/ERSP topoplot at a specific
%                  latency/frequency. 
% Usage:
%          >> std_chantopo( data, 'key', 'val', ...)
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
% % Unfortunately in some recent versions of Matlab, saving vectorized version of figures has become difficult (artefacts in STUDY scalp topographies). Let us know if you find better solutions. 

function std_chantopo_ersp(input,varargin)
data                                                                       = input.data;
plot_dir                                                                   = input.plot_dir;
time_window_name                                                           = input.time_window_name;
time_window                                                                = input.time_window;
frequency_band_name                                                        = input.frequency_band_name;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
pmaskcond                                                                  = input.pmaskcond;
pmaskgru                                                                   = input.pmaskgru;
pmaskinter                                                                 = input.pmaskinter;
ersp_measure                                                               = input.ersp_measure;
study_ls                                                                   = input.study_ls;


strfname = char([ name_f1, '_', name_f2]);


pgroup = [];
pcond  = [];
pinter = [];
if nargin < 2
    help std_chantopo;
    return;
end;

opt = finputcheck( varargin, { 'ylim'        'real'    []              [];
                               'titles'      'cell'    []              cell(20,20);
                               'threshold'   'real'    []              NaN;
                               'chanlocs'    'struct'  []              struct('labels', {});
                               'groupstats'  'cell'    []              {};
                               'condstats'   'cell'    []              {};
                               'interstats'  'cell'    []              {};
                               'subplotpos'  'integer' []              [];
                               'topoplotopt' 'cell'    []              { 'style', 'both' };
                               'binarypval'  'string'  { 'on','off' }  'on';
                               'datatype'    'string'  { 'ersp','itc','erp','spec' }    'erp';
                               'caxis'       'real'    []              [] }, 'std_chantopo', 'ignore'); %, 'ignore');
if isstr(opt), error(opt); end;
if ~isempty(opt.ylim), opt.caxis = opt.ylim; end;
if isnan(opt.threshold), opt.binarypval = 'off'; end;
if strcmpi(opt.binarypval, 'on'), opt.ptopoopt = { 'style' 'blank' }; else opt.ptopoopt = opt.topoplotopt; end;

% remove empty entries
datapresent = ~cellfun(@isempty, data);
for c = size(data,1):-1:1, if sum(datapresent(c,:)) == 0, data(c,:) = []; opt.titles(c,:) = []; if ~isempty(opt.groupstats), opt.groupstats(c) = []; end; end; end;
for g = size(data,2):-1:1, if sum(datapresent(:,g)) == 0, data(:,g) = []; opt.titles(:,g) = []; if ~isempty(opt.condstats ), opt.condstats( g) = []; end; end; end;

nc = size(data,1);
ng = size(data,2);
if nc >= ng, opt.transpose = 'on';
else         opt.transpose = 'off';
end;

set(0, 'DefaultFigureRendererMode', 'manual')
set(0,'DefaultFigureRenderer','zbuffer')

% plotting paramters
% ------------------
if ng > 1 & ~isempty(opt.groupstats), addc = 1; else addc = 0; end;
if nc > 1 & ~isempty(opt.condstats ), addr = 1; else addr = 0; end;
if ~isempty(opt.subplotpos), 
     if strcmpi(opt.transpose, 'on'), opt.subplotpos = opt.subplotpos([2 1 4 3]); end;
     addr = opt.subplotpos(1);
     addc = opt.subplotpos(2);
     posr = opt.subplotpos(4);
     posc = opt.subplotpos(3);
else posr = 0;
     posc = 0;
end;

% % compute significance mask
% % -------------------------
% if ~isempty(opt.interstats), pinter = opt.interstats{3}; end;


% compute significance mask
% --------------------------
if ~isempty(opt.interstats), pinter = opt.interstats{3}; 

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORREGGO BACO INTERAZIONE
%     pinter_corr=[];    
%     for ind = 1:length(opt.condstats)
%         pinter_corr(:,:,ind)  = opt.condstats{ind};
%     end;    
%     for ind = 1:length(opt.groupstats)
%         pinter_corr(:,:,(ind+length(opt.condstats))) = opt.groupstats{ind};         
%     end;    
%     if isnan(opt.threshold)
%         pinter=min(pinter_corr,[],3);
%     else
%        pinter=max(pinter_corr,[],3); 
%     end
%     
%     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end;

if ~isnan(opt.threshold(1)) && ( ~isempty(opt.groupstats) || ~isempty(opt.condstats) )    
    pcondplot  = opt.condstats;
    pgroupplot = opt.groupstats;
    pinterplot = pinter;
    maxplot = 1;
else
    for ind = 1:length(opt.condstats),  pcondplot{ind}  = -log10(opt.condstats{ind}); end;
    for ind = 1:length(opt.groupstats), pgroupplot{ind} = -log10(opt.groupstats{ind}); end;
    if ~isempty(pinter), pinterplot = -log10(pinter); end;
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLA
%     maxplot = 3;
    matp=[];
    
    if ~isempty(opt.condstats)
        for nind=1:length(pcondplot)    
            matp=[matp,pcondplot{nind}];
        end
    end
    
    if ~isempty(opt.groupstats)
        for nind=1:length(pgroupplot)
            matp=[matp, pgroupplot{nind}];
        end
    end
    
    if ~isempty(opt.interstats)
        matp=[matp, pinter];
    end
    
     sls=-log10(study_ls);
    maxplot = max( sls,(1+ceil(max(max(matp)))));
   
    
end;


% adjust figure size
% ------------------
if isempty(opt.subplotpos)
      fig=figure( 'color', 'w', 'Visible', 'off');
    set(0, 'DefaultFigureRendererMode', 'manual')
    set(0,'DefaultFigureRenderer','zbuffer')
    
    pos = get(fig, 'position');
    set(fig, 'position', [ pos(1)+15 pos(2)+15 pos(3)/2.5*(nc+addr), pos(4)/2*(ng+addc) ]);set(gcf, 'Visible', 'off')
    
    
    
    pos = get(fig, 'position');
    if strcmpi(opt.transpose, 'off'), set(gcf, 'position', [ pos(1) pos(2) pos(4) pos(3)]);
    else                              set(gcf, 'position', pos);
    end;
end

set(0, 'DefaultFigureRendererMode', 'manual')
set(0,'DefaultFigureRenderer','zbuffer')

mask_surface =~(isempty(pmaskgru) & isempty(pmaskcond));


% topoplot
% --------
tmpc = [inf -inf];
for c = 1:nc
    for g = 1:ng
        hdl(c,g) = mysubplot(nc+addr, ng+addc, g + posr + (c-1+posc)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off')
        if ~isempty(data{c,g})
            tmpplot = double(mean(data{c,g},3));
            if ~all(isnan(tmpplot))
                 if  ~mask_surface
                    topoplot( tmpplot, opt.chanlocs, opt.topoplotopt{:});set(gcf, 'Visible', 'off')
                 end
                if  mask_surface
                    p1=pmaskgru;
                    p2=pmaskcond;
                    if isempty(p1)
                        p1{c}=zeros(size(p2{g}));
                    end
                    if isempty(p2)
                        p2{g}=zeros(size(p1{c}));
                    end
                    ptopo=p1{c}+p2{g};

%                     topoplot( tmpplot.* ptopo, opt.chanlocs,'style','map');
                    topoplot( tmpplot, opt.chanlocs,'style','map');set(gcf, 'Visible', 'off')
               end
                if isempty(opt.caxis)
                    tmpc = [ min(min(tmpplot), tmpc(1)) max(max(tmpplot), tmpc(2)) ];
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLA
%                     tmpc = [ min(-max(abs(tmpplot)), tmpc(1)) max(max(abs(tmpplot)), tmpc(2)) ];
                    
                    
                    
                else 
                    caxis(opt.caxis);
                end;
                title(opt.titles{c,g}, 'interpreter', 'none'); 
            else
                axis off;
            end;
        else
            axis off;
        end;

        % statistics accross groups
        % -------------------------
        if g == ng & ng > 1 & ~isempty(opt.groupstats)
            hdl(c,g+1) = mysubplot(nc+addr, ng+addc, g + posr + 1 + (c-1+posc)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off')
             if isempty(pmaskgru)
            topoplot( pgroupplot{c}, opt.chanlocs, opt.ptopoopt{:});set(gcf, 'Visible', 'off')
             end
             if ~isempty(pmaskgru)
                 if sum(sum(pmaskgru{c}))>0
                    topoplot_masked(pmaskgru{c}, opt.chanlocs, 'style','map','pmask',pmaskgru{c},'threshold',study_ls);set(gcf, 'Visible', 'off')
                 else
                    topoplot_masked(pmaskgru{c}, opt.chanlocs,'style','blank');set(gcf, 'Visible', 'off')
                 end
                 caxis([-1000 1]);    
             else
                 topoplot(pgroupplot{c}, opt.chanlocs, opt.ptopoopt{:});set(gcf, 'Visible', 'off')
                 caxis([-maxplot maxplot]);   
             end
            title(opt.titles{c,g+1}); 


            
        end;
    end;
end;
        
% color scale
% -----------
if isempty(opt.caxis)
    for c = 1:nc
        for g = 1:ng
            axes(hdl(c,g));
            caxis(tmpc);
        end;
    end;
end;

for g = 1:ng
    % statistics accross conditions
    % -----------------------------
    if ~isempty(opt.condstats) && nc > 1
        hdl(nc+1,g) = mysubplot(nc+addr, ng+addc, g + posr + (c+posc)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off')
        
        if ~isempty(pmaskcond)
            if sum(sum(pmaskcond{g}))>0
                topoplot_masked(pmaskcond{g}, opt.chanlocs, 'style','map','pmask',pmaskcond{g},'threshold',study_ls);set(gcf, 'Visible', 'off')
            else
                topoplot_masked(pmaskcond{g}, opt.chanlocs,'style','blank');set(gcf, 'Visible', 'off')
            end
            caxis([-1000 1]);    
        else
            topoplot( pcondplot{g}, opt.chanlocs, opt.ptopoopt{:});set(gcf, 'Visible', 'off')
            caxis([-maxplot maxplot]);   
        end
        title(opt.titles{nc+1,g}); 
        
    end;
end;

% statistics accross group and conditions
% ---------------------------------------
if ~isempty(opt.condstats) && ~isempty(opt.groupstats) && ng > 1 && nc > 1
    hdl(nc+1,ng+1) = mysubplot(nc+addr, ng+addc, g + posr + 1 + (c+posc)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off')
    
    if ~isempty(pmaskinter)
        if sum(sum(pmaskinter{3}))>0
               topoplot_masked(pmaskinter{3}, opt.chanlocs,'style','map','pmask',pmaskinter{3},'threshold',study_ls);set(gcf, 'Visible', 'off')
        else
            topoplot_masked(pmaskinter{3}, opt.chanlocs,'style','blank');set(gcf, 'Visible', 'off')
        end
        caxis([-1000 1]);
    else
        topoplot( pinterplot, opt.chanlocs, opt.ptopoopt{:});set(gcf, 'Visible', 'off')
        caxis([-maxplot*1000 maxplot]);
    end
    title(opt.titles{nc+1,ng+1});     

end;    

% color bars
% ----------
axes(hdl(nc,ng)); 
cbar_standard(opt.datatype, ng);
if isnan(opt.threshold(1)) && (nc ~= size(hdl,1) || ng ~= size(hdl,2))
    axes(hdl(end,end));
    if ~mask_surface
        cbar_signif(ng, maxplot);
    end
    
end;

% remove axis labels
% ------------------
for c = 1:size(hdl,1)
    for g = 1:size(hdl,2)
        if g ~= 1 && size(hdl,2) ~=1, ylabel(''); end;
        if c ~= size(hdl,1) && size(hdl,1) ~= 1, xlabel(''); end;
    end;
end;


 tlf1=length(levels_f1);
 tlf2=length(levels_f2);
 
 switch ersp_measure     
     case 'dB'
         ersp_meaure='dB';
     case 'Pfu'
         ersp_meaure='Delta %';
 end
         
 if ~mask_surface  
    if tlf1 > 1 && tlf2 <= 1
          suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',  name_f1 ]);    

    end         
    if tlf1 <=1 && tlf2 > 1
       suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',   name_f2 ]);    

    end
    if tlf1 > 1 && tlf2 > 1 
        suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',  name_f1 ' and ' name_f2 ]);    

    end 
 else
    if tlf1 > 1 && tlf2 <= 1
          suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',  name_f1]);    

    end         
    if tlf1 <=1 && tlf2 > 1
       suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',   name_f2]);    

    end
    if tlf1 > 1 && tlf2 > 1 
        suptitle([frequency_band_name, ' ERSP (', ersp_meaure,') in the ' ,time_window_name,' time-window ','[',num2str(time_window),']: ',  name_f1 ' and ' name_f2]);    

    end  
     
 end


% name_embed=fullfile(plot_dir,'esrp_topo'); 
% name_plot=[name_embed,'_',time_window_name,'_',char(frequency_band_name)];
% set(fig, 'renderer', 'painter');set(gcf, 'Visible', 'off')
% modify_plot(fig);set(gcf, 'Visible', 'off')
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
% export_fig(fig,[name_embed,'.pdf'], '-pdf', '-append')     
 

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = [strfname,'_','esrp_topo'];
input_save_fig.suffix_plot            = [time_window_name,'_',char(frequency_band_name)];

save_figures( input_save_fig ,'exclude_format',{'svg'},'renderer', 'opengl')
 
% set(fig, 'paperpositionmode', 'auto');
% setfont(fig, 'fontsize', 16);
% name_plot=fullfile(plot_dir,['esrp_topo_',time_window_name,'_',char(frequency_band_name)]);
% saveas(fig, [name_plot,'.fig']);
% saveas(fig,[name_plot,'.eps'],'epsc');
% %plot2svg([name_plot,'.svg']) 
% 
% 
% % file_tiff=['esrp_topo_',time_window_name,'_',char(frequency_band_name),'.tif'];
% % print(fig,fullfile(plot_dir,file_tiff),'-dtiff')
% 
% os = system_dependent('getos');
% if ~ strncmp(os,'Linux',2) 
%     print(fig,fullfile(plot_dir,'esrp_topo.ps'),'-append','-dwinc')
%     saveppt2(fullfile(plot_dir,'esrp_topo.ppt'),'f',fig);
%    
% else
% %     set(gcf,'Renderer','painters')
%     print(fig,fullfile(plot_dir,'esrp_topo.ps'),'-append','-zbuffer','-r200')
% % print(fig,fullfile(plot_dir,'esrp_topo.ps'),'-append')
%     
% %     str=['ps2pdf ',fullfile(plot_dir,'esrp_topo.ps'), ' ',fullfile(plot_dir,'esrp_topo.pdf' )];    
% %     system(str);
% end
%  
% 
% ps2pdf('psfile',fullfile(plot_dir,'esrp_topo.ps'),'pdffile',fullfile(plot_dir,'esrp_topo.pdf'))


% close(fig)

% colorbar for ERSP and scalp plot
% --------------------------------
function cbar_standard(datatype, ng);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+pos(3)/fact pos(2) pos(3)/fact pos(4) ]);  
    set(gca, 'unit', 'normalized');
    if strcmpi(datatype, 'itc')
         cbar(tmp, 0, tmpc, 10); ylim([0.5 1]);
    else cbar(tmp, 0, tmpc, 5);
    end;

% colorbar for significance
% -------------------------
function cbar_signif(ng, maxplot);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+pos(3)/fact pos(2) pos(3)/fact pos(4) ]);  
    map = colormap;
    n = size(map,1);
    cols = [ceil(n/2):n]';
    image([0 1],linspace(0,maxplot,length(cols)),[cols cols]);
    %cbar(tmp, 0, tmpc, 5);
    tick = linspace(0, maxplot, maxplot+1);
    set(gca, 'ytickmode', 'manual', 'YAxisLocation', 'right', 'xtick', [], ...
        'ytick', tick, 'yticklabel', round(10.^-tick*1000)/1000);
    xlabel('');

% mysubplot (allow to transpose if necessary)
% -------------------------------------------
function hdl = mysubplot(nr,nc,ind,transp);

    r = ceil(ind/nc);
    c = ind -(r-1)*nc;
    if strcmpi(transp, 'on'), hdl = subplot(nc,nr,(c-1)*nr+r);
    else                      hdl = subplot(nr,nc,(r-1)*nc+c);
    end;

