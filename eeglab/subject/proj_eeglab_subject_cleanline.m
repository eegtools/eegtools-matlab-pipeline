%% EEG = proj_eeglab_subject_ica(project, varargin)
% Mandatory             Information
%   --------------------------------------------------------------------------------------------------
%   EEG                   EEGLAB data structure
%   --------------------------------------------------------------------------------------------------
%
%   Optional              Information
%   --------------------------------------------------------------------------------------------------
%   LineFrequencies:      Line noise frequencies to remove
%                         Input Range  : Unrestricted
%                         Default value: 60
%                         Input Data Type: real number (double)
%
%   ScanForLines:         Scan for line noise
%                         This will scan for the exact line frequency in a narrow range around the specified LineFrequencies
%                         Input Range  : Unrestricted
%                         Default value: 1
%                         Input Data Type: boolean
%
%   LineAlpha:            p-value for detection of significant sinusoid
%                         Input Range  : [0  1]
%                         Default value: 0.01
%                         Input Data Type: real number (double)
%
%   Bandwidth:            Bandwidth (Hz)
%                         This is the width of a spectral peak for a sinusoid at fixed frequency. As such, this defines the
%                         multi-taper frequency resolution.
%                         Input Range  : Unrestricted
%                         Default value: 1
%                         Input Data Type: real number (double)
%
%   SignalType:          Type of signal to clean
%                         Cleaned ICA components will be backprojected to channels. If channels are cleaned, ICA activations
%                         are reconstructed based on clean channels.
%                         Possible values: 'Components','Channels'
%                         Default value  : 'Components'
%                         Input Data Type: string
%
%   ChanCompIndices:      IDs of Chans/Comps to clean
%                         Input Range  : Unrestricted
%                         Default value: 1:152
%                         Input Data Type: any evaluable Matlab expression.
%
%   SlidingWinLength:     Sliding window length (sec)
%                         Default is the epoch length.
%                         Input Range  : [0  4]
%                         Default value: 4
%                         Input Data Type: real number (double)
%
%   SlidingWinStep:       Sliding window step size (sec)
%                         This determines the amount of overlap between sliding windows. Default is window length (no
%                         overlap).
%                         Input Range  : [0  4]
%                         Default value: 4
%                         Input Data Type: real number (double)
%
%   SmoothingFactor:      Window overlap smoothing factor
%                         A value of 1 means (nearly) linear smoothing between adjacent sliding windows. A value of Inf means
%                         no smoothing. Intermediate values produce sigmoidal smoothing between adjacent windows.
%                         Input Range  : [1  Inf]
%                         Default value: 100
%                         Input Data Type: real number (double)
%
%   PaddingFactor:        FFT padding factor
%                         Signal will be zero-padded to the desired power of two greater than the sliding window length. The
%                         formula is NFFT = 2^nextpow2(SlidingWinLen*(PadFactor+1)). e.g. For SlidingWinLen = 500, if PadFactor = -1, we
%                         do not pad; if PadFactor = 0, we pad the FFT to 512 points, if PadFactor=1, we pad to 1024 points etc.
%                         Input Range  : [-1  Inf]
%                         Default value: 2
%                         Input Data Type: real number (double)
%
%   ComputeSpectralPower: Visualize Original and Cleaned Spectra
%                         Original and clean spectral power will be computed and visualized at end
%                         Input Range  : Unrestricted
%                         Default value: true
%                         Input Data Type: boolean
%
%   NormalizeSpectrum:    Normalize log spectrum by detrending (not generally recommended)
%                         Input Range  : Unrestricted
%                         Default value: 0
%                         Input Data Type: boolean
%
%   VerboseOutput:        Produce verbose output
%                         Input Range  : [true false]
%                         Default value: true
%                         Input Data Type: boolean
%
%   PlotFigures:          Plot Individual Figures
%                         This will generate figures of F-statistic, spectrum, etc for each channel/comp while processing
%                         Input Range  : Unrestricted
%                         Default value: 0
%                         Input Data Type: boolean
function EEG = proj_eeglab_subject_cleanline(project, varargin)



list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end

numsubj = length(list_select_subjects);
vsel_sub = find(ismember(project.subjects.list,list_select_subjects));

% -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};

for subj=1:numsubj
    sel_sub = vsel_sub(subj);
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    EEG = [];
    if(exist(inputfile))
        disp(inputfile);
        
        EEG                     = pop_loadset(inputfile);
        [fpath,fname,fext] = fileparts(inputfile);
        
        EEG = pop_saveset( EEG, 'filename',[fname,'_cleanlinebck', fext],'filepath',fpath);
        
        if isempty(project.cleanline.LineFrequencies)
            disp('select custom frequencies!!!!');
        else
            if strcmp(project.cleanline.notch_remove_armonics,  'first')
                LineFrequencies = project.cleanline.notch_remove_armonics(1);
            end
            
            if strcmp(project.cleanline.notch_remove_armonics,  'all')
                begin_fr = project.cleanline.LineFrequencies(1);
                step_fr = project.cleanline.LineFrequencies(1);
                end_fr = floor(EEG.srate/2)-step_fr;
                LineFrequencies = begin_fr:step_fr:end_fr;                    
            end
            
            if strcmp(project.cleanline.notch_remove_armonics,  'custom')                
                LineFrequencies = project.cleanline.notch_remove_armonics;
            end
        end
        
        
        
        EEG = pop_cleanline(EEG,...
            'bandwidth',project.cleanline.Bandwidth,...
            'chanlist',[1:EEG.nbchan] ,...
            'computepower',project.cleanline.ComputeSpectralPower,...
            'linefreqs',LineFrequencies,...
            'newversion',project.cleanline.newversion,...
            'normSpectrum',project.cleanline.NormalizeSpectrum,...
            'p',project.cleanline.LineAlpha,...
            'pad',project.cleanline.PaddingFactor,...
            'plotfigures',project.cleanline.PlotFigures,...
            'scanforlines',project.cleanline.ScanForLines,...
            'sigtype',project.cleanline.SignalType,...
            'taperbandwidth',project.cleanline.taperbandwidth,...
            'tau',project.cleanline.SmoothingFactor,...
            'verb',project.cleanline.VerboseOutput,...
            'winsize',project.cleanline.SlidingWinLength,...
            'winstep',project.cleanline.SlidingWinStep ...
            );
        
        
        
    else
        disp(['Not existing ', inputfile,' !!!!'])
    end
    
    EEG = pop_saveset( EEG, 'filename',[fname, fext],'filepath',fpath);
    
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
