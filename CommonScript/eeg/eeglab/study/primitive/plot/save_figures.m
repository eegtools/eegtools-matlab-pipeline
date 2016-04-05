function [ ] = save_figures( input, varargin )
%% function [ ] = save_figures( input )
% save figures representing results of group statistical analysis in
% different formats (fig, eps, svg, tif + ps and pdf with embedded figures)
%
% plot_dir     = input.plot_dir;                                             % root directory for saving figures
% fig          = input.fig;                                                  % the figure handle to be saved
% name_embed   = input.name_embed;                                           % the name (without the path) of the overview files (ps, pdf, ppt,)
% suffix_plot  = input.suffix_plot;                                          % the suffix added, for each saved figure, to the name of ebbedded files
%
% varargin
% res             = '-r300'; % resolution
% exclude_format  = [];
% renderer        = 'painter';
% printer         ='-depsc2';
% pdf_mode        = 'export_fig';
%                    switch pdf_mode
%                     case 'export_fig'
%                         export_fig(fig, pdf_path, '-pdf', '-append',res);
%                     case 'ps2pdf'
%                         ps2pdf('psfile',  ps_path, 'pdffile', pdf_path, 'gspapersize', 'a4')
% end

plot_dir     = input.plot_dir;                                             % root directory for saving figures
fig          = input.fig;                                                  % the figure handle to be saved
name_embed   = input.name_embed;                                           % the name (without the path) of the overview files (ps, pdf, ppt,)
suffix_plot  = input.suffix_plot;                                          % the suffix added, for each saved figure, to the name of ebbedded files


fig_dir      = fullfile(plot_dir,'fig'); if(not(exist(fig_dir,'dir')));mkdir(fig_dir);end;
eps_dir      = fullfile(plot_dir,'eps'); if(not(exist(eps_dir,'dir')));mkdir(eps_dir);end;
svg_dir      = fullfile(plot_dir,'svg');
tif_dir      = fullfile(plot_dir,'tif'); if(not(exist(tif_dir,'dir')));mkdir(tif_dir);end;

name_plot    = [name_embed,'_',suffix_plot];                               % name of the plot without the path

% full paths of single figurs in different formats
fig_path =  fullfile(fig_dir,[name_plot,'.fig']);
eps_path =  fullfile(eps_dir,[name_plot,'.eps']);
svg_path =  fullfile(svg_dir,[name_plot,'.svg']);
tif_path =  fullfile(tif_dir,[name_plot,'.tif']);

% full path of overview embedded files
ps_path   =  fullfile(plot_dir,[name_embed,'.ps']);
ppt_path  =  fullfile(plot_dir,[name_embed,'.ppt']);
pdf_path  =  fullfile(plot_dir,[name_embed,'.pdf']);

res             = '-r300'; % resolution
exclude_format  = [];
renderer        = 'painter';
pdf_mode        = 'export_fig';
printer         ='-depsc2';

%% check optional arguments

for par=1:2:length(varargin)
    switch varargin{par}
        case {'renderer'          , ...
                'pdf_mode'          , ...
                'exclude_format'    , ...
                'res'               , ...
                'printer'           , ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

% renderer        = 'painter';
% set figure parameters in a good format for saving/exporting
set(fig, 'renderer', renderer);
modify_plot(fig);

% save matlab fig file
saveas(fig, fig_path);

% save eps file
print(eps_path,printer,res);

if(not(sum(ismember(exclude_format,'svg')))) % note: there is a specific bug of matlab/eeglab: when saving topoplots svg come corrupted
    if(not(exist(svg_dir,'dir')));mkdir(svg_dir);end;
    % save svg file
    plot2svg(svg_path)
end

% save tif file
print(tif_path,'-dtiff',res);


% check the operating system
os = system_dependent('getos');

% if windows windows, print append the current plot to a postscript file AND to a powerpoint file (for an overview of results)
if strncmp(os,'PCWIN',2)
    print(fig, ps_path,'-append','-dwinc')
    saveppt2(ppt_path,'f',fig);
    
    % if linux, only append to the postscript
end


if strncmp(os,'Linux',2)
    print(fig, ps_path,'-append',['-',renderer],res)
end



if strncmp(os,'Darwin',2)
    %set(fig,'PaperOrientation','landscape');
    pp = get(fig,'Position');
    pp(3) = 0.5 * pp(3);
    pp(4) = 0.5 * pp(4);
    set(fig, 'Position', pp)% save eps file

    %print(eps_path,printer,res);
    %saveas(fig,eps_path,'epsc')
        %print(fig, eps_path,'-depsc2',res)
        hgexport(fig,eps_path)

    print(fig, ps_path,'-append','-dpsc',res)
    %print(fig, '-dpsc', '-append', ps_path)
end
% in any operating system, append the current figure to a global pdf file
% for overview

if not(strncmp(os,'Darwin',2))
    
    switch pdf_mode
        case 'export_fig'
            export_fig(fig, pdf_path, '-pdf', '-append',res);
        case 'ps2pdf'
            ps2pdf('psfile',  ps_path, 'pdffile', pdf_path, 'gspapersize', 'a4')
    end
end
close all

end

