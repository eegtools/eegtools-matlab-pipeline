function onset_offset = eeglab_study_roi_erp_curve_compare_roi_onset_offset(params,  varargin)
%% compare significant deflections form baseline.
% consider a list of groups of rois and a list of time windows. 
% for each group and time window, compare onset/offset of ERP of different rois. 
% onset is estimated by t test comparing ERP value at each time point in a selected time window with the distriubution of ERP values during the baseline.
% 
%
% base_lim                      = params.base_lim_bp;                      % baseline in ms
% tw_list.limits                = params.tw_list.limits;                   % cell array. vector [tmin tmax] in ms.
%                                                                               select time windows in ms in which find onset and offset,
%                                                                               if empty all times oustide the baseline will be compared with the baseline
% ylim_vec                      = params.ylim_vec;                         % y limits for the plot
% offset.significant_lines      = params.offset.significant_lines;
% offset.text                   = params.offset.text;
% dy.significant_lines          = params.dy.significant_lines;
% dy.text                       = params.dy.text;
% dir.input                     = params.dir.input;
% dir.output                    = params.dir.output;
% grouping_roi_list             = params.grouping_roi_list;                % cell array. list of groups or rois which will be compared, each cell correspond to a separate plot
% 
% 
% % parameters which could in a future became varargin
% 
% fname_input                   = params.fname_input;
% name_embed                    = params.name_embed;                       % string. file name used for the pdf with all figures together
% col_list                      = params.col_list;
% pvalue                        = params.pvalue;
% correction                    = params.correction;                       % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni' 
%
%% extract parameters from the input structure
base_lim                      = params.base_lim_bp;                        % baseline in ms
tw_list.limits                = params.tw_list.limits;                     % cell array. vector [tmin tmax] in ms.
%                                                                             select time windows in ms in which find onset and offset,
%                                                                             if empty all times oustide the baseline will be compared with the baseline
tw_list.names                 = params.tw_list.names;                      % cell array of strings. names of the time windows, if empty, 'all_epoch'   
ylim_vec                      = params.ylim_vec;                           % y limits for the plot
offset.significant_lines      = params.offset.significant_lines;
offset.text                   = params.offset.text;
dy.significant_lines          = params.dy.significant_lines;
dy.text                       = params.dy.text;
dir.input                     = params.dir.input;
dir.output                    = params.dir.output;
grouping_roi_list             = params.grouping_roi_list;                  % cell array. list of groups or rois which will be compared, each cell correspond to a separate plot


% parameters which could in a future became varargin

fname_input                   = params.fname_input;
name_embed                    = params.name_embed;                         % string. file name used for the pdf with all figures together
col_list                      = params.col_list;
pvalue                        = params.pvalue;
correction                    = params.correction;                         % string. correction for multiple comparisons 'none'| 'fdr' | 'holms' | 'bonferoni' 

if isempty(fname_input)
    fname_input = 'erp_curve_roi-stat.mat';
end


if isempty(name_embed)
    name_embed  = 'onset_offset_plot';
end

if isempty(col_list)
    col_list    = {'m','c','r','g','b'};
end

if isempty(pvalue)
    pvalue      = 0.05;
end

if isempty(correction)
    pvalue      = 'fdr';
end



load(fullfile(dir.input,fname_input))

% total groups of rois (plots)
trl=length(grouping_roi_list);

% times (ms) of the whole epoch
times       = erp_curve_roi_stat.times;
tt          = length(times);

% if no wime window is indicated, consider the whole epoch
if isempty(tw_list.limits)
    tw_list.limits     = {[min(times), max(times)]};
end

% if no wime window is indicated, consider the whole epoch
if isempty(tw_list.names)
    tw_list.names     = {'all_epoch'};
end


% total amount of time windows
ttw = length(tw_list.limits);

onset_offset.tw_list.limits = tw_list.limits;
onset_offset.grouping_roi_list = grouping_roi_list;
onset_offset.pvalue = pvalue;


% for each time window
for ntw = 1:ttw    
    
    tw = tw_list.limits{ntw};
    
    onset_offset(tw).tw = tw;
    
    % for each group of rois
    for nrl = 1:trl
        roi_names = grouping_roi_list{nrl};
        
        sel_roi = find(ismember(erp_curve_roi_stat.roi_names,roi_names));
        
        tr=length(roi_names);
        
        % factor 1 (rows of the cell array)
        name_f1     = erp_curve_roi_stat.study_des.variable(1).label;
        levels_f1   = erp_curve_roi_stat.study_des.variable(1).value;
        tf1         = length(levels_f1);
        
        % factor 2 (columns of the cell array)
        name_f2     = erp_curve_roi_stat.study_des.variable(2).label;
        levels_f2   = erp_curve_roi_stat.study_des.variable(2).value;
        tf2         = length(levels_f2);
        
                
        % mask to select the baseline
        sel_base    = times >= base_lim(1) & times <= base_lim(2);
        
        % mask to select the baseline
        sel_tw      = times >= tw(1) & times <= tw(2);
        
        % mask to select time to be compared with the baseline: times outside
        % the baseline
        sel_test_times = times(not(sel_base)  &  sel_tw);
               
        % total timepoints to be compared with the baseline
        ttt=length(sel_test_times);
                
        mat_roi=zeros(tt,tr);
        cell_roi=cell(tf1,tf2);
        
        mat_sig_dif = zeros(tt,tr);
        cell_sig_dif=cell(tf1,tf2);
        cell_tonset=cell(tf1,tf2);
        cell_toffset=cell(tf1,tf2);
        
        vtonset = nan(tr);
        vtoffset = nan(tr);
        
        vmin=[];
        vmax=[];
        nm=1;
        
        % for each level of factor 1
        for nf1 =1:tf1
            
            % for each level of factor 2
            for nf2 =1:tf2
                
                % for each roi in the group of rois to be compared (on the
                % same plot)
                for nr = 1:tr
                    mat_roi(:,nr) = mean(erp_curve_roi_stat.dataroi(sel_roi(nr)).erp_curve_roi{nf1,nf2},2);
                    
                    vmin{nf1,nf2} = min(min(mat_roi));
                    vmax{nf1,nf2} = max(max(mat_roi));
                    
                    base_roi = mat_roi(sel_base,nr);
                    
                    sig_dif = nan(tt,1);
                    
                    % for each time point outside the baseline and within the time window to be compared with the baseline
                    for ntt=1:ttt
                        t2test = sel_test_times(ntt);
                        selpoint = times == t2test;
                        point2test = mat_roi(selpoint,nr);
                        [h,p]=ttest2( base_roi,point2test);
                        sig_dif(selpoint) = p;
                    end
                    sig_dif = mcorrect(sig_dif,correction);
                    sig_dif=(sig_dif<sig_thres)+0;
                    sig_dif(not(sig_dif))=nan;
                    
                    tonset=min(times(sig_dif>0));
                    toffset=max(times(sig_dif>0));
                    
                    mat_sig_dif(:,nr) = sig_dif;
                    if(not(isempty(tonset)))
                        vtonset(nr)=tonset;
                    end
                    if(not(isempty(toffset)))
                        vtoffset(nr)=toffset;
                    end
                end
                cell_roi{nf1,nf2}=mat_roi;
                cell_sig_dif{nf1,nf2}=mat_sig_dif;
                cell_tonset{nf1,nf2}=vtonset;
                cell_toffset{nf1,nf2}=vtoffset;
            end
        end
        onset_offset(tw).curves       = cell_roi;
        onset_offset(tw).sig_lines    = cell_sig_dif;
        onset_offset(tw).tonset       = cell_tonset;
        
        %% now plotting
        for nf1 =1:tf1
            for nf2 =1:tf2
                fig=figure;
                
                maxsig= vmin{nf1,nf2}-dy;
                minsig=ylim_vec(1)+dy;
                
                voff_sig=linspace(maxsig, minsig,nr);
                
                for nr = 1:tr
                    curve_roi = cell_roi{nf1,nf2}(:,nr);
                    curve_roi_norm=curve_roi;
                    %                 curve_roi_norm = curve_roi/max(abs( curve_roi));
                    
                    plot(times,curve_roi_norm,'color',col_list{nr},'LineWidt',2);
                    
                    if do_stats
                        hold on
                        
                        
                        sig_curve = cell_sig_dif{nf1,nf2}(:,nr)*voff_sig(nr);
                        plot(times,sig_curve,'color',col_list{nr},'LineWidt',3);
                        
                    end
                    
                    hold on
                    text(mean(times),offset.text - dy.text * nr,roi_names{nr},'color',col_list{nr});
                    
                end
                ylim(ylim_vec);
                
                str=[tw_list.names{ntw}, '_',name_f1,' = ', levels_f1{nf1},', ',name_f2,' = ',levels_f2{nf2}];
                title(str, 'Interpreter', 'none')
                ylabel('uV')
                xlabel('Time(ms)');
                %             line([0 0],[-2 2])
                name_fig = [levels_f1{nf1},'_ ',levels_f2{nf2},'.eps'];
                print(fig, '-depsc2',  fullfile(dir.input,name_fig));
                set(fig,'color','white');
                export_fig(fig,[fullfile(dir.input,name_embed),'.pdf'], '-pdf', '-append')
                close all
            end
        end
        
    end
    
    
end



end

