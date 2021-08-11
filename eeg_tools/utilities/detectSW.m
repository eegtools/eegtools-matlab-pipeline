function [output perEventData] = detectSW(stageData, EEG, ch)
%% Slow Wave 

perEventData = [];
% select channel
EEG = pop_select(EEG, 'channel', find(strcmp(ch, {EEG.chanlocs.labels})));

% resample to 100 Hz
EEG = pop_resample(EEG, 100);

spa = EEG.data';

% set up stages
stages = stageData.stages;

% 
% Remove stages that have artifacts marked
if isfield(stageData,'MarkedEvents')
artifacts = cell2mat(stageData.MarkedEvents(strcmp('[0]', stageData.MarkedEvents(:,1)), 3));
stages(artifacts)=7; % don't base data on artifacts.
end



[SW] = massimimi_sw_detection(spa, EEG.srate, stages, stageData.win);

if length(SW)>0
   output = [repmat({ch}, length(SW), 1) num2cell([SW.WaveStart]./EEG.srate)' num2cell([SW.WaveEnd]./EEG.srate)' num2cell(ceil([SW.WaveStart]./EEG.srate/stageData.win))' repmat({['Slow Wave (Riedner/Massimini)', ch,')']}, length(SW), 1) num2cell(ones(length(SW),1))];
   for i = 1:length(SW)
       output{i,7} = SW(i);
   end
else
   output = {};
 
end

end

%     if nspi>0
%         output = [repmat({ch}, nspi, 1) num2cell(spistart') num2cell(spiend') num2cell(ceil(spistart'./EEG.srate/30)) repmat({['Sleep Spindle (detected ', ch,')']}, nspi, 1)];
%     else
%         output = {};
%     end

function [SWMat] = massimimi_sw_detection(Cz,fs,stages, win)

%% Bandpass filter from 11-15 Hz and rectify filtered signal
 BandFilteredData = bandpass_filter_massimimi(Cz,fs);
 data = BandFilteredData;
 pos_index=zeros(length(BandFilteredData),1);
    pos_index(find(data>0))=1; %index of all positive points for EEG
    difference=diff(pos_index); poscross=find(difference==1) ; negcross=find(difference==-1); %find neg ZX and pos ZX
    EEGder=diff(data); %derivative to find peaks / depending on the filtering you may need to smooth with a moving average
    pos_index=zeros(length(EEGder),1);
    pos_index(find(EEGder>0.1))=1; %index of all positive points above minimum threshold
    difference=diff(pos_index);
    peaks=find(difference==-1)+1; troughs=find(difference==1)+1; %find pos ZX and neg ZX of the derivative (the peaks & troughs)
    peaks(data(peaks)<0)=[];troughs(data(troughs)>0)=[]; % rejects peaks below zero and troughs above zero
    if negcross(1)<poscross(1);start=1;else start=2;end %makes negcross and poscross same size to start
    if start==2;poscross(1)=[];end
    lastpk=NaN; %way to look at Peak to Peak parameters if needed
    endx = length(negcross)-1;
for wndx=start:endx
        wavest=negcross(wndx); %only used for neg/pos peaks
        wavend=negcross(wndx+1); %only used for neg/pos peaks
        mxdn=abs(min(diff(data(wavest:poscross(wndx)))))*fs; % matrix (27) determines instantaneous 1st segement slope / depending on the filtering you may need to smooth with a moving average
        mxup=max(diff(data(wavest:poscross(wndx))))*fs; % matrix (28) determines for 2nd segement /  depending on the filtering you may need to smooth with a moving average
        negpeaks=troughs(troughs>wavest&troughs<wavend);
        if isempty(negpeaks);negpeaks=wavest; end %if pospeaks is empty set pospeak to pos ZX
        wavepk=negpeaks(data(negpeaks)==min(data(negpeaks)));
        waveep=ceil(wavepk/(fs*30));  %used w/ sleep for matrix(3)
        pospeaks=peaks(peaks>wavest&peaks<=wavend);
        if isempty(pospeaks);pospeaks=wavend; end %if pospeaks is empty set pospeak to pos ZX
        wavest=wavest; %matrix(7)
        wavend=wavend; %matrix(8)
        period=(wavend-wavest)/fs; %matrix(11) /Fs
        poszx=poscross(wndx); %matrix(10)
        b=min(data(negpeaks)); % matrix (12) most neg peak /abs for matrix
        bx=negpeaks(data(negpeaks)==b); %matrix (13) max neg peak location in entire night
        c=max(data(pospeaks)); % matrix (14) most pos peak
        cx=pospeaks(data(pospeaks)==c); %matrix (15) max pos peak location in entire night
        maxb2c=c-b; % %matrix (16) max peak to peak amp
        nump=length(negpeaks); %matrix(24)
        n1=abs(data(negpeaks(1))); %matrix(17) 1st neg peak amp
        n1x=negpeaks(1); %matrix(18) 1st neg peak location
        nEnd=abs(data(negpeaks(end))); %matrix(19) last neg peak amp
        nEndx=negpeaks(end);%matrix(20) last neg peak location
        p1=data(pospeaks(1)); %matrix(21) 1st pos peak amp
        p1x=pospeaks(1); %matrix(22) 1st pos peak location
        meanNegAmp=abs(mean(data(negpeaks))); %matrix(23)
        meanPosAmp=abs(mean(data(pospeaks)));
        nperiod=(poszx-wavest); %matrix (25)neghalfwave period
        mdpt=wavest+ceil(nperiod/2); %matrix(9)
        epoch=ceil(bx/(fs*win)); %matrix(1)
        %        smepoch=ceil(bx/(Fs*withinsize)); %matrix(2)
        p2p=(cx-lastpk)/fs; %matrix(26) 1st peak to last peak period
        lastpk=cx;
        
        SW.epoch = epoch ;
        if max(epoch) > length(stages)
            sel_epoch = epoch <= length(stages);
            epoch = epoch(sel_epoch);
%             SWMat = [];
%             return
        end
            
        SW.stage = stages(epoch);
%         SW.stage = reject_stage(epoch, 1);
%         SW.cycle = nremp(epoch);
%         SW.hour = houreps(epoch);
%         SW.quarter = quartereps(epoch);
%         SW.third = thirdeps(epoch);
%         SW.half = halfeps(epoch);
        SW.WaveStart = wavest;
        SW.WaveEnd = wavend;
        SW.p2pAmp = maxb2c;
        SW.negPeakAmp = b;
        SW.negPeakX = bx;
        SW.posPeakAmp = c;
        SW.posPeakX = cx;
        SW.period = nperiod;
        SW.downSlope = mxdn;
        SW.upSlope = mxup;
        SW.fs = fs;
        SWMat(wndx) = SW;
        
end

% select only SW with half-period .25s - 1 s
SWMat([SWMat.period]./fs < .25) = [];
SWMat([SWMat.period]./fs > 1) = [];
SWMat([SWMat.negPeakAmp] >= -80) = [];
SWMat([SWMat.p2pAmp] < 140) = [];
SWMat([SWMat.stage] < 2) = [];
SWMat([SWMat.stage] > 4) = [];

%% Functions
    function out = bandpass_filter_massimimi(in,Fs)
   
        Wp=[.5 4]/(Fs/2);
        Ws=[.1 10]/(Fs/2);
        Rp=3;
        Rs=40;
        [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
        [bbp, abp]=cheby2(n,Rs,Wn);
        out=filtfilt_fast_hume(bbp, abp, in);
%         out = decimate(out, floor(Fs/100));
    end

end
