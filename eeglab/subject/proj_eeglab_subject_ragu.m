%% EEG = proj_eeglab_subject_add_factor(project, varargin)
%
%%
function EEG = proj_eeglab_subject_ragu(project, varargin)



EEG = [];

if not(isfield(project.epoching, 'custom_suffix') )
    project.epoching.custom_suffix = '';
end

if not(isfield(project.epoching, 'custom_input_folder') )
    project.epoching.custom_input_folder = '';
end

custom_suffix = project.epoching.custom_suffix;
custom_input_folder     = project.epoching.custom_input_folder;


list_select_subjects    = project.subjects.list;
get_filename_step       = 'ragu';
% custom_suffix           = '';
% custom_input_folder     = '';

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
% -------------------------------------------------------------------------------------------------------------------------------------

dir_data_ragu = fullfile(project.paths.output_epochs,'data_ragu');
dir_out_ragu = fullfile(dir_data_ragu,'out_ragu');
if not(exist(dir_out_ragu))
    mkdir(dir_out_ragu);
end
FileToSave = fullfile(dir_out_ragu,'RaguDataWithResults.mat');

Schema_60 = load(fullfile(dir_data_ragu,'info','Schema_60.mat'));

%% Open Ragu
%-------------------------------------------------------------------------
RaguHandle = Ragu;


%% import
if project.ragu.do_SlurpData
    disp(['Import data to Ragu from ', dir_data_ragu])
    [res,Names,msg] = SlurpData(project.ragu.data_str,...
        project.ragu.data_conds,...
        dir_data_ragu);
    
    
    rd.V = res;
    rd.IndFeature = ones(size(Names,1),1);
    rd.Design= project.ragu.Design;
    rd.PTanova = [];
    rd.TanovaEffectSize = [];
    rd.GFPPTanova = [];
    rd.GFPTanovaEffectSize = [];
    rd.MeanGFP = [];
    rd.pTopCons = [];
    rd.TanovaHits = [];
    rd.CritDuration = ones(size(project.ragu.Design))'*10^15;
    rd.PHitCount = [];
    rd.PHitDuration = [];
    rd.MSMaps = [];
    rd.MSEffectSize = [];
    rd.pMSStats = [];
    rd.LastPath= dir_data_ragu;
    rd.Threshold = project.ragu.Threshold;
    rd.Iterations = project.ragu.Iterations;
    rd.strF1 = project.ragu.strF1;
    rd.strF2 = project.ragu.strF2;
    rd.IndName= 'Group';
    rd.Normalize = 1;
    rd.FrequencyDomain = 0;
    rd.DoAnTopFFT = 0;
    rd.NoXing = 0;
    rd.txtX = 'ms';
    rd.DeltaX = 1/Schema_60.srate;
    rd.TimeOnset = Schema_60.xmin;
    rd.StartFrame = [];
    rd.EndFrame = [];
    rd.ContBetween = 0;
    rd.BarGraph = 0;
    rd.TwoFactors = 1;
    rd.ContF1 = 0;
    rd.MapStyle = 2;
    rd.DoGFP = 0;
    rd.OptStart = 3;
    rd.OptEnd = 10;
    rd.OptNTraining = 0;
    rd.FixedK = 0;
    rd.NoInconsistentMaps = 0;
    rd.FDR = 0.2000;
    rd.XValRestarts = 50;
    rd.Names= Names;
    rd.conds= project.ragu.data_conds;
    rd.Directory = dir_data_ragu;
    rd.Mask = project.ragu.data_str;
    rd.MakeAR = 1;
    rd.rd.AllowMissing = 0;
    rd.ExcelBasedImport = 0;
    rd.ExcelFileNameTable= '*.xlsx';
    rd.GroupLabels = {''};
    rd.Channel= Schema_60.Channel;
    rd.SelFactor = 2;
    rd.DLabels1= project.ragu.DLabels1;
    rd.DLabels2= project.ragu.DLabels2;
    rd.FileName = FileToSave;
    
    save(FileToSave,'rd');
    
end

% NB CLA probabilmente bisogna prima creare la struttura, salvare il file e
% caricarlo dentro ragu per evitare casini

% 
%       V: [3×7×60×230 double]
%              IndFeature: [3×1 double]
%                  Design: [7×2 double]
%                 PTanova: []
%        TanovaEffectSize: []
%              GFPPTanova: []
%     GFPTanovaEffectSize: []
%                 MeanGFP: []
%                pTopCons: []
%              TanovaHits: []
%            CritDuration: [2×4 double]
%               PHitCount: []
%            PHitDuration: []
%                  MSMaps: []
%            MSEffectSize: []
%                pMSStats: []
%                LastPath: 'C:\projects\test_ragu\'
%               Threshold: 0.0500
%              Iterations: 5000
%                   strF1: 'session'
%                   strF2: 'condition'
%                 IndName: 'Group'
%            MeanInterval: 0
%               Normalize: 1
%         FrequencyDomain: 0
%              DoAnTopFFT: 0
%                  NoXing: 0
%                    txtX: 'ms'
%                  DeltaX: 3.9063
%               TimeOnset: 0.1992
%              StartFrame: []
%                EndFrame: []
%             ContBetween: 0
%                BarGraph: 0
%              TwoFactors: 1
%                  ContF1: 0
%                MapStyle: 2
%                   DoGFP: 0
%                OptStart: 3
%                  OptEnd: 10
%            OptNTraining: 0
%                  FixedK: 0
%      NoInconsistentMaps: 0
%                     FDR: 0.2000
%            XValRestarts: 50
%                   Names: {3×7 cell}
%                   conds: {7×1 cell}
%               Directory: 'C:\projects\lateblind_abbi\toragu2'
%                    Mask: '*s-s2-1sc-1tl_PRE*'
%                  MakeAR: 1
%            AllowMissing: 0
%        ExcelBasedImport: 0
%      ExcelFileNameTable: '*.xlsx'
%             GroupLabels: {''}
%                 Channel: [1×60 struct]
%               SelFactor: 2
%                DLabels1: [1×2 struct]
%                DLabels2: [1×3 struct]
%                FileName: 'C:\projects\test_ragu\TEST.mat'



% Load a particular Ragu file
%-------------------------------------------------------------------------
% DataFileName = 'E:\Dropbox (PUK)\Docs\MATLAB\Ragu\Demo\Sample Maria Normalized.mat';
Ragu('LoadFile',RaguHandle,FileToSave);


if project.ragu.SetRandomizationOptions
    
    RaguHandle=Ragu;
    Ragu('SetRandomizationOptions',...
        project.ragu.RaguHandle,...
        project.ragu.nRuns,...
        project.ragu.pThreshold,...
        project.ragu.Normalize,...
        project.ragu.NoFactXing);   
    
    %% Finally, we save the Ragu file, including all the results
    Ragu('SaveFile',RaguHandle,FileToSave);
end


if project.ragu.do_SetAnalysisWindow
    
    
    
    % %% Now we set the analysis time period
    % %-------------------------------------------------------------------------
    % StartTime = []; % This is the onset of the analysis window. An empty matrix
    %                 % sets the start time to the beginning of the data
    %
    % EndTime   = []; % This is the ffset of the analysis window. An empty matrix
    %                 % sets the end time to the end of the data
    %
    % DoAverage = false;  % Sets whether the computations shall be done on the
    %                     % average of the time period, or time-point-wise
    %
    Ragu('SetAnalysisWindow',RaguHandle,project.ragu.StartTime,project.ragu.EndTime,project.ragu.DoAverage);

    Ragu('SaveFile',RaguHandle,FileToSave);

end
%% This does the TCT
%-------------------------------------------------------------------------
OutputPDF = fullfile(dir_out_ragu,'TCTResult.pdf');
Ragu('ComputeTCT',RaguHandle,OutputPDF)
                    
%% This is the computation of the TANOVA                    
%-------------------------------------------------------------------------
OutputPDF = fullfile(dir_out_ragu,'TANOVAResult.pdf');
Ragu('ComputeTanova',RaguHandle,OutputPDF);

%% This is the computation of the GFP stats
%-------------------------------------------------------------------------
OutputPDF = fullfile(dir_out_ragu,'GFPResult.pdf');
Ragu('ComputeGFPStats',RaguHandle,OutputPDF);

%% Finally, we save the Ragu file, including all the results
Ragu('SaveFile',RaguHandle,FileToSave);

%% And we close the whole thing
Ragu('Byebye',RaguHandle);


end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name


