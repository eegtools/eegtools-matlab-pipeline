function [name_noext, rr2,ica_type,duration, EEG] = eeglab_subject_ica(input,varargin)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition
%    in the same filei
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured


input_file_name             = input.input_file_name;
output_path                 = input.output_path;
eeg_ch_list                 = input.eeg_ch_list;
ch_ref                      = input.ch_ref;
ica_type                    = input.ica_type;
do_pca                      = input.do_pca;
ica_sr                      = input.ica_sr;
do_subsample                = input.do_subsample;
acquisition_system          = input.acquisition_system;
montage_list                = input.montage_list;
montage_names               = input.montage_names;

select_montage         = ismember(montage_names,acquisition_system);
ch_montage             = montage_list{select_montage};


[~, name_noext, ext] = fileparts(input_file_name);

% DEFAULTS
gpu_id=0;
out_file_name=name_noext;


for par=1:2:length(varargin)
    switch varargin{par}
        case {'gpu_id', 'ofn'}
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

% ......................................................................................................

% CLA inserisco passaggio a modalità base (non cudaica) su pc che non
% hanno cudaica


try
    
    % rimuovo la media da ogni canale
    EEG = pop_loadset(input_file_name);    
    mm = repmat(mean(EEG.data,2),1,EEG.pnts);    
    EEG.data = EEG.data - mm;
    
    dataset_ch_lab = {EEG.chanlocs.labels};
    dataset_eeg_ch_lab = intersect(dataset_ch_lab,ch_montage);
    dataset_eeg_ch_list = 1:length(dataset_eeg_ch_lab);
    
    
    ll1 = length(eeg_ch_list);
    ll2 = length(dataset_eeg_ch_list);
    ll = min(ll1,ll2);
    
    % if ll < length(eeg_ch_list)
    eeg_ch_list = 1:ll;
    % end
    
    sel_ch_ref = true(1,ll);
    
    if not(isempty(ch_ref))
        if not(length(ch_ref)>1 )
            if not(strcmp(ch_ref{1}, 'CAR'))
                sel_ch_ref  = ismember({EEG.chanlocs(1:ll).labels}, ch_ref);
                eeg_ch_list = eeg_ch_list(not(sel_ch_ref));
            end
        end
    end
    
    rr1 = ll;length(eeg_ch_list); % rango pieno
    rr2 = getrank_eeg(EEG.data(1:ll,: )); % rango reale stimato da eeglab
    
    drr = rr1-rr2; % differenza
    
    if not(strcmp(ica_type,'runica'))
        if ( not(exist('cudaica'))  ||  drr>2)  % se non c'è cudaica o se il rango è deficiente (cosa che non viene gestita da cudaica)
            str = computer; % verifica so
            if strcmp(str,'GLNXA64') % se linux puoi usare binica un po' più veloce
                ica_type = 'binica';
            else % sennò usa runica standard
                ica_type = 'runica';
            end
        end
    end
    fprintf('#EEG channels:%d actual rank:%d difference:%d uso: %s\n',rr1,rr2,drr,ica_type)
    if do_pca
         disp('use actual rank (preliminary pca)');
    else
        disp('use theoretical rank (NO preliminary pca, let ICA function adjust)');
    end
    pause(3)
    
    tic
    
    %     if gpu_id>0
    if strcmp(ica_type,'cudaica')
        EEG = pop_runica_octave_matlab(EEG, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 'd' gpu_id });
        %         end
    else % se ho rango deficitario o non posso usare cudaica, allora uso binica/runica con sottocampionamento (pare che ica funzioni meglio), poi copio i pesi della scomposizione nei dati originali.
        if do_subsample
            EEG2 = pop_eegfiltnew( EEG,1, floor(ica_sr/2), [], 0, [], 0);
            EEG2 = pop_resample( EEG2, ica_sr);
        else
            EEG2 = EEG;
        end
        
        if do_pca
            EEG2 = pop_runica_octave_matlab(EEG2, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 'pca' (rr2-1)});
        else
            EEG2 = pop_runica_octave_matlab(EEG2, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 });

        end
        
        EEG.icaweights = EEG2.icaweights;
        EEG.icasphere  = EEG2.icasphere;
        EEG.icachansind  = EEG2.icachansind;
        EEG.icawinv  = EEG2.icawinv;
        
    end
    
    duration = toc/60;
    
    if strcmp(ica_type, 'cudaica')
        delete('cudaica*');
    end
    
    if strcmp(ica_type, 'binica')
        delete('binica*');
    end
    
    if isempty(EEG.icaact)
        EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(eeg_ch_list, :);
    end
    disp(EEG.filename)
    EEG = pop_saveset( EEG, 'filename',[out_file_name,ext],'filepath',output_path);
    EEG = pop_saveset( EEG, 'filename',[name_noext,'_icabck',ext],'filepath',output_path);

    
    icadir = fullfile(output_path,'icadir');
    if not(exist(icadir))
        mkdir(icadir)
    end
    
    out_ica.icaweights = EEG.icaweights;
    out_ica.icasphere  = EEG.icasphere;
    out_ica.icachansind  = EEG.icachansind;
    out_ica.icawinv  = EEG.icawinv;
    out_ica.icaact = EEG.icaact;
    fname_out_ica = fullfile(icadir,[name_noext, '.mat']);
    save(fname_out_ica,'out_ica');
    
    
%     EEG = pop_ICMARC_interface(EEG, 'established_features', 1);
%     disp(EEG.filename)
%     EEG = pop_saveset( EEG, 'filename',out_file_name,'filepath',output_path);
%     
%    load('cfg_SASICA');
%     EEG = eeg_SASICA(EEG,cfg);
    
   
    
    
    
   
    
    
%     disp(EEG.filename)
%     EEG = pop_saveset( EEG, 'filename',[out_file_name,ext],'filepath',output_path);
    
    close all
catch err
    
    % This "catch" section executes in case of an error in the "try" section
    err
    err.message
    err.stack(1)
    disp(EEG.filename)
    disp(rr2)
    pause()
end
end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
