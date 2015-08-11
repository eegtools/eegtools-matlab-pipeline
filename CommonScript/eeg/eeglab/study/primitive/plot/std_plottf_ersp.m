% std_plottf_ersp() - plot ERSP/ITC images a component
%              or channel cluster in a STUDY. Also allows plotting scalp
%              maps.
% Usage:
%          >> std_plottf( times, freqs, data, 'key', 'val', ...)
% Inputs:
%  times - [vector] latencies in ms of the data points.
%  freqs - [vector] frequencies in Hz of the data points.
%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to plot mean ERPs from a STUDY 
%           for epochs of 800 frames in two conditions from three groups 
%           of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> std_plottf(erp_ms,data);
%
%           By default, parametric statistics are computed across subjects 
%           in the three groups. (group,condition) ERP averages are plotted. 
%           See below and >> help statcond 
%           for more information about the statistical computations.
%
% Optional display parameters:
%  'datatype'    - ['ersp'|'itc'] data type {default: 'ersp'}
%  'titles'      - [cell array of string] titles for each of the subplots. 
%                  { default: none}
%
% Statistics options:
%  'groupstats'  - ['on'|'off'] Compute (or not) statistics across groups.
%                  {default: 'off'}
%  'condstats'   - ['on'|'off'] Compute (or not) statistics across groups.
%                  {default: 'off'}

%  'threshold'   - [NaN|real<<1] Significance threshold. NaN -> plot the 
%                  p-values themselves on a different figure. When possible, 
%                  significance regions are indicated below the data.
%                  {default: NaN}
%  'maskdata'    - ['on'|'off'] when threshold is non-NaN and not both 
%                  condition and group statistics are computed, the user 
%                  has the option to mask the data for significance.
%                  {defualt: 'off'}
%
% Other plotting options:
%  'plotmode'    - ['normal'|'condensed'] statistics plotting mode:
%                  'condensed' -> plot statistics under the curves 
%                  (when possible); 'normal' -> plot them in separate 
%                  axes {default: 'normal'}
%  'freqscale'   - ['log'|'linear'|'auto'] frequency plotting scale. This
%                  will only change the ordinate not interpolate the data.
%                  If you change this option blindly, your frequency scale
%                  might be innacurate {default: 'auto'}
%  'ylim'        - [min max] ordinate limits for ERP and spectrum plots
%                  {default: all available data}
%
% ITC/ERSP image plotting options:
%  'tftopoopt'   - [cell array] tftopo() plotting options (ERSP and ITC)
%  'caxis'       - [min max] color axis (ERSP, ITC, scalp maps)
%
% Scalp map plotting options:
%  'chanlocs'    - [struct] channel location structure
%
% Author: Arnaud Delorme, CERCO, CNRS, 2006-
%
% See also: pop_erspparams(), pop_erpparams(), pop_specparams(), statcond()

% Copyright (C) 2006 Arnaud Delorme
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [pgroup, pcond, pinter] = std_plottf_ersp(input,varargin)

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
ersp_mode                                                                  = input.ersp_mode;
% group_time_windows_list                                                    = input.group_time_windows_list;
frequency_bands_list                                                       = input.frequency_bands_list;
display_pmode                                                              = input.display_pmode;

pgroup = [];
pcond  = [];
pinter = [];

% cla
close all

if nargin < 2
    help std_plottf;
    return;
end;

opt = finputcheck( varargin, { 'titles'         'cell'   []              cellfun(@num2str, cell(20,20), 'uniformoutput', false);
                               'caxis'          'real'   []              [];
                               'ersplim'        'real'   []              []; % same as above
                               'itclim'         'real'   []              []; % same as above
                               'ylim'           'real'   []              [];
                               'tftopoopt'      'cell'   []              {};
                               'threshold'      'real'   []              NaN;
                               'unitx'          'string' []              'ms'; % just for titles
                               'chanlocs'       'struct' []              struct('labels', {});
                               'freqscale'      'string' { 'log','linear','auto' }  'auto';
                               'events'         'cell'   []              {};
                               'groupstats'     'cell'   []              {};
                               'condstats'      'cell'   []              {};
                               'interstats'     'cell'   []              {};                               
                               'maskdata'       'string' { 'on','off' }   'off';
                               'datatype'       'string' { 'ersp','itc' 'erpim' }    'ersp';
                               'plotmode'       'string' { 'normal','condensed' }  'normal' }, 'std_plottf');
if isstr(opt), error(opt); end;
if all(all(cellfun('size', data, 3)==1))               opt.singlesubject = 'on'; end;

% remove empty entries
datapresent = ~cellfun(@isempty, data);
for c = size(data,1):-1:1, if sum(datapresent(c,:)) == 0, data(c,:) = []; opt.titles(c,:) = []; if ~isempty(opt.groupstats), opt.groupstats(c) = []; end; end; end;
for g = size(data,2):-1:1, if sum(datapresent(:,g)) == 0, data(:,g) = []; opt.titles(:,g) = []; if ~isempty(opt.condstats ), opt.condstats( g) = []; end; end; end;

if ~isempty(opt.groupstats) & ~isempty(opt.condstats) & strcmpi(opt.maskdata, 'on')
    disp('Cannot use ''maskdata'' option with both condition stat. and group stat. on');
    disp('Disabling statistics');
    opt.groupstats = {}; opt.condstats = {}; opt.maskdata = 'off'; 
end;
if ~isempty(opt.ersplim), opt.caxis = opt.ersplim; end;
if ~isempty(opt.itclim), opt.caxis = opt.itclim; end;
onecol  = { 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' };
manycol = { 'b' 'r' 'g' 'k' 'c' 'y' };

nc = size(data,1);
ng = size(data,2);
if nc >= ng, opt.transpose = 'on';
else         opt.transpose = 'off';
end;


if strcmp(ersp_mode, 'Pfu')
     ersp_measure = 'Delta %';
    else
     ersp_measure = 'dB';
end


% test log frequencies
% --------------------
if length(freqs) > 2 & strcmpi(opt.freqscale, 'auto')
    midfreq = (freqs(3)+freqs(1))/2;
    if midfreq*.9999 < freqs(2) & midfreq*1.0001 > freqs(2), opt.freqscale = 'linear';
    else                                                     opt.freqscale = 'log';
    end;
end;






% condensed plot
% --------------
if strcmpi(opt.plotmode, 'condensed') 
    meanplot = zeros(size(data{1},1), size(data{1},2));
    count = 0;
    for c = 1:nc
        for g = 1:ng
            if ~isempty(data{c,g})
                meanplot = meanplot + mean(data{c,g},3);
                count = count+1;
            end;
        end;
    end;
    meanplot = meanplot/count;
    options = { 'chanlocs', opt.chanlocs, 'electrodes', 'off', 'cbar', 'on', ...
            'cmode', 'separate', opt.tftopoopt{:} };       
        
    if strcmpi(opt.freqscale, 'log'), options = { options{:} 'logfreq', 'native' }; end;
    tftopo( meanplot', times, freqs, 'title', opt.titles{1}, options{:}); 
    currentHangle = gca;set(gcf, 'Visible', 'off');
    if ~isempty( opt.caxis )
        caxis( currentHangle, opt.caxis )
    end
    colorbarHandle = cbar;
    title(colorbarHandle,ersp_measure);
    axes(currentHangle); 
    return; 
end;

% plotting paramters
% ------------------
if ng > 1 && ~isempty(opt.groupstats), addc = 1; else addc = 0; end;
if nc > 1 && ~isempty(opt.condstats  ), addr = 1; else addr = 0; end;

% % compute significance mask
% % --------------------------
% if ~isempty(opt.interstats), pinter = opt.interstats{3}; end;

% compute significance mask
% --------------------------
if ~isempty(opt.interstats), pinter = opt.interstats{3}; 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORREGGO BACO INTERAZIONE
    pinter_corr=[];    
    for ind = 1:length(opt.condstats)
        pinter_corr(:,:,ind)  = opt.condstats{ind};
    end;    
    for ind = 1:length(opt.groupstats)
        pinter_corr(:,:,(ind+length(opt.condstats))) = opt.groupstats{ind};         
    end;    
    if isnan(opt.threshold)
        pinter=min(pinter_corr,[],3);
    else
       pinter=max(pinter_corr,[],3); 
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end;





if ~isnan(opt.threshold) && ( ~isempty(opt.groupstats) || ~isempty(opt.condstats) )    
    pcondplot  = opt.condstats;
    pgroupplot = opt.groupstats;
    pinterplot = pinter;
    maxplot = 1;
else
    for ind = 1:length(opt.condstats),  pcondplot{ind}  = -log10(opt.condstats{ind}); end;
    for ind = 1:length(opt.groupstats), pgroupplot{ind} = -log10(opt.groupstats{ind}); end;
    if ~isempty(pinter), pinterplot = -log10(pinter); end;
    maxplot = 3;
end;

% -------------------------------
% masking for significance of not
% -------------------------------
statmask = 0;
if strcmpi(opt.maskdata, 'on') && ~isnan(opt.threshold) && ...
        (~isempty(opt.condstats) || ~isempty(opt.condstats))
    addc = 0; addr = 0; statmask = 1;
end;

% -------------------------
% plot time/frequency image
% -------------------------
options = { 'chanlocs', opt.chanlocs, 'electrodes', 'off', 'cbar', 'off', ...
            'cmode', 'separate', opt.tftopoopt{:} };
if strcmpi(opt.freqscale, 'log'), options = { options{:} 'logfreq', 'native' }; end;
if strcmpi(opt.datatype, 'erpim'), options = { options{:} 'ylabel' 'Trials' }; end;
        
% adjust figure size
% ------------------
fig = figure('Visible', 'off','color', 'w');
pos = get(fig, 'position');
set(fig, 'position', [ pos(1)+15 pos(2)+15 pos(3)/2.5*(nc+addr), pos(4)/2*(ng+addc) ]);
% vv=get(0,'ScreenSize');
%  set(fig, 'Position', [1 1 1000 1000]);
pos = get(fig, 'position');set(fig, 'Visible', 'off');
if strcmpi(opt.transpose, 'off'), set(gcf, 'position', [ pos(1) pos(2) pos(4) pos(3)]);set(gcf, 'Visible', 'off');
else                              set(gcf, 'position', pos);set(fig, 'Visible', 'off');set(gcf, 'Visible', 'off');
end;

set(fig, 'Visible', 'off');
 mask_surface =~(isempty(pmaskgru) & isempty(pmaskcond));    

tmpc = [inf -inf];
for c = 1:nc
    for g = 1:ng
        hdl(c,g) = mysubplot(nc+addr, ng+addc, g + (c-1)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off');
        if ~isempty(data{c,g})
            tmpplot = mean(data{c,g},3);
            if ~isreal(tmpplot(1)), tmpplot = abs(tmpplot); end;
            if statmask, 
                if ~isempty(opt.condstats), tmpplot(find(pcondplot{g}(:) == 0)) = 0;
                else                        tmpplot(find(pgroupplot{c}(:) == 0)) = 0;
                end;
            end;
            if ~isempty(opt.events)
                 tmpevents = mean(opt.events{c,g},2);
            else tmpevents = [];
            end;
            
            
            
            if mask_surface
                p1=pmaskgru;
                p2=pmaskcond;
                if isempty(p1)
                    p1{c}=zeros(size(p2{g}));
                end
                if isempty(p2)
                    p2{g}=zeros(size(p1{c}));
                end
                pthresh=p1{c}+p2{g};
                tmpplot=tmpplot.*pthresh;           
            end
                  
            
            
            tftopo( tmpplot, times, freqs, 'events', tmpevents, 'title', opt.titles{c,g}, options{:}); set(gcf, 'Visible', 'off');
            hold on
            
            for nband=1:length(frequency_bands_list)
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(1),'--','Color','black','LineWidth',0.75)
                hold on
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(2),'--','Color','black','LineWidth',0.75)
                hold on
            end
            
            if isempty(opt.caxis) && ~isempty(tmpc)
                warning off;
                tmpc = [ min(min(tmpplot(:)), tmpc(1)) max(max(tmpplot(:)), tmpc(2)) ];
                warning on;
            else 
                if ~isempty(opt.caxis)
                    caxis(opt.caxis);
                end;
            end;

            if c > 1
                ylabel(''); 
            end;
        end;
    
        % statistics accross groups
        % -------------------------
        if g == ng && ng > 1 && ~isempty(opt.groupstats) && ~isinf(pgroupplot{c}(1)) && ~statmask
            hdl(c,g+1) = mysubplot(nc+addr, ng+addc, g + 1 + (c-1)*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off');
            
            if ~isempty(pmaskgru)
                pgroupplot{c}(~pmaskgru{c})=0;
            end
            
           if ng == 2 && length(unique(pgroupplot{c}))<4  
                if strcmp(display_pmode,'raw_diff')
                    pp = sign( (mean(data{c,1},3) - mean(data{c,2},3)) .* pgroupplot{c});
                    imagesc(times,freqs,pp)
                    set(gca,'YDir','normal')
                    caxis([-2 2])
                    title(['P(',levels_f2{1},' - ',levels_f2{2},')'])
                    hold on
                    plot(zeros(length(freqs)),freqs,'-.')
                    
               elseif strcmp(display_pmode,'abs_diff')        
                    pp = sign( (abs(mean(data{c,1},3)) - abs(mean(data{c,2},3))) .* pgroupplot{c});
                    imagesc(times,freqs,pp)
                    set(gca,'YDir','normal')
                    caxis([-2 2])
                    title(['P(|',levels_f2{1},'| - |',levels_f2{2},'|)'])
                    hold on
                    plot(zeros(length(freqs)),freqs,'-.')

		else
		        tftopo( pgroupplot{c}, times, freqs, 'title', opt.titles{c,g+1}, options{:});
		        caxis([-maxplot maxplot]);
                   
                end
            else
                tftopo( pgroupplot{c}, times, freqs, 'title', opt.titles{c,g+1}, options{:});
                caxis([-maxplot maxplot]);
            end;
set(gcf, 'Visible', 'off');
            
            hold on
             for nband=1:length(frequency_bands_list)
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(1),'--','Color','black','LineWidth',0.75)
                hold on
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(2),'--','Color','black','LineWidth',0.75)
                hold on
            end
            
            
        end;
    end;
end;

for g = 1:ng
    % statistics accross conditions
    % -----------------------------
    if ~isempty(opt.condstats) && ~isinf(pcondplot{g}(1)) && ~statmask && nc > 1
        hdl(nc+1,g) = mysubplot(nc+addr, ng+addc, g + c*(ng+addc), opt.transpose);set(gcf, 'Visible', 'off');
        
        if ~isempty(pmaskcond)
                pcondplot{g}(~pmaskcond{g})=0;            
        end
            
        
         
        if nc == 2 && length(unique(pcondplot{g}))<4 
            if strcmp(display_pmode,'raw_diff')
                pp = sign( (mean(data{1,g},3) - mean(data{2,g},3)) .*  pcondplot{g});
                imagesc(times,freqs,pp)
                set(gca,'YDir','normal')
                caxis([-2 2])
                title(['P(',levels_f1{1},' - ',levels_f1{2},')'])
                hold on
                plot(zeros(length(freqs)),freqs,'-.')
                hold off
            elseif strcmp(display_pmode,'abs_diff')
                pp = sign( (abs(mean(data{g,1},3)) - abs(mean(data{g,2},3))) .*  pcondplot{g});
                imagesc(times,freqs,pp)
                set(gca,'YDir','normal')
                caxis([-2 2])
                title(['P(|',levels_f1{1},'| - |',levels_f1{2},'|)'])
                hold on
                plot(zeros(length(freqs)),freqs,'-.')
                hold off
	else
		tftopo( pcondplot{g}, times, freqs, 'title', opt.titles{nc+1,g}, options{:});
            caxis([-maxplot maxplot]);
            end
        else
            tftopo( pcondplot{g}, times, freqs, 'title', opt.titles{nc+1,g}, options{:});
            caxis([-maxplot maxplot]);
        end
        hold on
         for nband=1:length(frequency_bands_list)
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(1),'--','Color','black','LineWidth',0.75)
                hold on
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(2),'--','Color','black','LineWidth',0.75)
                hold on
            end
      
    end;
end;

% color scale
% -----------
if isempty(opt.caxis)
    tmpc = [-max(abs(tmpc)) max(abs(tmpc))];
    for c = 1:nc
        for g = 1:ng
            axes(hdl(c,g));
            if ~isempty(tmpc)
                caxis(tmpc);
            end;
        end;
    end;
end;

% statistics accross group and conditions
% ---------------------------------------
if ~isempty(opt.groupstats) && ~isempty(opt.condstats) && ng > 1 && nc > 1
    hdl(nc+1,ng+1) = mysubplot(nc+addr, ng+addc, g + 1 + c*(ng+addr), opt.transpose);set(gcf, 'Visible', 'off');
    
    if ~isempty(pmaskinter)
        pinterplot(~pmaskinter{3})=0;
    end
    
    
    tftopo( pinterplot,  times, freqs, 'title', opt.titles{nc+1,ng+1}, options{:});set(gcf, 'Visible', 'off');
    hold on 
     for nband=1:length(frequency_bands_list)
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(1),'--','Color','black','LineWidth',0.75)
                hold on
                plot(times(1,:),ones(1,length(times(1,:)))*frequency_bands_list{nband}(2),'--','Color','black','LineWidth',0.75)
                hold on
            end
    caxis([-maxplot maxplot]);
    ylabel('');
end;    

% color bars
% ----------
axes(hdl(nc,ng)); 
cbar_standard(opt.datatype, ng,ersp_measure); 
if isnan(opt.threshold) && (nc ~= size(hdl,1) || ng ~= size(hdl,2))
    ind = find(hdl(end:-1:1));
    axes(hdl(end-ind(1)+1));
    cbar_signif(ng, maxplot);
end;

tlf1=length(levels_f1);
tlf2=length(levels_f2);  

 if tlf1 > 1 && tlf2 <= 1
    suptitle(['ERSP in ' roi_name,': ', name_f1])
 end
 if tlf1 <=1 && tlf2 > 1
    suptitle(['ERSP in ' roi_name,': ' name_f2 ])
 end
 if tlf1 > 1 && tlf2 > 1 
    suptitle(['ERSP in ' roi_name,': ', name_f1 ' and ' name_f2 ])
 end
 
% name_embed=fullfile(plot_dir,'ersp_tf'); 
% name_plot=[name_embed,'_', char(roi_name)];
% set(fig, 'renderer', 'painter');set(fig, 'Visible', 'off');
% modify_plot(fig);set(fig, 'Visible', 'off');
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
% close(fig)

input_save_fig.plot_dir               = plot_dir;
input_save_fig.fig                    = fig;
input_save_fig.name_embed             = 'ersp_tf';
input_save_fig.suffix_plot            = [char(roi_name)];

save_figures( input_save_fig )

% mysubplot (allow to transpose if necessary)
% -------------------------------------------
function hdl = mysubplot(nr,nc,ind,transp);

    r = ceil(ind/nc);
    c = ind -(r-1)*nc;
    if strcmpi(transp, 'on'), hdl = subplot(nc,nr,(c-1)*nr+r);
    else                      hdl = subplot(nr,nc,(r-1)*nc+c);
    end;

% colorbar for ERSP and scalp plot
% --------------------------------
function cbar_standard(datatype, ng,ersp_measure);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+max(pos(3)/fact,0.006) pos(2) max(pos(3)/fact,0.01) pos(4) ]);  
    set(gca, 'unit', 'normalized');set(gcf, 'Visible', 'off');
    if strcmpi(datatype, 'itc')
         cbar(tmp, 0, tmpc, 10); ylim([0.5 1]);
         title('ITC');
    elseif strcmpi(datatype, 'erpim')
        cbar(tmp, 0, tmpc, 5);
    else
        cbar(tmp, 0, tmpc, 5);title(ersp_measure);
    end;
    

% colorbar for significance
% -------------------------
function cbar_signif(ng, maxplot);
    pos = get(gca, 'position');
    tmpc = caxis;
    fact = fastif(ng == 1, 40, 20);
    tmp = axes('position', [ pos(1)+pos(3)+max(pos(3)/fact,0.006) pos(2) max(pos(3)/fact,0.01) pos(4) ]);  
    map = colormap;
    n = size(map,1);
    cols = [ceil(n/2):n]';
    image([0 1],linspace(0,maxplot,length(cols)),[cols cols]);
%     cbar(tmp, 0, tmpc, 5);
    tick = linspace(0, maxplot, maxplot+1);
    set(gca, 'ytickmode', 'manual', 'YAxisLocation', 'right', 'xtick', [], ...
        'ytick', tick, 'yticklabel', round(10.^-tick*1000)/1000);
    xlabel('');
set(gcf, 'Visible', 'off');
% rapid filtering for ERP
% -----------------------
function tmpdata2 = myfilt(tmpdata, lowpass, highpass, factor, filtertype)

    tmpdata2 = reshape(tmpdata, size(tmpdata,1), size(tmpdata,2)*size(tmpdata,3)*size(tmpdata,4));
    tmpdata2 = eegfiltfft(tmpdata2',lowpass, highpass, factor, filtertype)';
    tmpdata2 = reshape(tmpdata2, size(tmpdata,1), size(tmpdata,2), size(tmpdata,3), size(tmpdata,4));
