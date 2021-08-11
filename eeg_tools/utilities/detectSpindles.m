function [output perEventData] = detectSpindles(stageData, EEG, ch)
%% FERRARELLI 2007 ALGORITHM AS IMPLEMENTED BY WARBY 2013


% select channel
EEG = pop_select(EEG, 'channel', find(strcmp(ch, {EEG.chanlocs.labels})));
EEG = pop_resample(EEG,100);
spa = EEG.data';

% set up stages
stages = stageData.stages;

perEventData = [];

% Spindles use a data-driven threshold; thus, we want to limit detection Stages 2,3, 4;
%do not detect spindles in WAKE, Stage 1, REM, MT or Artifacts (if marked)
if isfield(stageData,'MarkedEvents')
artifacts = cell2mat(stageData.MarkedEvents(strcmp('[0]', stageData.MarkedEvents(:,1)), 3));
stages(artifacts)=7; % don't base data on artifacts.
end


[detection spistart spiend perEvent] = ferrarelli_spindle_detection(spa, 100, stages, 2, 6, stageData.win);

if length(spistart)>0
   output = [repmat({ch}, length(spistart), 1) num2cell(spistart./100) num2cell(spiend./100) num2cell(ceil(spistart./100/stageData.win)) repmat({['Sleep Spindle (Ferrarelli/Warby ', ch,')']}, length(spistart), 1) num2cell(ones(length(spistart),1))];
   for i = 1:length(spistart)
       output{i,7} = perEvent(i);
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

function [detection spistart spiend perEvent] = ferrarelli_spindle_detection(C3,fs,stages, lThr, hThr, win)
% FERRARELLI Detect sleep spindles using the Ferrarelli algorithm.
% Ferrarelli et al. "Reduced Sleep Spindle Activity in Schizophrenia
% Patients", Am J Psychiatry 164, 2007, pp 483-492
%
% Input is recorded EEG for a whole night of sleep (any channel can be
% used), the sampling frequency, a stage file (STA) that has been loaded in
% to MATLAB.
% Output is a binary vector containing ones at spindle samples.
% Syntax: detection = ferrarelli_spindle_detection(C3,fs,stage_file)
%
% Adopted from Ferrarelli by Sabrina Lyngbye Wendt, July 2013

%% Initialize and load data
sleep = stages;
lower_thresh_ratio = lThr;
upper_thresh_ratio = hThr;
epochsize = win;

%% Redefine sleep stage numbers and get the nrem samples
sleep(sleep==1)=-1;sleep(sleep==2)=-2;sleep(sleep==3)=-3;sleep(sleep==4)=-4;
sleepsamp = reshape(repmat(sleep,1,epochsize*fs)',1,length(sleep)*epochsize*fs)';
nremsamples = find(sleepsamp<=-2); % Use data from stage S2+S3+S4

%% Bandpass filter from 11-15 Hz and rectify filtered signal
BandFilteredData = bandpass_filter_ferrarelli(C3,fs);
RectifiedData = abs(BandFilteredData);

%% Create envelope from the peaks of rectified signal (peaks found using zero-crossing of the derivative)
datader = diff(RectifiedData); % x(2)-x(1), x(3)-x(2), ... + at increase, - at decrease
posder = zeros(length(datader),1);
posder(datader>0) = 1; % index of all points at which the rectified signal is increasing in amplitude
diffder = diff(posder); % -1 going from increase to decrease, 1 going from decrease to increase, 0 no change
envelope_samples = find(diffder==-1)+1; % peak index of rectified signal
Envelope = RectifiedData(envelope_samples); % peak amplitude of rectified signal

%
% Finds peaks of the envelope
datader = diff(Envelope);
posder = zeros(length(datader),1);
posder(datader>0) = 1; % index of all points at which the rectified signal is increasing in amplitude
diffder = diff(posder);
envelope_peaks = envelope_samples(find(diffder==-1)+1); % peak index of Envelope signal
envelope_peaks_amp = RectifiedData(envelope_peaks); % peak amplitude of Envelope signal

%% Finds troughs of the envelope
envelope_troughs = envelope_samples(find(diffder==1)+1); % trough index of Envelope signal
envelope_troughs_amp = RectifiedData(envelope_troughs); % peak trough of Envelope signal

%% Determine upper and lower thresholds
if max(envelope_peaks) > length(sleepsamp)
    sel_peaks = envelope_peaks<=length(sleepsamp);
    envelope_peaks = envelope_peaks(sel_peaks);
% detection = [];
% spistart = [];
% spiend = [];
% perEvent = [];
% return
end

nrem_peaks_index=sleepsamp(envelope_peaks)<=-2; % extract samples that are in NREM stage S2+S3+S4
[counts amps] = hist(envelope_peaks_amp(nrem_peaks_index),120); % divide the distribution peaks of the Envelope signal in 120 bins
[~,maxi] = max(counts); % select the most numerous bin
ampdist_max = amps(maxi); % peak of the amplitude distribution
lower_threshold = lower_thresh_ratio*ampdist_max;
upper_threshold = upper_thresh_ratio*mean(RectifiedData(nremsamples));

%% Find where peaks are higher/lower than threshold
below_troughs = envelope_troughs(envelope_troughs_amp<lower_threshold); % lower threshold corresponding to 4* the power of the most numerous bin
envelope_peaks_amp=envelope_peaks_amp(1:length(envelope_peaks));
above_peaks=envelope_peaks(envelope_peaks_amp>upper_threshold & sleepsamp(envelope_peaks)<=-2); % Use this line insted of no. 60 if spindles should only be detected in S2+S3+S4
%above_peaks = envelope_peaks(envelope_peaks_amp>upper_threshold); %this to not detect spindles in stages other 2, 3, 4 

%% For each of peaks above threshold
spistart = NaN(length(above_peaks),1); % start of spindle (in 100Hz samples)
spiend = NaN(length(above_peaks),1); % end of spindle (in 100Hz samples)
spimaxi = NaN(length(above_peaks),1); % peak rectified signal
nspi=0; % spindle count
% for all indexes of peaks (peaks of peaks)
i = 1;
while i <= length(above_peaks)
    current_peak = above_peaks(i);
    % find troughs before and after current peak
    trough_before = below_troughs(find(below_troughs > 1 & below_troughs < current_peak,1,'last'));
    trough_after  = below_troughs(find(below_troughs < length(RectifiedData) & below_troughs > current_peak,1,'first'));
    
    if ~isempty(trough_before) && ~isempty(trough_after)  % only count spindle if it has a start and end
        nspi=nspi+1;
        spistart(nspi)=trough_before;
        spiend(nspi)=trough_after;
        % if there are multiple peaks, pick the highest and skip the rest
        potential_peaks = above_peaks(above_peaks > trough_before & above_peaks < trough_after);
        [~, maxpki]=max(RectifiedData(potential_peaks));
        current_peak=potential_peaks(maxpki); 
        spimaxi(i) = current_peak;
        i = i+length(potential_peaks); % adjust the index to account for different max
    else
        i = i+1;
    end
end

scoring = NaN(nspi,1);  % sleep state where end lies
for j=1:nspi
    scoring(j) = sleepsamp(spiend(j));
end

%% Create the binary output vector
detection = zeros(size(C3));
spistart = spistart(isnan(spistart)~=1);
spiend = spiend(isnan(spiend)~=1);
spimaxi =spimaxi(isnan(spimaxi)~=1);

duration = spiend-spistart;
spistart(duration<0.3*fs | duration>3*fs) = NaN;
spiend(duration<0.3*fs | duration>3*fs) = NaN;
spimaxi(duration<0.3*fs | duration>3*fs) = NaN;

duration = duration(isnan(spistart)~=1); % Trim duration for only final spindles JS Addition 071420
spistart = spistart(isnan(spistart)~=1);
spiend = spiend(isnan(spiend)~=1);
spimaxi = spimaxi(isnan(spimaxi)~=1);

perEvent = struct('sumamp',[], 'maxamp', [], 'spifrq', [], 'duration', [], 'spimaxi', [], 'fs', []);
for k = 1:length(spistart)
    detection(spistart(k):spiend(k)) = 1;
    perEvent(k).sumamp = sum(RectifiedData(spistart(k):spiend(k)));  % Summed amplitude of spindle JS Addition 071420
    
    % Calculate frequency of each spindle as #peaks+troughs / duration / 2
    % JS Addition 071420
    RectSpi = RectifiedData(spistart(k):spiend(k));
    datader = diff(RectSpi); % x(2)-x(1), x(3)-x(2), ... + at increase, - at decrease
    posder = zeros(length(datader),1);
    posder(datader>0) = 1; % index of all points at which the rectified signal is increasing in amplitude
    diffder = diff(posder); % -1 going from increase to decrease, 1 going from decrease to increase, 0 no change
    envelope_samples = find(diffder==-1)+1; % peak index of rectified signal
    Envelope = RectSpi(envelope_samples); % peak amplitude of rectified signal
    [perEvent(k).maxamp] = max(Envelope); % Max amplitude of spindle JS Addition 071420
    perEvent(k).spimaxi = spimaxi(k); % index of peak in overall signal
    perEvent(k).spifrq = length(Envelope) / (duration(k)/fs) / 2;
    perEvent(k).duration = duration(k);
    perEvent(k).fs = fs;
    perEvent(k).stage = sleepsamp(spistart(k));
    
  
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
        out=filtfilt_fast_hume(bbp, abp, in);
    end

end

% %% FERRARELLI 2007 ALGORITHM AS IMPLEMENTED BY WARBY 2013
% 
% %spa(reshape(time2rej,1,[]),:)=NaN;
% epo = length(spa(:,1));
% 
% %%%%envelope
%     x=abs(spa(:,recchannel))';  %RMS signal
%     p=0; pin=[]; ps=[];
%     for i=2:length(x)-1
%         if (x(i)>=x(i-1)) & (x(i)>=x(i+1))
%             if p>0
%                 if (i-1)>pin(p)
%                     p=p+1;
%                     pin(p)=i;
%                     ps(p)=x(i);
%                 elseif  x(i)>x(i-1)
%                     pin(p)=i;   % peak index where in the signal the peak is
%                     ps(p)=x(i); % peak size how big is the peak
%                 end;
%             else
%                 p=p+1;
%                 pin(p)=i;   % peak index
%                 ps(p)=x(i); % peak size
%             end
%         end
%     end
%     np=p; %new time series = envelope
%     
%     %%%%maximum
%     xx=ps;
%     p=0; pinx=[]; psx=[];here=[];here2=[];
%     for i=2:np-1
%         if (xx(i)>=xx(i-1)) & (xx(i)>=xx(i+1))
%             if p>0
%                 if (i-1)>pin(p)
%                     p=p+1;
%                     pinx(p)=i;
%                     psx(p)=xx(i);
%                 elseif  xx(i)>xx(i-1)
%                     pinx(p)=i;   % peak index
%                     psx(p)=xx(i); % peak size
%                 end;
%             else
%                 p=p+1;
%                 pinx(p)=i;   % peak index
%                 psx(p)=xx(i); % peak size
%             end
%         end
%     end
%     pinxndx=pin(pinx); %index of maximums of new time series
%     
%     [nx nn]=hist(psx,120); %120= divide the distribution of the index of maximums in 120 bins
%     
%     [nxmax,ndxnxmax]=max(nx); %select the most numerous bin(nx)
%     maxnn=nn(ndxnxmax); %determine the power in this bin (nn)
%     
%     %%%%minimum
%     p=0; pinxm=[]; psxm=[];
%     for i=2:np-1
%         if (xx(i)<=xx(i-1)) & (xx(i)<=xx(i+1))
%             if p>0
%                 if (i-1)>pin(p)
%                     p=p+1;
%                     pinxm(p)=i;
%                     psxm(p)=xx(i);
%                 elseif  xx(i)<xx(i-1)
%                     pinxm(p)=i;   % peak index
%                     psxm(p)=xx(i); % peak size
%                 end;
%             else
%                 p=p+1;
%                 pinxm(p)=i;   % peak index
%                 psxm(p)=xx(i); % peak size
%             end
%         end
%     end
%     pinxmndx=pin(pinxm); %index of minimum of new time series
%     
%     %%%%determine thresholds
%     ndxpsxm=find(psxm<2*maxnn);  %lower threshold corresponding at 2* the power of the most numerous bin
%     psxmthresh=psxm(ndxpsxm);
%     
%     ndxpsx=find(psx>8*nanmean(x));  %upper threshold, 8*average of RMS signal. It represents an index of all max. peaks above threshold
%     psxthresh=psx(ndxpsx);
%     
%     aspa=abs(spa);
%     
%     %%%%detect maxima with thresholds
%     spistart=[]; spistartGood=[]; spifastStart=[]; spislowStart=[];
%     spimax=[];
%     spimaxpow=[]; spimaxpowGood=[]; spimaxpowFast=[]; spimaxpowSlow=[];
%     spiend=[]; spiendGood=[]; spifastEnd=[]; spislowEnd=[];
%     
%     nspi=0;
%     
%     for i=1:length(ndxpsx)
%         if i==1  %if it is the first peak it doesn't have a mininum before. Therefore it is skipped becuase it is not possible to determine the spindle duration
%             ndxmaxbef=1:1:pinxndx(ndxpsx(i));
%         else
%             ndxmaxbef=pinxndx(ndxpsx(i-1)):1:pinxndx(ndxpsx(i));
%         end
%         ndxminbef=intersect(ndxmaxbef,pinxmndx(ndxpsxm));
%         
%         if i==length(ndxpsx)  %if it is the last peak it doesn't have a mininum after. Therefore it is skipped becuase it is not possible to determine the spindle duration
%             ndxmaxaft=pinxndx(ndxpsx(i)):1:length(aspa);
%         else
%             ndxmaxaft=pinxndx(ndxpsx(i)):1:pinxndx(ndxpsx(i+1));
%         end
%         ndxminaft=intersect(ndxmaxaft,pinxmndx(ndxpsxm));
%         
%         if length(ndxminbef)>0 & length(ndxminaft)>0   %single peak not at the beginning or the end of the session (in between the first and the last)
%             nspi=nspi+1;
%             spistart(nspi)=ndxminbef(end);
%             spimax(nspi)=pinxndx(ndxpsx(i));
%             spimaxpow(nspi)=aspa(pinxndx(ndxpsx(i)));
%             spiend(nspi)=ndxminaft(1);
%         elseif length(ndxminbef)>0 & isempty(ndxminaft)  %multiple peaks start but no end. There is a minumum before but not a minimum after a multi-peak spindle.
%             nspi=nspi+1;
%             spistart(nspi)=ndxminbef(end);
%             spimax(nspi)=pinxndx(ndxpsx(i));
%             spimaxpow(nspi)=aspa(pinxndx(ndxpsx(i)));
%         elseif isempty(ndxminbef) & length(ndxminaft)>0 & nspi>0  %multiple peaks end but no start.There is a minumum after but not a minimum before a multi-peak spindle.
%             if spimaxpow(nspi)<aspa(pinxndx(ndxpsx(i)))
%                 spimax(nspi)=pinxndx(ndxpsx(i));
%                 spimaxpow(nspi)=aspa(pinxndx(ndxpsx(i)));
%             end
%             spiend(nspi)=ndxminaft(1);
%         elseif nspi>0  %multiple peaks not at the beginning or the end of the session (in between the first and the last)
%             if spimaxpow(nspi)<aspa(pinxndx(ndxpsx(i)))
%                 spimax(nspi)=pinxndx(ndxpsx(i));
%                 spimaxpow(nspi)=aspa(pinxndx(ndxpsx(i)));
%             end
%         end
%     end
%     
%     if nspi>length(spiend)
%         nspi=nspi-1;
%         spistart=spistart(1:end-1);
%     end
%     
%     %%
%     if nspi>0
%         output = [repmat({ch}, nspi, 1) num2cell(spistart') num2cell(spiend') num2cell(ceil(spistart'./EEG.srate/30)) repmat({['Sleep Spindle (detected ', ch,')']}, nspi, 1)];
%     else
%         output = {};
%     end
% 