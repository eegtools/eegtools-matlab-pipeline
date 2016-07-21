% calculate the mean power spectrum within a time interval
% freq_bands: must be formatted as it:
% by default it does not calculate any stats nor comparison between baseline
function [mean_spectrum, freqs] = eeglab_subject_psd_plot_onecondition(input_set, roi, varargin)
   
    [path,name_noext,ext] = fileparts(input_set);
    
    EEG             = pop_loadset('filename', {[name_noext ext] }, 'filepath', path);

    chanlist        = {EEG(1).chanlocs.labels};
    
    chan_ids        = [];
    ch_label        = '';
    for ch=1:length(roi)
        chan_ids = [chan_ids find(strcmp(roi{ch},chanlist))];
        ch_label = [ch_label roi{ch}];
    end
    datas           = EEG.data(chan_ids,:,:);
    datas           = squeeze(mean(datas, 1));
    
    srate           = EEG(1).srate;
    pnt             = EEG(1).pnts;
    xmin            = EEG(1).xmin;  ... in seconds
    xmax            = EEG(1).xmax;

    % default values
    save_fig        = 0;
    fig_output_path = '';
    freq_band       = [];
    cycles          = [3 0.5];

    options_num     = size(varargin,2);
    opt             = 1;
    while options_num>0
        switch varargin{opt}
            case 'save_fig'
                opt=opt+1;
                save_fig=varargin{opt};              
            case 'fig_output_path'
                opt=opt+1;
                fig_output_path=varargin{opt};
            case 'freq_band'
                opt=opt+1;
                freq_band=varargin{opt};                
            case 'xmax'
                opt=opt+1;
                xmax=varargin{opt}; 
            case 'xmin'
                opt=opt+1;
                xmin=varargin{opt}; 
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
    %-------------------------------------------------------------------------------------------------------
    set(0,'DefaultTextInterpreter','none');    
    figure
    title_name=[name_noext '_in_' ch_label];    
    
    
    if isempty(freq_band)
        [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(datas, pnt, [xmin xmax]*1000, srate, cycles, 'plotitc','off','plotersp', 'off'); 
    else
        [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(datas, pnt, [xmin xmax]*1000, srate, cycles, 'plotitc','off','plotersp', 'off', 'freqs', [4:0.5:25], 'padratio', 4); 
    end
    
    
    mean_spectrum = squeeze(mean(ersp, 2));
    suptitle(title_name);    
    plot(freqs, mean_spectrum);
    

    
    if save_fig
        hfig=gcf();
        output_file=fullfile(fig_output_path, [title_name '.jpg']);
        saveas(hfig,output_file,'jpg');
        close(hfig);
    end    
   

end    