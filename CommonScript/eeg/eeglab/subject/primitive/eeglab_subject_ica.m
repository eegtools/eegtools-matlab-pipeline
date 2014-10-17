   function EEG = eeglab_subject_ica(input_file_name, output_path, eeg_ch_list, ica_type, varargin)
%    
%    function EEG = eeglab_subject_ica(input_file_name, settings_path,  output_path, ica_type)%
%    computes ica decompositions and saves the data with the decomposition in the same file
%    input_file_name is the full path of the input file (.set EEGLab format)
%    output_path is the folder where files with the ica decomposition will be placed
%    eeg_ch_list is the list of EEG channels id
%    ica_type is the algorithm employed to peform ica decomposition (see EEGLab manua, eg. 'runica'). The cuda implementation of ica ('cudaica') 
%    is only available on linux or mac and only if the PC has been previously properly configured   

    [path,name_noext,ext] = fileparts(input_file_name);
    
    % DEFAULTS
    gpu_id=0;
    out_file_name=name_noext;
    
    options_num=size(varargin,2);
    for opt=1:options_num
        switch varargin{opt}
            case 'gpu_id'
                opt=opt+1;
                gpu_id=varargin{opt};
            case 'ofn'
                opt=opt+1;
                out_file_name=varargin{opt};
        end
    end
    % ......................................................................................................
  
    EEG = pop_loadset(input_file_name);
    
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

    
