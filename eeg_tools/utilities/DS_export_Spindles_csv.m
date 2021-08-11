function DS_export_Spindles_csv(EEG,PARAM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Export spindle events to CSV file
%
% Part of detect_spindles toolbox:
%
% Authors:  Stephane Sockeel, PhD, University of Montreal
%           Stuart Fogel, PhD, University Ottawa
%           Thanks to support from Julien Doyon and input from Arnaud Bore.
%           Copyright (C) Stuart fogel & Stephane Sockeel, 2016
%           See the GNU General Public License for more details.
%
% Contact:  sfogel@uottawa.ca
%
% Date:     June 8, 2016
%
% Citation: Ray, L.B., Sockeel, S., Soon, M., Bore, A., Myhr, A.,
%           Stojanoski, B., Cusack, R., Owen, A.M., Doyon, J., Fogel, S.,
%           2015. Expert and crowd-sourced validation of an individualized
%           sleep spindle detection method employing complex demodulation
%           and individualized normalization. Front. Hum. Neurosci. 9.
%           doi:10.3389/fnhum.2015.00507
%
%           journal.frontiersin.org/article/10.3389/fnhum.2015.00507/full
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mrk = EEG.event;
nbMrk = length(Mrk);
ChannelName = {EEG.chanlocs.labels};

for i = 1:nbMrk
    Mrk(i).latency = Mrk(i).latency/EEG.srate; % convert to seconds
    Mrk(i).duration = Mrk(i).duration/EEG.srate; % convert to seconds
    if isfield(Mrk,'peak')
        Mrk(i).peak = Mrk(i).peak/EEG.srate; % convert to seconds
    end
    if isfield(Mrk,'channel')
        if Mrk(i).channel == 0 % some file importers indicate no channel as [0] instead of []
            Mrk(i).channel = [];
        elseif isnan(Mrk(i).channel) % some file importers indicate no channel as NaN instead of []
            Mrk(i).channel = [];
        elseif isempty(Mrk(i).channel) % some events have empty channels '' instead of []
            Mrk(i).channel = [];
        else
            Mrk(i).channel = ChannelName{Mrk(i).channel};
        end
    else
        Mrk(i).channel = 'none';
    end
end

NameFields = fieldnames(Mrk);
nbFields = length(NameFields);
%cc
FileName = fullfile(EEG.filepath, [EEG.setname, '.csv']);
fid = fopen(FileName,'w');

towrite = '';
for i = 1:nbFields
    towrite  = [towrite NameFields{i} ','];
end

towrite(end) = []; % last ',' out

fprintf(fid,'%s\n',towrite);

for iMrk = 1:nbMrk
    towrite = '';
    if strcmpi(Mrk(iMrk).type,PARAM.eventName)
        for i = 1:nbFields
            towrite  = [towrite instring(Mrk(iMrk).(NameFields{i})) ','];
        end
        towrite(end) = []; % last ',' out
        fprintf(fid,'%s\n',towrite);
    end
end

fclose(fid);

end

function stra = instring(a)

if ~ischar(a)
    stra = num2str(a);
else
    stra =a;
end

end
