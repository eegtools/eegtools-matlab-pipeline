function spectra_sub = eeglab_subject_spectra(input, varargin)



input_file_name = input.input_file_name;
freqrange      = input.freqrange;
freq            = input.freq;
plotchans       = input.plotchans;
plot_dir        = input.plot_dir;
plot_label      = input.plot_label;
% chan_analysis    = input.chan_analysis;
% band_analysis    = input.band_analysis;

list_band_lim = input.list_band_lim;
list_band_name = input.list_band_name;
list_roi_ch = input.list_roi_ch;
list_roi_name = input.list_roi_name;


scale            = input.scale;
plot_single_subject = input.plot_single_subject;


str_col = {'m','c','r','g','b','k'};
list_col = repmat(str_col,1,length(list_band_name));

ylim_rel = [];
if not(isempty(input.ylim_rel))
    ylim_rel = input.ylim_rel;
end

ylim_abs = [];
if not(isempty(input.ylim_abs))
    ylim_abs = input.ylim_abs;
end

% do_plots        =

% function [name_noext, rr2,ica_type,duration, EEG] = eeglab_subject_spectra(input_file_name, output_path, eeg_ch_list, ch_ref, ica_type, do_pca, ica_sr, varargin)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition
%    in the same filei
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured

%         [names{subj},ranks{subj},ica_types{subj},durations{subj}, EEG]         = eeglab_subject_spectra(inputfile, project.paths.output_preprocessing, project.eegdata.eeg_channels_list, project.import.reference_channels, ica_type,do_pca,ica_sr);


[~, name_noext, ~] = fileparts(input_file_name);




% for par=1:2:length(varargin)
%     switch varargin{par}
%         case {'gpu_id', 'ofn'}
%             if isempty(varargin{par+1})
%                 continue;
%             else
%                 assign(varargin{par}, varargin{par+1});
%             end
%     end
% end

% ......................................................................................................

% CLA inserisco passaggio a modalità base (non cudaica) su pc che non
% hanno cudaica


try
    
    
%     EEG = pop_loadset(input_file_name);


    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end
    
    spectra_sub.chanlocs = EEG.chanlocs;
    spectra_sub.duration = EEG.xmax;
    
    old_chan = {EEG.chanlocs.labels};
    
    allch = unique(old_chan);
    tch = length(allch);
    
    ind_nodub = [];
    for nch = 1:tch
        sel_ind = find(ismember(old_chan,allch(nch)));
        ind_nodub(nch) = sel_ind(1);
    end
    
    EEG = pop_select(EEG,'channel',ind_nodub);
    allch = {EEG.chanlocs.labels};
    
    
    disp(EEG.filename)
    
    
    if strcmp(plot_single_subject,'on')
        
        set(0,'DefaultFigureVisible','off')
        fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
        [spectra,freqs,~,~,~] = ...
            spectopo(EEG.data, EEG.pnts, EEG.srate, 'chanlocs',EEG.chanlocs,  ...
            'freqrange', freqrange, 'freq', freq, 'plotchans', plotchans,...
            'winsize',2*EEG.srate, 'nfft',2*EEG.srate,'overlap',EEG.srate);
        suptitle2(plot_label);
        
        plot_dir_topo = fullfile(plot_dir,'topo_sp');
        if not(exist(plot_dir_topo))
            mkdir(plot_dir_topo)
        end
        
        
        inputsf.plot_dir    = plot_dir_topo;
        inputsf.fig         = fig;
        inputsf.name_embed  = 'subject_spectra_topo';
        inputsf.suffix_plot = ['subject_spectra_topo_',plot_label];
        save_figures(inputsf,'res','-r100');
        
    else
        [spectra,freqs,~,~,~] = ...
            spectopo(EEG.data, EEG.pnts, EEG.srate, 'chanlocs',EEG.chanlocs,  ...
            'freqrange', freqrange, 'freq', freq, 'plotchans', plotchans,...
            'winsize',2*EEG.srate, 'nfft',2*EEG.srate,'overlap',EEG.srate, 'plot','off');
    end
    
    % spectra matrice n canali  x n freq
    
    sel_freq = freqs >= freqrange(1) & freqs <= freqrange(2);
    
    spectra_sub.freqs = freqs(sel_freq);
    tfreq = length(spectra_sub.freqs);
    
    spectra_sub.log_spectra = spectra(:,sel_freq);
    
    
    if strcmp(scale, 'raw')
        
        spectra_sub.abs_spectra = 10.^(spectra(:,sel_freq)/10);        
        ss = sum(spectra_sub.abs_spectra,2);
        ss2 = repmat(ss,1,tfreq);
        spectra_sub.rel_spectra = spectra_sub.abs_spectra./ss2*100; % in percentuali
    else
        spectra_sub.abs_spectra = log(10.^(spectra(:,sel_freq)/10));
        minsp = min(spectra_sub.abs_spectra,[],2);
        mat_minsp = repmat(minsp,1,tfreq);
        abs_spectra_shift = spectra_sub.abs_spectra + abs(mat_minsp);
        
        ss = sum(abs_spectra_shift,2);
        ss2 = repmat(ss,1,tfreq);
        spectra_sub.rel_spectra = abs_spectra_shift./ss2*100;
        
    end
    
    %     spectra_sub.freqs = freqs(sel_freq);
    
    
    
   
    
    
    plot_dir_ch = fullfile(plot_dir,'roi_sp');
    if not(exist(plot_dir_ch))
        mkdir(plot_dir_ch)
    end
    
     plot_dir_ch_abs = fullfile(plot_dir_ch,'abs');
    if not(exist(plot_dir_ch_abs))
        mkdir(plot_dir_ch_abs)
    end
    
     plot_dir_ch_rel = fullfile(plot_dir_ch,'rel');
    if not(exist(plot_dir_ch_rel))
        mkdir(plot_dir_ch_rel)
    end
    
    for nband = 1:length(list_band_name)
        band_analysis = list_band_lim(nband,:);            
        sel_band = spectra_sub.freqs >= band_analysis(1) & spectra_sub.freqs <= band_analysis(2);
        spectra_sub.band(nband).name = list_band_name{nband};
        spectra_sub.band(nband).abs_spectra = mean(spectra_sub.abs_spectra(:,sel_band),2);
        spectra_sub.band(nband).rel_spectra = mean(spectra_sub.rel_spectra(:,sel_band),2); 
        spectra_sub.band(nband).log_spectra = mean(spectra_sub.log_spectra(:,sel_band),2);        
		
    end
    
    %% plot absolute spectra
    for nroi  = 1:length(list_roi_name)        
        spectra_sub.roi(nroi).name = list_roi_name{nroi};        
        chan_analysis =  list_roi_ch{nroi};        
        spectra_sub.roi(nroi).ch = chan_analysis;        
        sel_ch = ismember(allch,chan_analysis);
        %         tch = length(sel_ch);
        
        %         ind_ch = sel_ch(nch);
        %         ch_lab = allch{ind_ch};
        %         spectra_sub.ch(nch).ch_lab = ch_lab;
        
        roispectra_abs = mean(spectra_sub.abs_spectra(sel_ch,:),1);   
		roispectra_log = mean(spectra_sub.log_spectra(sel_ch,:),1);   

        ss = sum(roispectra_abs);
        roispectra_rel = roispectra_abs./ss*100;        
        spectra_sub.roi(nroi).roispectra_abs = roispectra_abs;
        spectra_sub.roi(nroi).roispectra_rel = roispectra_rel;
		spectra_sub.roi(nroi).roispectra_log = roispectra_log;


        if strcmp(plot_single_subject,'on')
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            hax=axes;
            
            plot_label_ch = [plot_label,'_',list_roi_name{nroi}];
            
            plot(spectra_sub.freqs,roispectra_abs,'LineWidth',2);
            xlabel('Frequency (Hz)')
            
            if strcmp(scale, 'raw')
                
                ylabel('Power density(uV^2 / Hz)')
                
            else
                ylabel('Power density(Log uV^2 / Hz)')
                
            end
        end
        
        for nband = 1:length(list_band_name)            
            spectra_sub.roi(nroi).band(nband).name = list_band_name{nband};            
            band_analysis = list_band_lim(nband,:);            
            sel_band = spectra_sub.freqs >= band_analysis(1) & spectra_sub.freqs <= band_analysis(2);
%             spectra_sub.band = spectra_sub.freqs(sel_band);            
            roispectra_abs_band = roispectra_abs(sel_band);
            roispectra_rel_band = roispectra_rel(sel_band);            
            masxp_abs = max(roispectra_abs_band);
            masxp_rel = max(roispectra_rel_band);
            fmaxsp = spectra_sub.freqs(ismember(roispectra_abs,masxp_abs));
            fmaxsp = fmaxsp(1);            
            spectra_sub.roi(nroi).band(nband).masxp_abs = masxp_abs;
            spectra_sub.roi(nroi).band(nband).masxp_rel = masxp_rel;
            spectra_sub.roi(nroi).band(nband).fmaxsp = fmaxsp;            
            %             barsp = sum(roispectra_band' .* spectra_sub.band)/sum(roispectra_band);
            %             masxp_rel = spectra_sub.rel_spectra(ind_ch,ismember(roispectra,masxp_abs));
            
            
            %             spectra_sub.ch(nch).masxp_abs = masxp_abs;
            %             spectra_sub.ch(nch).barsp = barsp;
            %             spectra_sub.ch(nch).masxp_rel = masxp_rel;
            %             spectra_sub.ch(nch).fmaxsp = fmaxsp;
            
            
            %             spectra_sub.ch(nch).abs_spectra = spectra_sub.abs_spectra(ind_ch,:);
            %             spectra_sub.ch(nch).rel_spectra = spectra_sub.rel_spectra(ind_ch,:);
            
            if strcmp(plot_single_subject,'on')
                hold on
                plot([fmaxsp fmaxsp],get(hax,'YLim'),'Color',list_col{nband},'LineWidth',2)
                hold on
                
                
                %             plot([barsp barsp],get(hax,'YLim'),'Color','green','LineWidth',2)
                str_leg = ['Spectrum',list_band_name];
                
                legend(str_leg)
                %             legend('Spectrum')
            end
        end
        
        
        if strcmp(plot_single_subject,'on')
            suptitle2(plot_label_ch);
            
            inputsf.plot_dir    = plot_dir_ch;
            inputsf.fig         = fig;
            inputsf.name_embed  = 'subject_spectra_ch';
            inputsf.suffix_plot = ['subject_spectra_ch',plot_label_ch];
            save_figures(inputsf,'res','-r100');
        end
        
        
    end
    
    
    
    
    
    
    
    
    
   
    
    %% plot relative spectra
     for nroi  = 1:length(list_roi_name)        
%         spectra_sub.roi(nroi).name = list_roi_name{nroi};        
%         chan_analysis =  list_roi_ch{nroi};        
%         spectra_sub.roi(nroi).ch = chan_analysis;        
%         sel_ch = ismember(allch,chan_analysis);
        %         tch = length(sel_ch);
        
        %         ind_ch = sel_ch(nch);
        %         ch_lab = allch{ind_ch};
        %         spectra_sub.ch(nch).ch_lab = ch_lab;
        
%         roispectra_abs = mean(spectra_sub.abs_spectra(sel_ch,:),1);        
%         ss = sum(roispectra_abs);
%         roispectra_rel = roispectra_abs./ss*100;        
%         spectra_sub.roi(nroi).roispectra_abs = roispectra_abs;
%         spectra_sub.roi(nroi).roispectra_rel = roispectra_rel;

        if strcmp(plot_single_subject,'on')
            fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
            hax=axes;
            
            plot_label_ch = [plot_label,'_',spectra_sub.roi(nroi).name];
            
            plot(spectra_sub.roi(nroi).roispectra_rel,'LineWidth',2);
            
            if(not(isempty(ylim_rel)))
                ylim(ylim_rel)
            end
            xlabel('Frequency (Hz)')
            
            if strcmp(scale, 'raw')
                
                ylabel('Power density(% / Hz)')
                
            else
                ylabel('Power density(% / Hz)')
                
            end
        end
        
        for nband = 1:length(list_band_name)            
%             spectra_sub.roi(nroi).band(nband).name = list_band_name{nband};            
%             band_analysis = list_band_lim(nband,:);            
%             sel_band = spectra_sub.freqs >= band_analysis(1) & spectra_sub.freqs <= band_analysis(2);
% %             spectra_sub.band = spectra_sub.freqs(sel_band);            
%             roispectra_abs_band = roispectra_abs(sel_band);
%             roispectra_rel_band = roispectra_rel(sel_band);            
%             masxp_abs = max(roispectra_abs_band);
%             masxp_rel = max(roispectra_rel_band);
%             fmaxsp = spectra_sub.freqs(ismember(roispectra_abs,masxp_abs));
%             fmaxsp = fmaxsp(1);            
%             spectra_sub.roi(nroi).band(nband).masxp_abs = masxp_abs;
%             spectra_sub.roi(nroi).band(nband).masxp_rel = masxp_rel;
%             spectra_sub.roi(nroi).band(nband).fmaxsp = fmaxsp;            
            %             barsp = sum(roispectra_band' .* spectra_sub.band)/sum(roispectra_band);
            %             masxp_rel = spectra_sub.rel_spectra(ind_ch,ismember(roispectra,masxp_abs));
            
            
            %             spectra_sub.ch(nch).masxp_abs = masxp_abs;
            %             spectra_sub.ch(nch).barsp = barsp;
            %             spectra_sub.ch(nch).masxp_rel = masxp_rel;
            %             spectra_sub.ch(nch).fmaxsp = fmaxsp;
            
            
            %             spectra_sub.ch(nch).abs_spectra = spectra_sub.abs_spectra(ind_ch,:);
            %             spectra_sub.ch(nch).rel_spectra = spectra_sub.rel_spectra(ind_ch,:);
            
            if strcmp(plot_single_subject,'on')
                hold on
                plot([spectra_sub.roi(nroi).band(nband).fmaxsp spectra_sub.roi(nroi).band(nband).fmaxsp],get(hax,'YLim'),'Color',list_col{nband},'LineWidth',2)
                hold on
                
                
                %             plot([barsp barsp],get(hax,'YLim'),'Color','green','LineWidth',2)
                str_leg = ['Spectrum',list_band_name];
                
                legend(str_leg)
                %             legend('Spectrum')
            end
        end
        
        
        if strcmp(plot_single_subject,'on')
            suptitle2(plot_label_ch);
            
            inputsf.plot_dir    = plot_dir_ch_abs;
            inputsf.fig         = fig;
            inputsf.name_embed  = 'subject_spectra_ch';
            inputsf.suffix_plot = ['subject_spectra_ch',plot_label_ch];
            save_figures(inputsf,'res','-r100');
        end
    end
    
    
    
    
    for nch  = 1:length(allch)        
        spectra_sub.ch(nch).name = allch{nch};        
        chan_analysis =  allch{nch};        
        spectra_sub.ch(nch).ch = chan_analysis;        
        sel_ch = ismember(allch,chan_analysis);
       
        
        chspectra_abs = mean(spectra_sub.abs_spectra(sel_ch,:),1); 
        chspectra_log = mean(spectra_sub.log_spectra(sel_ch,:),1);        
		
        ss = sum(chspectra_abs);
        chspectra_rel = chspectra_abs./ss*100;        
        spectra_sub.ch(nch).chspectra_abs = chspectra_abs;
        spectra_sub.ch(nch).chspectra_rel = chspectra_rel;
        spectra_sub.ch(nch).chspectra_log = chspectra_log;

%         if strcmp(plot_single_subject,'on')
%             fig=figure('color','w','visible','off'); % creo una figura che avrà tanti sub-plot quanti sono i livelli del secondo fattore
%             hax=axes;
%             
%             plot_label_ch = [plot_label,'_',list_roi_name{nroi}];
%             
%             plot(spectra_sub.freqs,roispectra_abs,'LineWidth',2);
%             xlabel('Frequency (Hz)')
%             
%             if strcmp(scale, 'raw')
%                 
%                 ylabel('Power density(uV^2 / Hz)')
%                 
%             else
%                 ylabel('Power density(Log uV^2 / Hz)')
%                 
%             end
%         end
        
        for nband = 1:length(list_band_name)            
            spectra_sub.ch(nch).band(nband).name = list_band_name{nband};            
            band_analysis = list_band_lim(nband,:);            
            sel_band = spectra_sub.freqs >= band_analysis(1) & spectra_sub.freqs <= band_analysis(2);
            chspectra_abs_band = chspectra_abs(sel_band);
            chspectra_rel_band = chspectra_rel(sel_band);            
            masxp_abs = max(chspectra_abs_band);
            masxp_rel = max(chspectra_rel_band);
            fmaxsp = spectra_sub.freqs(ismember(chspectra_abs,masxp_abs));
            fmaxsp = fmaxsp(1);            
            spectra_sub.ch(nch).band(nband).masxp_abs = masxp_abs;
            spectra_sub.ch(nch).band(nband).masxp_rel = masxp_rel;
            spectra_sub.ch(nch).band(nband).fmaxsp = fmaxsp;            
           
            
%             if strcmp(plot_single_subject,'on')
%                 hold on
%                 plot([fmaxsp fmaxsp],get(hax,'YLim'),'Color',list_col{nband},'LineWidth',2)
%                 hold on
%                 
%                 
%                 %             plot([barsp barsp],get(hax,'YLim'),'Color','green','LineWidth',2)
%                 str_leg = ['Spectrum',list_band_name];
%                 
%                 legend(str_leg)
%                 %             legend('Spectrum')
%             end
        end
        
        
%         if strcmp(plot_single_subject,'on')
%             suptitle2(plot_label_ch);
%             
%             inputsf.plot_dir    = plot_dir_ch;
%             inputsf.fig         = fig;
%             inputsf.name_embed  = 'subject_spectra_ch';
%             inputsf.suffix_plot = ['subject_spectra_ch',plot_label_ch];
%             save_figures(inputsf,'res','-r100');
%         end
        
        
    end
    
    
    
    
    
    
    
    
    %     close all
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)
    disp(EEG.filename)
    pause()
end
end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
