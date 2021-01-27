%% function brainstorm_result_uncontrained2flat(protocol_name, result_file, varargin)
% convert an uncontranstrained 3 dimensional vector in a single scalar
% method - 1: Norm = sqrt(x^2+y^2+z^2)
%        - 2: PCA
function brainstorm_subject_scout_tf(protocol_name, result_file, tag,...
    downsample_atlasname, scouts_name, scoutfunc_str,...
    comment, Freqs, MorletFc, MorletFwhmTc, ClusterFuncTime, Measure, Output, normalize,...
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


% Process: Time-frequency (Morlet wavelets)
FileNamesA = bst_process('CallProcess', 'process_timefreq', FileNamesA, [], ...
    'clusters', {downsample_atlasname, scouts_name},... {'Desikan-Killiany', {'bankssts L', 'bankssts R', 'caudalanteriorcingulate L', 'caudalanteriorcingulate R', 'caudalmiddlefrontal L', 'caudalmiddlefrontal R', 'cuneus L', 'cuneus R', 'entorhinal L', 'entorhinal R', 'frontalpole L', 'frontalpole R', 'fusiform L', 'fusiform R', 'inferiorparietal L', 'inferiorparietal R', 'inferiortemporal L', 'inferiortemporal R', 'insula L', 'insula R', 'isthmuscingulate L', 'isthmuscingulate R', 'lateraloccipital L', 'lateraloccipital R', 'lateralorbitofrontal L', 'lateralorbitofrontal R', 'lingual L', 'lingual R', 'medialorbitofrontal L', 'medialorbitofrontal R', 'middletemporal L', 'middletemporal R', 'paracentral L', 'paracentral R', 'parahippocampal L', 'parahippocampal R', 'parsopercularis L', 'parsopercularis R', 'parsorbitalis L', 'parsorbitalis R', 'parstriangularis L', 'parstriangularis R', 'pericalcarine L', 'pericalcarine R', 'postcentral L', 'postcentral R', 'posteriorcingulate L', 'posteriorcingulate R', 'precentral L', 'precentral R', 'precuneus L', 'precuneus R', 'rostralanteriorcingulate L', 'rostralanteriorcingulate R', 'rostralmiddlefrontal L', 'rostralmiddlefrontal R', 'superiorfrontal L', 'superiorfrontal R', 'superiorparietal L', 'superiorparietal R', 'superiortemporal L', 'superiortemporal R', 'supramarginal L', 'supramarginal R', 'temporalpole L', 'temporalpole R', 'transversetemporal L', 'transversetemporal R'}}, ...
    'scoutfunc', scoutfunc, ...  % 1 = Mean
    'edit',      struct(...
    'Comment',        [tag, ' | ', downsample_atlasname,',' ,comment],...'Scouts,Power,1-32Hz',...[ tag, ' | ', comment], ...
    'TimeBands',       [], ...
    'Freqs',           Freqs, ...
    'MorletFc',        MorletFc, ...
    'MorletFwhmTc',    MorletFwhmTc, ...
    'ClusterFuncTime', ClusterFuncTime,...'after', ...
    'Measure',         Measure, ...
    'Output',          Output, ...    
    'SaveKernel',      0), ...
    'normalize', normalize);  % None: Save non-standardized time-frequency maps




brainstorm_utility_check_process_success(FileNamesA);

output_file_name    = FileNamesA(1).FileName;
[odir,oname, oext]  = fileparts(output_file_name);
[idir,iname, iext]  = fileparts(result_file);

src                 = fullfile(brainstorm_data_path, output_file_name);
% dest                = fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' iname  iext]);
% dest                = fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' 'pippo'  iext]);
% dest                = fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' downsample_atlasname  iext]);

[str1, str2] = strtok(iname,'_');
dest                = fullfile(brainstorm_data_path, odir, ['timefreq_morlet' str2, '_', downsample_atlasname   iext]);


movefile(src,dest);

db_reload_studies(FileNamesA(1).iStudy);
end