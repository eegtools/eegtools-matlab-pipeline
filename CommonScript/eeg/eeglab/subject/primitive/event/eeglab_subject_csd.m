function EEG = eeglab_subject_csd(EEG)

	nch_eeg=EEG.chanlocs

    for site = 1:nch_eeg 
        trodes{site}=(EEG.chanlocs(site).labels);
    end;
    trodes=trodes';


    %% Get Montage for use with CSD Toolbox
    Montage_64=ExtractMontage('10-5-System_Mastoids_EGI129.csd',trodes);
    MapMontage(Montage_64);

    %% Derive G and H!
    [G,H] = GetGH(Montage_64);    

    for ne = 1:length(EEG.epoch)               % loop through all epochs
        myEEG = single(EEG.data(:,:,ne));      % reduce data precision to reduce memory demand
        MyResults = CSD(myEEG,G,H);            % compute CSD for <channels-by-samples> 2-D epoch
        data(:,:,ne) = MyResults;              % assign data output
    end
    EEG.data = double(data);          % final CSD data

end

    
