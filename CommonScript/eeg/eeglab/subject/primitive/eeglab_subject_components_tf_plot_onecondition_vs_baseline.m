% freq_bands: must be formatted as it:

function eeglab_subject_components_tf_plot_onecondition_vs_baseline(input_set_filename, ch_label, varargin)
   

    [path,name_noext,ext] = fileparts(input_set_filename);
    
    EEG             = pop_loadset('filename', {[name_noext ext] }, 'filepath', path);

    chanlist        = {EEG(1).chanlocs.labels};
    chan_num        = find(strcmp(ch_label,chanlist));
    srate           = EEG(1).srate;
    pnt             = EEG(1).pnts;
    xmin            = EEG(1).xmin;  ... in seconds
    xmax            = EEG(1).xmax;
    bc_type         = '';
    num_ic          = size(EEG.icawinv ,2);
    % default values
    pvalue          = 0.05;
    correction      = 'none';
    save_fig        = 1;
    fig_output_path = '';
    baseline        = [xmin 0]*1000; ...i need it in milliseconds
    freq_bands      = [];
    cycles          = [3 0.5];

    options_num     = size(varargin,2);
    opt             = 1;
    while options_num>0
        switch varargin{opt}
            case 'pvalue'
                opt=opt+1;
                pvalue=varargin{opt};                  
            case 'correct'
                opt=opt+1;
                correction=varargin{opt};
            case 'baseline'
                opt=opt+1;
                baseline=varargin{opt};
            case 'save_fig'
                opt=opt+1;
                save_fig=varargin{opt};              
            case 'fig_output_path'
                opt=opt+1;
                fig_output_path=varargin{opt};
            case 'freq_bands'
                opt=opt+1;
                freq_bands=varargin{opt};                
            case 'xmax'
                opt=opt+1;
                xmax=varargin{opt}; 
            case 'bc_type'
                opt=opt+1;
                bc_type=varargin{opt}; 
            case 'cycles'
                opt=opt+1;
                cycles=varargin{opt};               
            otherwise
                opt=opt+1;
                disp('input parameter not recognized');
        end
        opt=opt+1;
        options_num=options_num-2;
    end
    baseline_point=[round(abs(xmin-baseline(1)/1000)*srate) round(abs(xmin-baseline(2)/1000)*srate)] + 1;    
    %-------------------------------------------------------------------------------------------------------
    set(0,'DefaultTextInterpreter','none');
    
    title_name  = [name_noext '_in_' ch_label];    
    output_file = fullfile(fig_output_path, [title_name]);
    
    for nic=1:num_ic
        fig = figure('visible','off');

        ic2remove = [];
        for ic=1:nic-1
            ic2remove = [ic2remove ic];
        end
        
        for ic=(nic+1):num_ic
            ic2remove = [ic2remove ic];
        end
        
        EEG2 = pop_subcomp( EEG, ic2remove, 0);

        
        [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(EEG2.data(chan_num,:,:) ,pnt, [xmin xmax]*1000, srate, cycles, 'alpha',pvalue,'erspmax',3,'plotitc','off','mcorrect',correction,'plotersp', 'on', 'baseline', baseline,'trialbase','full'); ... 'timesout', 200, 
        sub_title_name  = [name_noext '_in_' ch_label '_incomp_' num2str(nic)]; 
        suptitle(sub_title_name);
    
    
        print(fig,output_file,'-append');
        close(fig);
                
 
    end
    
%     % plot epochs (baselined)
%     for fb=1:length(freq_bands)
%         
%         % newtimef resampled my data vector and removed edge latencies, so I have to recompute start and end baseline_points 
%         new_bs_min = max(times(1), baseline(1));
%         new_bs_max = min(times(end), baseline(2));
%         new_srate   = (1/abs(times(1)-times(2)))*1000;
%         
%         baseline_point=[round(abs((times(1)-new_bs_min)/1000)*new_srate) round(abs((times(1)-new_bs_max)/1000)*new_srate)] + 1;    
%     
%         set(0, 'defaultTextInterpreter', 'none');
%     
%         sel_freqs=[freqs>freq_bands{fb}(1) & freqs<freq_bands{fb}(2)];
%         data=squeeze(mean(abs(tfdata(sel_freqs,:,:)).^2,1))';  ... trial x tp %   data=squeeze(mean(tfdata(sel_freqs,:,:).*conj(tfdata(sel_freqs,:,:)),1))';
% 
%         if strcmp(bc_type, 'trial')
%             
%             mbs             = mean(data(:, baseline_point(1):1:baseline_point(2),:),2); %     mbs: channel, 1, epochs
%             baseline        = repmat(mbs,1,pnt);
%             bs_data         = data-baseline;    
%             
%         else
%     
%             mbs             = mean(data(:, baseline_point(1):1:baseline_point(2)),2); %     mbs=mean(data(:,[baseline(1):baseline(2)]),2);
%             baseline        = repmat(mbs,1,200);
%             bs_data         = data-baseline;
%         end        
%         
%         
%         %mmbs=mean(mbs);%dbs=mbs-mmbs; dbaseline=repmat(dbs,1,200); bs_data=bs_data-baseline;%bs_data=bs_data-mmbs; ...baseline;    
%         figure();
%         imagesc(times,[],bs_data,[-4 4]);
%         title(title_name);    
%         
%         if save_fig
%             hfig=gcf();
%             output_file=fullfile(fig_output_path, [title_name '_trials' '.jpg']);
%             saveas(hfig,output_file,'jpg');
%             close(hfig);
%         end 
%     
%     end
end    