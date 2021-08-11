function [EEG] = eeglab_subject_interpolate_segments(input_file_name,list_trigger_artifact,cutlimits,window_smooth,...
    method_smooth,n_smooth)


[file_path, name_noext, ext] = fileparts(input_file_name);
% EEG = pop_loadset(input_file_name);

try
    EEG                     = pop_loadset(input_file_name);
catch
    [fpath,fname,fext] = fileparts(input_file_name);
    EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
end


EEG = pop_saveset( EEG, 'filename',[name_noext,'_nointerp_segments', ext],'filepath',EEG.filepath);


all_triggers_type = {EEG.event.type};
sel_triggers2interpolate = ismember(all_triggers_type,list_trigger_artifact);
all_triggers_lat = [EEG.event.latency];

lat_triggers2interpolate = all_triggers_lat(sel_triggers2interpolate);

% convert the begin of the segment to be interpolated from ms to point
samples1=round((EEG.srate*cutlimits(1))/1000);
% convert the begin of the segment to be interpolated from ms to point
samples2=round(EEG.srate*cutlimits(2)/1000);
% create a set of points from the begin to the end of the segment to be
% interpolated
samplescut=samples1:1:samples2;

% create a set of points from the begin of the segment to be interpolated,
% going back in time for the length of the segments to be interpolated
samplescopy=samples1-1:-1:samples1-length(samplescut);

trialscut=repmat(lat_triggers2interpolate',1,size(samplescut,2))+repmat(samplescut,size(lat_triggers2interpolate,2),1);
trialscopy=repmat(lat_triggers2interpolate',1,size(samplescut,2))+repmat(samplescopy,size(lat_triggers2interpolate,2),1);
datatmp=EEG.data;
datatmp(:,trialscut)=datatmp(:,trialscopy);%è diverso per tutti gli elettrodi?si


samples11=round((EEG.srate*window_smooth(1))/1000);
samples22=round(EEG.srate*window_smooth(2)/1000);
samplessmooth=samples11:1:samples22;
% borda1;
samplessmooth1=samples11:1:samples22+samples1;
% borda2;
samplessmooth2=samples11:1:samples22+samples2;
trialssmooth1=repmat(lat_triggers2interpolate',1,size(samplessmooth1,2))+repmat(samplessmooth1,size(lat_triggers2interpolate,2),1);
trialssmooth2=repmat(lat_triggers2interpolate',1,size(samplessmooth2,2))+repmat(samplessmooth2,size(lat_triggers2interpolate,2),1);

h=waitbar(0,'Smoothing Data...');
for i=1:1:size(datatmp,1)
    for j=1:1:size(trialssmooth1,1)
        datatmp(i,trialssmooth2(j,:))=smooth(datatmp(i,trialssmooth2(j,:)),n_smooth,method_smooth);
    end
    waitbar(i/size(datatmp,1),h)
end
delete(h)
EEG.data = datatmp;
EEG = pop_saveset( EEG, 'filename',[name_noext ,ext],'filepath',EEG.filepath);

clear i j h cutlimits method_smooth n_smooth samples1 samples11 samples2 samples22...
    samplescopy samplescut samplessmooth samplessmooth1 samplessmooth2...
    window_smooth trialscopy trialscut trialssmooth1 trialssmooth2 lat_triggers2interpolate


% if not(isempty(segm2remove_sec))
%     [file_path, name_noext, ext] = fileparts(input_file_name);
%     EEG = pop_loadset(input_file_name);
%     segm2remove_pts = segm2remove_sec*EEG.srate;
%     EEG = eeg_eegrej( EEG,   segm2remove_pts);
%     EEG = pop_saveset( EEG, 'filename',[name_noext, ext],'filepath',EEG.filepath);
% end
end
%===========================================================================================================================
% 04/06/2015
% corrected reference management, exclude reference channels from ICA
