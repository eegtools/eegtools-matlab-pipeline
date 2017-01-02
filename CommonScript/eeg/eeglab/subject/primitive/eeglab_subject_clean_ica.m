function [name_noext, EEG] = eeglab_subject_clean_ica(input_file_name, output_path, varargin)
% funzione per testare/usare come supporto toolbox eeglab che eliminano
% artefatti usando ica (a differenza della pca come nell'algoritmo di ASR)

[~, name_noext, ~] = fileparts(input_file_name);

% DEFAULTS
% gpu_id=0;
out_file_name=name_noext;

cfg.MARA.enable = 1;
cfg.ADJUST.enable      = 1;


cfg.FASTER.enable = 0;
cfg.FASTER.blinkchanname = 'vEOG';

cfg.chancorr.enable = 0;
cfg.chancorr.channames = {};

cfg.EOGcorr.enable = 0; 
cfg.EOGcorr.Veogchannames = 'vEOG';
cfg.EOGcorr.corthreshV    = 0.6;
cfg.EOGcorr.Heogchannames = 'hEOG';
cfg.EOGcorr.corthreshH    = 0.6;

cfg.resvar.enable = 1;
cfg.resvar.thresh = 15;

cfg.SNR.enable    = 0;
cfg.SNR.snrcut    = 1;
cfg.SNR.snrBL     = [-Inf 0];
cfg.SNR.snrPOI    = [0 Inf];

cfg.trialfoc.enable = 0;
cfg.trialfoc.focaltrialout = 'auto';

cfg.focalcomp.enable = 1;
cfg.focalcomp.focalICAout = 'auto';

cfg.autocorr.enable = 1;
cfg.autocorr.autocorrint = 20;
cfg.autocorr.dropautocorr = 'auto';

cfg.opts.noplot    = 1;
cfg.opts.nocompute = 0;
cfg.opts.FontSize  = 14;



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
    
    
    EEG = pop_loadset(input_file_name);
    
    
    if sum(ismember({EEG.chanlocs.labels},'vEOG')     )
        
       
        cfg.FASTER.enable = 1;
        
        cfg.EOGcorr.enable = 1;
        
        cfg.chancorr.enable = 1;
        cfg.chancorr.channames = [cfg.chancorr.channames,'vEOG'];        
        cfg.chancorr.corthresh = 0.6;
        
        
    end
    
    
    if sum(ismember({EEG.chanlocs.labels},'hEOG')     )
        
        cfg.chancorr.enable = 1;
        cfg.chancorr.channames = [cfg.chancorr.channames,'hEOG'];        
        cfg.chancorr.corthresh = 0.6;
        
        cfg.EOGcorr.enable = 1;
        
        
    end
    
    
    
    %     ll1 = length(eeg_ch_list);
    %     ll2 = length({EEG.chanlocs.labels});
    %     ll = min(ll1,ll2);
    %
    %     % if ll < length(eeg_ch_list)
    %     eeg_ch_list = 1:ll;
    %     % end
    %
    %     sel_ch_ref = true(1,ll);
    %
    %     if not(isempty(ch_ref))
    %         if not(strcmp(ch_ref{1}, 'CAR'))
    %             sel_ch_ref  = ismember({EEG.chanlocs(1:ll).labels}, ch_ref);
    %             eeg_ch_list = eeg_ch_list(not(sel_ch_ref));
    %         end
    %     end
    %
    %     rr1 = ll;length(eeg_ch_list); % rango pieno
    %     rr2 = getrank_eeg(EEG.data(1:ll,: )); % rango reale stimato da eeglab
    %
    %     drr = rr1-rr2; % differenza
    %
    %
    %     if ( not(exist('cudaica'))  ||  drr>2)  % se non c'è cudaica o se il rango è deficiente (cosa che non viene gestita da cudaica)
    %         str = computer; % verifica so
    %         if strcmp(str,'GLNXA64') % se linux puoi usare binica un po' più veloce
    %             ica_type = 'binica';
    %         else % sennò usa runica standard
    %             ica_type = 'runica';
    %         end
    %     end
    %     fprintf('#EEG channels:%d actual rank:%d difference:%d uso: %s\n',rr1,rr2,drr,ica_type)
    %     pause(3)
    %
    %     tic
    %
    %     %     if gpu_id>0
    %     if strcmp(ica_type,'cudaica')
    %         EEG = pop_runica_octave_matlab(EEG, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 'd' gpu_id });
    %         %         end
    %     else % se ho rango deficitario o non posso usare cudaica, allora uso binica con sottocampionamento (pare che ica funzioni meglio), poi copio i pesi della scomposizione nei dati originali.
    %         EEG2 = pop_resample( EEG, 128);
    %         EEG2 = pop_runica_octave_matlab(EEG2, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 'pca' (rr2-1)});
    %
    %         EEG.icaweights = EEG2.icaweights;
    %         EEG.icasphere  = EEG2.icasphere;
    %         EEG.icachansind  = EEG2.icachansind;
    %         EEG.icawinv  = EEG2.icawinv;
    %
    %     end
    %
    %     duration = toc/60;
    %
    %     if strcmp(ica_type, 'cudaica')
    %         delete('cudaica*');
    %     end
    %
    %     if strcmp(ica_type, 'binica')
    %         delete('binica*');
    %     end
    %
    %     if isempty(EEG.icaact)
    %         EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(eeg_ch_list, :);
    %     end
    %     disp(EEG.filename)
    %     EEG = pop_saveset( EEG, 'filename',out_file_name,'filepath',output_path);
    %
    %
    EEG = pop_ICMARC_interface(EEG, 'established_features', 1);
    disp(EEG.filename)
    EEG = pop_saveset( EEG, 'filename',out_file_name,'filepath',output_path);
    
    %    load('cfg_SASICA');
    
    
    
    
    EEG = eeg_SASICA(EEG,cfg);
    
    %     [EEG, com]= SASICA(EEG,'MARA_enable',1,'FASTER_enable',0,'FASTER_blinkchanname','hEOG',...
    %         'ADJUST_enable',1,'chancorr_enable',0,'chancorr_channames','hEOG','chancorr_corthresh',0.6,...
    %         'EOGcorr_enable',1,'EOGcorr_Heogchannames','hEOG','EOGcorr_corthreshH',0.7,...
    %         'EOGcorr_Veogchannames','No channel','EOGcorr_corthreshV',0.7,'resvar_enable',1,'resvar_thresh',15,...
    %         'SNR_enable',0,'SNR_snrcut',1,'SNR_snrBL',[-Inf 0] ,'SNR_snrPOI',[0 Inf] ,...
    %         'trialfoc_enable',0,'trialfoc_focaltrialout','auto','focalcomp_enable',1,'focalcomp_focalICAout','auto',...
    %         'autocorr_enable',1,'autocorr_autocorrint',20,'autocorr_dropautocorr','auto','opts_noplot',1,'opts_nocompute',0,'opts_FontSize',14);
    %
    
    
    
    
    
    
    disp(EEG.filename)
    EEG = pop_saveset( EEG, 'filename',out_file_name,'filepath',output_path);
    
    close all
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)
    disp(EEG.filename)
%     disp(rr2)
    pause()
end
end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
