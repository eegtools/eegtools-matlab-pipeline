function brainstorm_process_stats_sources2(protocol_name, result_struct_file, StatThreshOptions)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    brainstorm_anat_path    = protocol.SUBJECTS;    
    
    % load default MRI file data structure for coordinate conversion
    sSubject                = bst_get('Subject', '@default_subject');
    mri_file                = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    sMri                    = load (fullfile(brainstorm_anat_path, mri_file));
    sMri.FileName           = mri_file;
    
 
    % load result data structure
    if (strcmp(result_struct_file(1),'@'))
        file_name           = fullfile(brainstorm_data_path, result_struct_file);
    else
        file_name           = result_struct_file;        
    end
    res = load(file_name);
    
    % load SurfaceFile data structures for vertex coordinates
    surf                    = load (fullfile(brainstorm_anat_path, res.SurfaceFile));
        
    
    pmap                    = process_extract_pthresh('GetPmap', res.tmap, res.df);
    [pmask, corr_p]         = bst_stat_thresh(pmap, StatThreshOptions);
    
    threshold_value         = mean(corr_p);
    
    latencies_list='';
   [fpath fname fext]= fileparts(result_struct_file);
   
   
    fid = fopen(fullfile(brainstorm_data_path,'fname_parsed.txt'));
   
    
    [nsource, ntp] = size(pmap);
    for tp=1:ntp
        latency_data    = pmap(:,tp);
        [val, id]       = min(latency_data);
        if (val < corr_p(tp))
            latency_str     =num2str(res.Time(tp)*1000);
            latencies_list  = [latencies_list ',' latency_str];
            for src=1:nsource
                if (latency_data(src) < corr_p(tp))
                    P_mri       = cs_scs2mri(sMri, surf.Vertices(src,:)' .* 1000)';
                    P_voxels    = bst_bsxfun(@rdivide, P_mri, sMri.Voxsize);
                    mniLoc      = cs_mri2mni(sMri, P_voxels(:));
                    disp(['latency: ' latency_str ', vertex: ' num2str(src) ', coord:' num2str(mniLoc(1)) ',' num2str(mniLoc(2)) ',' num2str(mniLoc(3)) ', values:' num2str(latency_data(src))]);
                
                    fprintf('latency:  %s, vertex:  %s , coord: %s, %s,  %s, values: %s',latency_str, num2str(src),  num2str(mniLoc(1)), num2str(mniLoc(2)), num2str(mniLoc(3)), num2str(latency_data(src)));

                end
            end
        end
    end
    disp(['significant latencies: ' latencies_list]);
    
    fclose all

end
