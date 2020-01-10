function brainstorm_result_extract_scouts(protocol_name, result_file,downsample_atlasname, scoutfunc_str, scouts_name, tag, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    scouts_label            = '';
    for x=1:length(scouts_name)
        scouts_label = [scouts_label '_' scouts_name{x}];
    end
        
    isflip                  = 1;
    isnorm                  = 1;
    scoutfunc               = 1;
    
%     if isfielf(project.brainstorm.postprocess,'scoutfunc_str')
%         scoutfunc_str = project.brainstorm.postprocess.scoutfunc_str;
%     else
%         scoutfunc_str = 'mean';
%     end
    
    disp(['Using function', scoutfunc_str, 'to aggregate scouts']);
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'isflip'
                isflip = varargin{opt+1}; 
            case 'isnorm'
                isnorm = varargin{opt+1};
            case 'scoutfunc'
                scoutfunc_str = varargin{opt+1};                
                
        end
    end
    
    
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
    
    % define optional parameters, accepted varargin parameters are:
    % Input files
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Scouts time series
    sFiles = bst_process('CallProcess', 'process_extract_scout', FileNamesA, [], ...
        'timewindow', [],...time_limits, ...
        'scouts', {downsample_atlasname, scouts_name}, ...
        'scoutfunc', scoutfunc, ...  % Mean, Max, PCA, Std, All
        'isflip', isflip, ...
        'isnorm', isnorm, ...
        'concatenate', 1, ...
        'save', 1, ...
        'addrowcomment', 1, ...
        'addfilecomment', 1,...
        'Comment',[tag,' | scout ', downsample_atlasname]);

    % Save report
    ReportFile      = bst_report('Save', sFiles);
    if isempty(sFiles)
        bst_report('Open', ReportFile);        
        rep = load(ReportFile);
        rep.Reports{3,4}
       keyboard 
    end     
    
    output_file_name=sFiles(1).FileName;
    
    [idir,iname,iext]   = fileparts(result_file);
    [odir,oname,oext]   = fileparts(output_file_name);
    
    iname               = strrep(iname, 'results_', '');
    
    src                 = fullfile(brainstorm_data_path, output_file_name);
%     dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname '_scouts' downsample_atlasname '_' num2str(time_limits(1)*1000) '_' num2str(time_limits(2)*1000) oext]);
% dest                = fullfile(brainstorm_data_path, odir, ['matrix_test.mat']);
    dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname '_scouts' downsample_atlasname  oext]);


movefile(src,dest);
    
    db_reload_studies(sFiles(1).iStudy);
end


% time_limits in seconds
% function brainstorm_result_extract_scouts(protocol_name, result_file,downsample_atlasname, scouts_name, time_limits, tag, varargin)
% 
%     iProtocol               = brainstorm_protocol_open(protocol_name);
%     protocol                = bst_get('ProtocolInfo');
%     brainstorm_data_path    = protocol.STUDIES;
%     
%     scouts_label            = '';
%     for x=1:length(scouts_name)
%         scouts_label = [scouts_label '_' scouts_name{x}];
%     end
%         
%     isflip                  = 1;
%     isnorm                  = 1;
%     scoutfunc               = 1;
%     
%     options_num=size(varargin,2);
%     for opt=1:2:options_num
%         switch varargin{opt}
%             case 'isflip'
%                 isflip = varargin{opt+1}; 
%             case 'isnorm'
%                 isnorm = varargin{opt+1};
%             case 'scoutfunc'
%                 scoutfunc_str = varargin{opt+1};                
%                 switch scoutfunc_str
%                     case 'mean'
%                         scoutfunc = 1;
%                     case 'max'
%                         scoutfunc = 2;
%                     case 'pca'
%                         scoutfunc = 3;
%                     case 'std'
%                         scoutfunc = 4;
%                     case 'all'
%                         scoutfunc = 5;
%                 end 
%         end
%     end
%     
%     
%     % define optional parameters, accepted varargin parameters are:
%     % Input files
%     FileNamesA = {result_file};
% 
%     % Start a new report
%     bst_report('Start', FileNamesA);
% 
%     % Process: Scouts time series
%     sFiles = bst_process('CallProcess', 'process_extract_scout', FileNamesA, [], ...
%         'timewindow', [],...time_limits, ...
%         'scouts', {downsample_atlasname, scouts_name}, ...
%         'scoutfunc', scoutfunc, ...  % Mean, Max, PCA, Std, All
%         'isflip', isflip, ...
%         'isnorm', isnorm, ...
%         'concatenate', 1, ...
%         'save', 1, ...
%         'addrowcomment', 1, ...
%         'addfilecomment', 1,...
%         'Comment',[tag,' | ', downsample_atlasname]);
% 
%     % Save report
%     ReportFile      = bst_report('Save', sFiles);
%     if isempty(sFiles)
%         bst_report('Open', ReportFile);        
%         rep = load(ReportFile);
%         rep.Reports{3,4}
%        keyboard 
%     end     
%     
%     output_file_name=sFiles(1).FileName;
%     
%     [idir,iname,iext]   = fileparts(result_file);
%     [odir,oname,oext]   = fileparts(output_file_name);
%     
%     iname               = strrep(iname, 'results_', '');
%     
%     src                 = fullfile(brainstorm_data_path, output_file_name);
% %     dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname '_scouts' downsample_atlasname '_' num2str(time_limits(1)*1000) '_' num2str(time_limits(2)*1000) oext]);
% % dest                = fullfile(brainstorm_data_path, odir, ['matrix_test.mat']);
%     dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname '_scouts' downsample_atlasname  oext]);
% 
% 
% movefile(src,dest);
%     
%     db_reload_studies(sFiles(1).iStudy);
% end