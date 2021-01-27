%% function brainstorm_subject_scout_fc_cohere1n(protocol_name, result_file, tag,...
function brainstorm_subject_scout_fc_cohere1n(protocol_name, result_file, tag,...
    downsample_atlasname, scouts_name, scoutfunc_str, scouttime, removeevoked,...
    cohmeasure,maxfreq, ...
    ...maxfreqres, ... lasciamo stimare a lui
    outputmode, ...
    tw_list,...
    ...comment,...
    varargin)


iProtocol               = brainstorm_protocol_open(protocol_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

%     method                  = 1;


disp(['Using function ', scoutfunc_str, ' to aggregate scouts']);


switch scoutfunc_str
    case 'mean'
        scoutfunc = 1;
    case 'max'
        scoutfunc = 2;
    case 'pca'
        scoutfunc = 3;
    case 'std'
        scoutfunc = 4;
    case 'all'
        scoutfunc = 5;
end


%     options_num=size(varargin,2);
%     for opt=1:2:options_num
%         switch varargin{opt}
%             case 'method'
%                 method  = varargin{opt+1};
%         end
%     end


% define optional parameters, accepted varargin parameters are:
% Input files
FileNamesA = {result_file};

% Start a new report
bst_report('Start', FileNamesA);

for ntw = 1:length(tw_list)
    
    tw = [tw_list(ntw).min, tw_list(ntw).max];
    
    tw_sec = tw/1000;
    % https://electronics.stackexchange.com/questions/12407/what-is-the-relation-between-fft-length-and-frequency-resolution
    maxfreqres = round(2/(tw_sec(2)-tw_sec(1)));
    
    % Process: Coherence NxN
    FileNamesA = bst_process('CallProcess', 'process_cohere1n', FileNamesA, [], ...
        'timewindow',   tw_sec, ...
        'scouts',       {downsample_atlasname, scouts_name}, ...
        'scoutfunc',    scoutfunc, ...  % 1 =   Mean
        'scouttime',    scouttime, ...  % 2 = After
        'removeevoked', removeevoked, ... % 0 = no
        'cohmeasure',   cohmeasure, ...  % 1 = Magnitude-squared
        'maxfreq',      maxfreq, ...
        'maxfreqres',   maxfreqres, ...16,...
        'outputmode',   outputmode...,... 1 = % Save individual results (one file per input file)
        ...'Comment', [tag]... non prende commenti
        );
    
    brainstorm_utility_check_process_success(FileNamesA);
    
    output_file_name    = FileNamesA(1).FileName;
    [odir,oname, oext]  = fileparts(output_file_name);
    [idir,iname, iext]  = fileparts(result_file);
    
    src                 = fullfile(brainstorm_data_path, output_file_name);
    
    [str1, str2] = strtok(iname,'_');
    tw_str = [' [',num2str(tw(1)),'_', num2str(tw(2)), ']'];
    dest                = fullfile(brainstorm_data_path, odir, ['timefreq_connectn_cohere' str2, '_', downsample_atlasname, tw_str,  iext]);
    
    
    movefile(src,dest);
    
    m = matfile(dest,'Writable',true);
    m.Comment = [tag, ' | ',downsample_atlasname, ' | ', m.Comment, ' | ', tw_str];
    
    
    db_reload_studies(FileNamesA(1).iStudy);
end
end