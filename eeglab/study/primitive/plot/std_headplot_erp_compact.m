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

function std_headplot_erp_compact(input, varargin)


plot_dir                                                                   = input.plot_dir;
time_window_name                                                           = input.time_window_name;
name_f1                                                                    = input.name_f1;
name_f2                                                                    = input.name_f2;
levels_f1                                                                  = input.levels_f1;
levels_f2                                                                  = input.levels_f2;
erp_headplot_tw                                                            = input.erp_headplot_tw;
clim                                                                       = input.clim;
z_transform                                                                = input.z_transform;
file_spline                                                                = input.file_spline; % '/home/campus/behaviourPlatform/VisuoHaptic/ABBI_EEG/ABBI_EEG_st/af_AS_mc_s-s1-1sc-1tc.spl'
view_list                                                                  = input.view_list; %[0 45]
% chlocs                                                                     = input.chlocs;      

totviews = size(view_list,1);

strfname = char([ name_f1, '_', name_f2]);
% if nargin < 2
%     help std_chantopo;
%     return;
% end;


%  'view'       - Camera viewpoint in deg. [azimuth elevation]
%                    'back'|'b'=[  0 30]; 'front'|'f'=[180 30]
%                    'left'|'l'=[-90 30]; 'right'|'r'=[ 90 30];
%                    'frontleft'|'bl','backright'|'br', etc.,
%                    'top'=[0 90],  Can rotate with mouse {default [143 18]}


%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');


%% NOTA: bisogna da qualche parte generare lo splide della testa

colbk='white';

erp_measure='uV';

if strcmp(z_transform,'on')
    erp_meaure='Z(ERP)';
end


% total levels of factor 1 (e.g conditions) and 2 (e.g groups)
[tlf1 tlf2]=size(erp_headplot_tw);

close all

for nlf1 = 1:tlf1
    for nlf2 = 1:tlf2
        if tlf2
            str = char([ name_f1, '_', levels_f1{nlf1},'__', name_f2, '_',levels_f2{nlf2}]);
        else
            str = char([ name_f1, '_', levels_f1{nlf1}]);
        end
        
        erp_mat = squeeze(erp_headplot_tw{nlf1,nlf2});
        
        [tch, tsub] = size(erp_mat);
        
        if strcmp(z_transform,'on')
            for nsub = 1:tsub
                erp_mat(:,nsub) = (erp_mat(:,nsub) - mean(erp_mat(:,nsub)))/std(erp_mat(:,nsub));
            end
        end
        
        erp_vec= mean(erp_mat,2);
        
        for nview = 1:totviews
            
            view = view_list(nview,:);
            
            strv = char(num2str(view));
            sel_spaces = ismember(strv, ' ');
            strv(sel_spaces) = '_';
            
            tot_str = [char(time_window_name),'_', str,'_',strv];
            
            
            fig=figure( 'Visible', 'off');
            
            if isempty(clim)
                headplot(erp_vec, file_spline, 'electrodes','off','view',view, 'cbar',0,'title',tot_str);
            else
                
                headplot(erp_vec, file_spline, 'electrodes','off','view',view, 'maplimits',clim,'cbar',0,'title',tot_str);
            end
            
            
            
            
%               'view'       - Camera viewpoint in deg. [azimuth elevation]
%                    'back'|'b'=[  0 30]; 'front'|'f'=[180 30] 
%                    'left'|'l'=[-90 30]; 'right'|'r'=[ 90 30];
%                    'frontleft'|'bl','backright'|'br', etc.,
%                    'top'=[0 90],  Can rotate with mouse {default [143 18]}
            
            
            input_save_fig.plot_dir               = plot_dir;
            input_save_fig.fig                    = fig;
            input_save_fig.name_embed             = [strfname,'_','erp_headplot_tw'];
            input_save_fig.suffix_plot            = tot_str;
            
            save_figures( input_save_fig ,'do_ps',0)
        end
        
    end
end





% end
