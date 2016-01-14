function EEG = eeglab_subject_ica(input_file_name, output_path, eeg_ch_list, ch_ref, ica_type, varargin)
%
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition in the same file
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica')
%    is only available on linux or mac and only if the PC has been previously properly configured

    [~, name_noext, ~] = fileparts(input_file_name);

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
    if (not(exist('cudaica'))
        ica_type = 'runica';
    end
    
    
    EEG = pop_loadset(input_file_name);

    ll = length({EEG.chanlocs.labels});
    if ll < length(eeg_ch_list)
        eeg_ch_list = 1:ll;
    end

    if not(isempty(ch_ref))
        if not(strcmp(ch_ref{1}, 'CAR'))
            sel_ch_ref  = ismember({EEG.chanlocs(1:length(eeg_ch_list)).labels}, ch_ref);
            eeg_ch_list = eeg_ch_list(not(sel_ch_ref)); 
        end
    end

    if gpu_id>0
        EEG = pop_runica_octave_matlab(EEG, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1 'd' gpu_id});
    else
        EEG = pop_runica_octave_matlab(EEG, 'icatype',ica_type,'chanind',eeg_ch_list,'options',{'extended' 1});
    end

    if strcmp(ica_type, 'cudaica')
        delete('cudaica*');
    end
    if isempty(EEG.icaact)
        EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(eeg_ch_list, :);
    end
    EEG = pop_saveset( EEG, 'filename',out_file_name,'filepath',output_path);
end

%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
