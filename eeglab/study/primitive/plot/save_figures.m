function [ ] = save_figures( input )
%% function [ fig ] = save_figures( input )
% save figures representing results of group statistical analysis in different formats
%
% plot_dir     = input.plot_dir;                                             % root directory for saving figures
% fig          = input.fig;                                                  % the figure handle to be saved
% name_embed   = input.name_embed;                                           % the name (without the path) of the overview files (ps, pdf, ppt,)
% suffix_plot  = input.suffix_plot;                                          % the suffix added, for each saved figure, to the name of ebbedded files
%
plot_dir     = input.plot_dir;                                             % root directory for saving figures
fig          = input.fig;                                                  % the figure handle to be saved
name_embed   = input.name_embed;                                           % the name (without the path) of the overview files (ps, pdf, ppt,)
suffix_plot  = input.suffix_plot;                                          % the suffix added, for each saved figure, to the name of ebbedded files

fig_dir      = fullfile(plot_dir,'fig'); mkdir(fig_dir);
eps_dir      = fullfile(plot_dir,'eps'); mkdir(eps_dir);
svg_dir      = fullfile(plot_dir,'svg'); mkdir(svg_dir);
tif_dir      = fullfile(plot_dir,'tif'); mkdir(tif_dir);

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

res       = '-r600'; % resolution


% set figure parameters in a good format for saving/exporting
set(fig, 'renderer', 'painter')
modify_plot(fig);

% save matlab fig file
saveas(fig, fig_path);

% save eps file
print(eps_path,'-depsc2',res);

% save svg file
plot2svg(svg_path)

% save tif file
print(tif_path,'-dtiff',res);


% check the operating system
os = system_dependent('getos');

% if windows windows, print append the current plot to a postscript file AND to a powerpoint file (for an overview of results)
if ~ strncmp(os,'Linux',2)
    print(fig, ps_path,'-append','-dwinc')
    saveppt2(ppt_path,'f',fig);
    
    % if linux, only append to the postscript
else
    print(fig, ps_path,'-append','-painter',res)
end
% in any operating system, append the current figure to a global pdf file
% for overview
export_fig(fig, pdf_path, '-pdf', '-append')

close(fig)

end

