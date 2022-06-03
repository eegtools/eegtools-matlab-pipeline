function h0 = spectrogramRpt_SingleCh_mean_norm(EEG,ch, stageStats)
% spectrogramRpt_SingleChed(EEG,ch, stageStats)
%
% Generic Spectrogram Creation Tool (requires signal processing toolbox
% and EEGLAB)
%
% Inputs (required)
%
% EEG - EEGLAB EEG Struct
%
% ch - string indicating Channel label to analyze (should match those
% in EEG (e.g., 'C3' or 'C3-A2', depending on data used). The
% function will currently fail if label is incorrect.
%
% Inputs (optional)
%
% stageStats - struct variable 'stageStats' as output of
% Hume sleep statistics. If included, the function will plot the
% hypnogram, and overlay NREM cycle averages of Delta/Sigma in Plots
% 3 and 4.
%
%% Copyright (c) 2019 Jared M. Saletin, PhD
%
% This file is part of Húmë.
%
% Húmë is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% Húmë is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with Húmë. If not, see <http://www.gnu.org/licenses/>.
%
% Húmë is intended for research purposes only. Any commercial or medical
% use of this software is prohibited. The authors accept no
% responsibility for its use in this manner.
%%
EEG = pop_select(EEG,'channel',find(strcmp({EEG.chanlocs.labels},ch)));

norm_label = 'mean_norm';

if ~isempty(stageStats)
    
    % Removes unscored data
    stageData = stageStats.stageData;
    
    % Epochs marked artifact
    artifactEpochs=[stageData.MarkedEvents{strcmp(stageData.MarkedEvents(:,1),'[0]'),3}];
    
    % Window definition
    win = stageStats.stageData.win;% stageData.win
    
    % The first scored epoch
    firstEp = min(find(stageData.stages ~= 7));
    
    % The last epoch
    lastEp = max(find(stageData.stages ~= 7));
    %EEG=pop_loadset(eeg);
    
    % The sampling rate (remember we re-set this in line 15)
    srate = EEG.srate;
    
    % Trim the EEG between first and last scored epochs
    if firstEp ~= 0
        
        EEG = pop_select(EEG,'point',[(1+(firstEp-1)*srate*win) ((lastEp)*srate*win)]);
    elseif firstEp == 0
        
        EEG = pop_select(EEG,'point',[1 ((lastEp)*srate*win)]);
    end
end



%% PWELCH



artifactEpochs = (artifactEpochs - firstEp)+1;
data = EEG.data;
data = buffer(data,30*EEG.srate,0)';
nfft=stageData.spect_win*EEG.srate;
spect = nan(size(data,1), nfft/2 + 1);
for i = 1:size(data,1)
    [pxx] = pwelch(data(i,:), stageData.spect_win*EEG.srate, [], stageData.spect_win*EEG.srate, EEG.srate);
    spect(i,:) = pxx;
end
spect(artifactEpochs,:) = nan;
spect=spect';
%cc
Flims = stageData.Flims_global;%[.05 20];
f = (0:1/(nfft/EEG.srate):EEG.srate/2);



scaleFactor = EEG.pnts / size(data,1);



h0=figure;
h0.Position=[1900 1000 840 1020];
h0.Name=['Spectrogram for Channel: ''',ch,''''];



if ~isempty(stageStats)
    k = 4;
    j=1;
    subplot(k, 1, j);
    
    stages = stageStats.stageData.stages(firstEp:lastEp);
    rasterStages = zeros(7,length(stages));
    for i = 1:length(stages)
        rasterStages(stages(i)+1,i)=1;
    end
    rasterStages=logical(rasterStages);
    plotSpikeRaster(rasterStages,'PlotType','vertline','TimePerBin',stageStats.stageData.win,'spikeDuration',stageStats.stageData.win);
    xlim([0, length(stages)/(60/stageStats.stageData.win)/60]);
    ylim([.5 7.5]);
    xlabel({'Time (hours)'});
    yticks([1:1:7]);
    set(gca,'YTickLabel',{'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'MT'});
    
    
    
    cycles=stageStats.cycleBoundsJenniSplit;
    
    for cy=1:size(cycles,1)
        cycleBegin=cycles(cy,1);
        cycleEnd = cycles(cy,2);
        if cycleEnd == 0
            cycleEnd = cycles(cy,3);
        end
        line([cycleBegin/(60/stageStats.stageData.win)/60 cycleBegin/(60/stageStats.stageData.win)/60],[.5 7.5],'Color','green','LineWidth',.75,'LineStyle','--');
        line([cycleEnd/(60/stageStats.stageData.win)/60 cycleEnd/(60/stageStats.stageData.win)/60],[.5 7.5],'Color','red','LineWidth',.75,'LineStyle','--');
    end
    
else
    k=3;
    j=0;
end



subplot(k,1,j+1);
%cc
specdata.plot_spect.x = [0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60;
specdata.plot_spect.y = f(min(find(f>=Flims(1))):max(find(f<=Flims(2))));
specdata.plot_spect.z = 10*log10(spect(min(find(f>=Flims(1))):max(find(f<=Flims(2))),:));
specdata.plot_spect.YDir = 'normal';
specdata.plot_spect.colormap = 'jet';
specdata.plot_spect.ylabel = {'Frequency (Hz)'};
specdata.plot_spect.xlabel = {'Time (hours)'};
specdata.plot_spect.colorbar_string = 'Power (db)';




h=imagesc(specdata.plot_spect.x, ...
    specdata.plot_spect.y,...
    specdata.plot_spect.z);
set(gca,'YDir','normal');
colormap(jet);
ylabel({'Frequency (Hz)'});
caxis([-20 20])
xlabel({'Time (hours)'});
%c=colorbar; c.Location = 'Southoutside';
c.Label.String = 'Power (db)';



%cc
% delta = trapz(spect(and(f>=.5,f<=4.75),:),1);
delta = trapz(spect(and(f>=stageData.Flims_delta(1),f<=stageData.Flims_delta(2)),:),1);




if ~isempty(stageStats)
    delta = (delta./nanmean(delta( intersect(stageStats.milestones(1,1):stageStats.milestones(2,1), find(and(stages>1,stages<5))) )))*100;
    legendText = ('% Whole Night NREM');
else
    delta = (delta./nanmean(delta))*100;
    legendText = ('% Whole Night');
end




subplot(k,1,j+2);



h2=area([0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60,delta,'EdgeAlpha',0,'FaceColor',[0 0 0],'FaceAlpha',[.45]);
h2.Parent.XLim = h.Parent.XLim;
ylim([0 prctile(delta,99)]);
xlabel({'Time (hours)'});
% cc
% ylabel({'Delta [0.6-4.6 Hz]'; legendText});
ylabel({['Delta [',num2str(stageData.Flims_delta(1)),'-',num2str(stageData.Flims_delta(2)),'Hz]']; legendText});




hold;
if ~isempty(stageStats)
    cycles=stageStats.cycleBoundsJenniSplit;
    
    for cy=1:size(cycles,1)
        cycleBegin=cycles(cy,1);
        cycleEnd = cycles(cy,2);
        if cycleEnd == 0
            cycleEnd = cycles(cy,3);
        end
        deltaCy(cy)=nanmean(delta(intersect(find(and(stages>1,stages<5)),cycleBegin:cycleEnd)));
        mid(cy)=median(cycleBegin:cycleEnd);
        line([cycleBegin/(60/stageStats.stageData.win)/60 cycleBegin/(60/stageStats.stageData.win)/60],ylim,'Color','green','LineWidth',.75,'LineStyle','--');
        line([cycleEnd/(60/stageStats.stageData.win)/60 cycleEnd/(60/stageStats.stageData.win)/60],ylim,'Color','red','LineWidth',.75,'LineStyle','--');
    end
    h25=plot(mid./((60/stageStats.stageData.win)*60),deltaCy,'k-s','MarkerSize',10,...
        'MarkerEdgeColor','black',...
        'MarkerFaceColor',[1 1 1],'LineWidth',2);
    %legend(h25,'Cycle NREM Avg');
    
    %TRY TO ESTIMATE TAU if DATA AVAILABLE; Use first cycle epoch of SWA as
    %guess, rest of starting values from Rusterholz 2010 mean restricted fit
    [param output] = SWA_Decay((mid.*stageStats.stageData.win)./60,deltaCy,[delta(cycles(1,1)) 43.68 2.16*60 ],2,4,2.16*60,2*60);
    h250=plot(nan,nan,'LineStyle','none');
    legend([h25, h250],{'NREM Delta by Cycle' ['Decay time-constant: ',num2str(param(3)/60),' h']});
end



%cc
% sigma = trapz(spect(and(f>=11.9,f<=15.1),:),1);
sigma = trapz(spect(and(f>=stageData.Flims_sigma(1),f<=stageData.Flims_sigma(2)),:),1);



if ~isempty(stageStats)
    sigma = (sigma./nanmean(sigma( intersect(stageStats.milestones(1,1):stageStats.milestones(2,1), find(and(stages>1,stages<5))) )))*100;
    legendText = ('% Whole Night NREM');
else
    sigma = (sigma./nanmean(sigma))*100;
    legendText = ('% Whole Night');
end



subplot(k,1,j+3);
h3=area([0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60,sigma,'EdgeAlpha',0,'FaceColor',[0 0 0],'FaceAlpha',[.45]);
h3.Parent.XLim = h.Parent.XLim;
ylim([0 prctile(sigma,99)]);
xlabel({'Time (hours)'});
% cc
ylabel({['Sigma [',num2str(stageData.Flims_sigma(1)),'-',num2str(stageData.Flims_sigma(2)),'Hz]']; legendText});
% ylabel({'Sigma [12-15 Hz]'; legendText});
hold;
if ~isempty(stageStats)
    cycles=stageStats.cycleBoundsJenniSplit;
    for cy=1:size(cycles,1)
        cycleBegin=cycles(cy,1);
        cycleEnd = cycles(cy,2);
        if cycleEnd == 0
            cycleEnd = cycles(cy,3);
        end
        
        sigmaCy(cy)=nanmean(sigma(intersect(find(and(stages>1,stages<5)),cycleBegin:cycleEnd)));
        mid(cy)=median(cycleBegin:cycleEnd);
        line([cycleBegin/(60/stageStats.stageData.win)/60 cycleBegin/(60/stageStats.stageData.win)/60],ylim,'Color','green','LineWidth',.75,'LineStyle','--');
        line([cycleEnd/(60/stageStats.stageData.win)/60 cycleEnd/(60/stageStats.stageData.win)/60],ylim,'Color','red','LineWidth',.75,'LineStyle','--');
    end
    h35=plot(mid./((60/stageStats.stageData.win)*60),sigmaCy,'k-s','MarkerSize',10,...
        'MarkerEdgeColor','black',...
        'MarkerFaceColor',[1 1 1],'LineWidth',2);
    legend(h35,{'NREM Sigma by Cycle'});
end
h4.Parent.XLim = h.Parent.XLim;




title(h0.Children(end), {EEG.filename;['Sleep Spectrogram Q/A Report: ', ch];'';''}, 'Interpreter', 'none');



specdata.spect = spect;
% specdata.spect.plot_spect = plot_spect;
specdata.delta = delta;
specdata.sigma = sigma;




specdatafile = fullfile(stageData.project.paths.project, 'hume',EEG.filename(1:end-4),[EEG.filename(1:end-4),'_',ch,'_',norm_label,'_specdata.mat']);



save(specdatafile,'specdata');



specfigfile = fullfile(stageData.project.paths.project, 'hume',EEG.filename(1:end-4),[EEG.filename(1:end-4),'_',ch,'_',norm_label,'_specdata.png']);
saveas(h, specfigfile);



% export band and single frequency data
% band
table_band.power = [specdata.delta,specdata.sigma]';
table_band.band = [repmat({'delta'},length(specdata.delta),1);repmat({'sigma'},length(specdata.sigma),1)];



stages_ind = stageStats.stageData.stages;
stages_label = repmat({'none'},length(stages_ind),1);



stage_ind_list = [0:5,7];
stage_label_list = stageStats.stageData.stageNames;



for ns = 1:length(stageStats.stageData.stageNames)
    current_stage_ind = stage_ind_list(ns);
    current_stage_label = stage_label_list(ns);
    
    sel_ind_label = stages_ind == current_stage_ind;
    stages_label(sel_ind_label) = current_stage_label;
end
sel_stages = not(stages_ind == 7);
cleaned_stages = stages_label(sel_stages);
table_band.sleep_stage = repmat(cleaned_stages,2,1);
table_band.normized_time = repmat(specdata.plot_spect.x,1,2)';
table_band = struct2table(table_band);
table_band_file = fullfile(stageData.project.paths.project, 'hume',EEG.filename(1:end-4),[EEG.filename(1:end-4),'_',ch,'_',norm_label,'_table_band.txt']);
writetable(table_band,table_band_file,'Delimiter','\t');



% frenquency
times_spect = specdata.plot_spect.x;
freqs_spect = specdata.plot_spect.y;
pow_spect_db = specdata.plot_spect.z;




pow_spect_uv2 = 10.^(pow_spect_db/10);
ss = sum(pow_spect_uv2);
ss2 = repmat(ss,length(freqs_spect),1);
pow_spect_perc =pow_spect_uv2./ss2*100; % in percentua




pow_table_db = [];
pow_table_uv2 = [];
pow_table_perc = [];
times_table = [];
stages_tabel = [];
freqs_table = [];



for nf = 1:length(freqs_spect)
    current_freq = freqs_spect(nf);
    pow_table_db = [pow_table_db,pow_spect_db(nf,:)];
    pow_table_uv2 = [pow_table_uv2,pow_spect_uv2(nf,:)];
    pow_table_perc = [pow_table_perc,pow_spect_perc(nf,:)];
    times_table = [times_table,times_spect];
    stages_tabel = [stages_tabel;cleaned_stages];
    freqs_table = [freqs_table;repmat(current_freq,length(times_spect),1)];
end
table_frequency.frequency = freqs_table;
table_frequency.power_db = pow_table_db';
table_frequency.power_uv2 = pow_table_uv2';
table_frequency.power_perc = pow_table_perc';
table_frequency.sleep_stage = stages_tabel;
table_frequency.normized_time = times_table';
table_frequency = struct2table(table_frequency);
table_frequency_file = fullfile(stageData.project.paths.project, 'hume',EEG.filename(1:end-4),[EEG.filename(1:end-4),'_',ch,'_',norm_label,'_table_frequency.txt']);
writetable(table_frequency,table_frequency_file,'Delimiter','\t');




end



function [param output] = SWA_Decay(t,S,x0,model,errtype,md,bd)



% [param output] = SWA_Decay(t,S,x0,model,errtype,md,bd)
%
%CODE FITS EXPONENTIONAL PROCESS S DECAY FUNCTION TO SWA DATA AT NREM-REM
% CYCLE MIDPOINTS VIA MINIMIZING EITHER MSE OR SSE ACCORDING TO
% NEWTON-MEAD's METHOD
%
% t: Time Data, S: SWA data matching t
%
% x0: Vector of Starting Guesses for the three parameters
%
% model: 1 = Model of simply SWA_0 (combined % onset SWA with lower
% asymptote). 2 = Model of SWA at onset seperately, leading to need to add
% with lower Asymtote to estiamte SWA at onset.
%
% errtype refers to the type of error function to minimize: 1)
% Unconstrained MSE (preferred for standard pooled data), 2)
% Unconstrained SSE (similar result, though not correcting for N; 3)
% Contrained MSE, with t in units of hours; 4) Constrained MSE, with t
% in units of minutes; Approaches 3 and 4 ideal for individual data, as per
% below reference
%
% md and bd are constrain parameters to limit the decay time constant to
% physiological levels, per Rusterholz, 2010 (SLEEP)



%%



% Setup Options for fminsearch; 'iter' flag will display all iterations,
% refer to matlab documention on optimset and fminsearch



if nargin < 6
    md = [];
    bd = [];
end



options = optimset('Display','iter');



% Minimize the error function of SWA_Decay given setup parameters

[param fval exitflag output] = fminsearch(@ErrorFunction,x0,options,t,S,model,errtype,md,bd);



if exitflag == 0 % Fitting Failed
    
    param = [NaN NaN NaN]; % Return null result
    
    
    
end

end



function [ERR]=ErrorFunction(param,t,S,model,errtype,md,bd)



% Error function to be minimized, either MSE (constrained or unconstrained
% or SSE, depending on paramters provided for errtype)



switch model
    case 1
        Yhat = ((param(1))*exp(-t/param(3)))+param(2); % Create modeled data
    case 2
        Yhat = ((param(1)-param(2))*exp(-t/param(3)))+param(2);
end



residuals = S - Yhat; % Residuals between model and data
SSE = sum(residuals.^2); % Sums of Squares of Error
MSE = SSE / ((length(t)-length(param))); % Mean Square Error



switch errtype
    case 1
        ERR = MSE;
    case 2
        ERR = SSE;
    case 3
        ERR = MSE * (1/sqrt((1-((param(3)-(md/60))/(bd/60))^2))); % Adjust MSE for boundaries (important for individual data, as simple decay function may not fit properly, see above reference).
    case 4
        ERR = MSE * (1/sqrt((1-((param(3)-(md))/(bd))^2)));
end



end