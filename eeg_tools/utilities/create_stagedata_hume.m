function [stagedata_path] = create_stagedata_hume(filename,stagedatadir,reset_stageData,project)
%CREATE_MONTAGE_HUME Summary of this function goes here
%   Detailed explanation goes here
[fpath,fname,fext] = fileparts(filename);
EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);


stagedata_path = fullfile(stagedatadir,[fname,'.mat']);

if not(exist(stagedata_path)) || reset_stageData
    stageData.srate = EEG.srate;
    stageData.win = 30;% finestra di staging (standard AASM)
    nepo = round(EEG.xmax/stageData.win);
    
    dd = datetime(EEG.etc.T0);
    
    stageData.recStart = datenum(dd);
    stageData.lightsOFF = datenum(dd + seconds(3*stageData.win));
    stageData.lightsON = datenum(datestr(dd + seconds(EEG.xmax)));
    stageData.Notes = 'ciao';
    stageData.stages = repmat(7,nepo,1);
    stageData.onsets = zeros(nepo,1);
    stageData.stageTime = (0:nepo-1)*0.5;% times in minutes
    % stageData.MarkedEvents = {};    
    
    stageData.MarkedEvents{1,1} = '[0]';
    stageData.MarkedEvents{1,2} = stageData.win * EEG.srate +1;
    stageData.MarkedEvents{1,3} = 2;
    stageData.MarkedEvents{1,4} = nan;   
    

    % creo campi custom per gestire parametri
    stageData.Flims_global = project.sleep.hume.stageData.Flims_global;%[.05 20];
    stageData.Flims_delta = project.sleep.hume.stageData.Flims_delta;%[.5 4.75];
    stageData.Flims_sigma = project.sleep.hume.stageData.Flims_sigma;%[.05 20];
    stageData.project = project;
    stageData.spect_win = project.sleep.hume.stageData.spect_win;% window length for spectrogram calculation, default 5 secs
    
    
    disp('NOTE THAT WE KEEP THE STAGE 4 FOR COMPABILITY WITH HUME BUT THE NEW AASM RULES MERGE STAGE 3 AND 4!!!');
%     stageData.stageNames = {'wake'; 'stage1'; 'stage2'; 'stage3'; 'stage4'; 'rem'; 'mt'};
stageData.stageNames = project.sleep.hume.stageData.stageNames;% = {'W'; 'N1'; 'N2'; 'N3'; 'N4'; 'REM'; 'MT'}; % DO NOT EDIT: sleep stage coding for HUME
    
    save(stagedata_path,'stageData');
end
end

