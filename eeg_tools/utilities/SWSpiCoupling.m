function [out] = SWSpiCoupling(stageData, EEG, ch, spiEvent, swEvent)
%% Slow Wave


% select channel
EEG = pop_select(EEG, 'channel', find(strcmp(ch, {EEG.chanlocs.labels})));
% resample to 100 Hz
EEG = pop_resample(EEG, 100);
data = EEG.data;
spiData = bandpass_filter_ferrarelli(data, 100);
spiEnv = abs(hilbert(spiData));
swData = bandpass_filter_massimimi(data,100);

% Find spindles
spiEvents = [stageData.rectEvents{ismember([stageData.rectEvents(:,5)], spiEvent),7}];
spiStarts = ([stageData.rectEvents{ismember([stageData.rectEvents(:,5)], spiEvent),2}].*100);
spiEnds = ([stageData.rectEvents{ismember([stageData.rectEvents(:,5)], spiEvent),3}].*100);
%spipeaks = round(([spiEvents.spimaxi] ./ [spiEvents.fs]).*100);
for i=1:length(spiStarts)
    [~, maxi]= max(spiEnv(spiStarts(i):spiEnds(i)));
    spipeaks(i) = spiStarts(i)+maxi-1;
end


% Find SW
swEvents = [stageData.rectEvents{ismember([stageData.rectEvents(:,5)], swEvent),7}];
swStarts = round([swEvents.WaveStart] ./ [swEvents.fs]).*100;
swEnds = round([swEvents.WaveEnd] ./ [swEvents.fs]).*100;
swNegpeaks = ([swEvents.negPeakX] ./ [swEvents.fs]).*100;


swWithSpi = zeros(length(swEvents),1);

% Find spis inside SWs
for i = 1:length(spipeaks)
    minX = spipeaks(i) - 1*100;
    maxX = spipeaks(i) + 1*100;
    [swFound] = find(and(swNegpeaks>=minX, swNegpeaks<=maxX));
    spiSWs(i) = ~isempty(swFound);
    swWithSpi(swFound)=1;
end
spiWithSWs = find(spiSWs);
swWithSpi=find(swWithSpi);

for i =1:length(spiWithSWs)
    spiEpochs(:,i) = zscore(spiData((spipeaks(spiWithSWs(i))-1*100):(spipeaks(spiWithSWs(i))+1*100))');
    swEpochs(:,i) = zscore(swData((spipeaks(spiWithSWs(i))-1*100):(spipeaks(spiWithSWs(i))+1*100))');
end
swEpochsHilbert = hilbert(swEpochs);
spiEpochsHilbert = hilbert(spiEpochs);

swPhase = (angle(swEpochsHilbert)); % Instantaneous SW Phase;
for i = 1:length(spiWithSWs)
    
    swPhaseSpiPeak(i) = swPhase(101,i);
    
end

fig=figure;
subplot(9,3,[1 4 7]);
histogram(([swEvents.period])./100,'FaceColor', 'red');
hold;
histogram(([swEvents(swWithSpi).period])./100,'FaceColor','blue');
%legend({'All slow waves' 'Spi-coupled slow waves'});
xlabel('SW Period (s)');
ylabel('slow wave count');
subplot(9,3,[2 5 8]);
histogram(([swEvents.negPeakAmp]),'FaceColor', 'red');
hold;
histogram(([swEvents(swWithSpi).negPeakAmp]),'FaceColor','blue');
xlabel('SW Neg Peak Amp (uV)');
subplot(9,3,[3 6 9]);
histogram(([swEvents.p2pAmp]),'FaceColor', 'red');
hold;
histogram(([swEvents(swWithSpi).p2pAmp]),'FaceColor','blue');
legend({'All slow waves' 'Spi-coupled slow waves'});
xlabel('SW Peak-to-Peak Amp (uV)');

subplot(9,3,[10 13 16]);
histogram(([spiEvents.duration]./100),'FaceColor', 'red');
hold;
histogram(([spiEvents(spiWithSWs).duration]./100),'FaceColor','blue');
xlabel('Duration (s)')
ylabel('spindle count');

subplot(9,3,[11 14 17]);
histogram([spiEvents.maxamp],'FaceColor', 'red');
hold;
histogram([spiEvents(spiWithSWs).maxamp],'FaceColor','blue');
xlabel('Maximal spindle Amp (abs uV)')

subplot(9,3,[12 15 18]);
histogram([spiEvents.spifrq],'FaceColor', 'red');
hold;histogram([spiEvents(spiWithSWs).spifrq],'FaceColor','blue');
legend({'All spindles' 'SW-coupled spindles'});
xlabel('Spindle frequency (Hz)')
%ylabel('spindle count');


subplot(9,3,19)
plot([-1:1/100:1],mean(spiEpochs,2));
hold;
xlim([-1 1]);
ylim([-.5 .5]);
plot([-1:1/100:1],abs(hilbert(mean(spiEpochs,2))));
ylabel('spindle amp (z)');
line([-1 1], [0 0],'color', 'black');

subplot(9,3,22)
plot([-1:1/100:1],mean(swEpochs,2))
xlim([-1 1]);ylim([-.5 .5]);
ylabel('slow wave amp (z)');
line([-1 1], [0 0],'color', 'black');

subplot(9,3,25)
plot([-1:1/100:1],rad2deg(angle(hilbert(mean(swEpochs,2)))));
xlim([-1 1]);ylim([-180 180]);
ylabel('slow wave phase (deg)');
line([-1 1], [0 0],'color', 'black');
xlabel('Time (s)')

subplot(9,3,[20 23 26]);
histogram(rad2deg(swPhaseSpiPeak),'FaceColor', 'blue');
xlabel('SW phase (deg)');
xlim([-180 180]);
ylabel('spindle count');

% subplot(9,3,[21 24 27]);
% if exist('circ_plot')==2
%     circ_plot(swPhaseSpiPeak,'hist',[],20,false, true,'linewidth',2,'color','r');
% else
%     polarhistogram(swPhaseSpiPeak, 20, 'FaceColor', 'blue');
% end
fig.Name=['Slow Wave + Spindle Coupling: ', swEvent, '& ', spiEvent];
out = fig;
end


%% Functions
function out = bandpass_filter_massimimi(in,Fs)

Wp=[.5 4]/(Fs/2);
Ws=[.1 10]/(Fs/2);
Rp=3;
Rs=40;
[n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bbp, abp]=cheby2(n,Rs,Wn);
out=filtfilt_hume(bbp, abp, in);
%         out = decimate(out, floor(Fs/100));
end


%% Functions
function out = bandpass_filter_ferrarelli(in,Fs)
% BANDPASS_FILTER_FERRARELLI Bandpass filter used by Ferrarelli et al.
% This function creates a 12th order (if the sampling frequency is 100 Hz)
% Chebyshev Type II bandpass filter with passband between 10 and 16 Hz. The
% filter is -3 dB at 10.7 and 15 Hz.
% The input signal is filtered with the created filter and the filtered
% signal is returned as output.
Wp=[11 15]/(Fs/2);
Ws=[10 16]/(Fs/2);
Rp=3;
Rs=40;
[n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bbp, abp]=cheby2(n,Rs,Wn);
out=filtfilt_hume(bbp, abp, in);
end
