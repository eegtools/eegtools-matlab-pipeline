% Protocol name has to be a valid folder name (no spaces, no weird characters...)

function status = proj_brainstorm_convert_montage_eeglab2brainstorm(project) ... ProtocolName,folder_path,default_anatomy)
    
[path, name, ext] = fileparts(project.brainstorm.channels_file_path);

name2 = 'brainstorm_channel_EEGLAB_64_10-10';

file_chan_eeglab = fullfile(path, [name2,ext]);

% file_chan_eeglab = project.eegdata.eeglab_channels_file_path;
% locs_eeglab      = pop_readlocs(file_chan_eeglab);
load(file_chan_eeglab);

file_chan_brainstorm = 'channel_BioSemi_64_10-10.mat';

switch project.brainstorm.default_anatomy
    case {'ICBM152', 'ICBM152_2016c'}
        anatomy = 'ICBM152';
    case 'Colin27_2016'
        anatomy = 'Colin27';
end


path_chan_brainstorm = fullfile(project.paths.brainstorm,'defaults','eeg',anatomy ,file_chan_brainstorm);
load(path_chan_brainstorm);

content_chan_brainstorm = {'Channel',    'Comment',    'HeadPoints',    'History',...
    'MegRefCoef',    'Projector',    'SCS',    'TransfEeg',...
    'TransfEegLabels',    'TransfMeg',    'TransfMegLabels'};

locs_brainstorm = Channel;

file_chan = project.brainstorm.channels_file_path;

% EEG=pop_chanedit(EEG, 'save',file_chan);




sel_Afz = ismember({Channel.Name},'Afz');
Channel(sel_Afz).Name  = 'AFz';

chan_lab_brainstorm = {Channel.Name};
chan_lab_eeglab     = {locs_eeglab.labels};

chan_intersection = chan_lab_eeglab(ismember(chan_lab_eeglab,chan_lab_brainstorm));

[LIA,LOCB] = ismember(chan_intersection,chan_lab_brainstorm);

Channel_old = Channel;

Channel = Channel_old(LOCB);

save(project.brainstorm.channels_file_path,content_chan_brainstorm{:})

status = 1;

disp('Montage imported from eeglab to brainstorm')

end