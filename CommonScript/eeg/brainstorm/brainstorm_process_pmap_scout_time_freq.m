function brainstorm_process_pmap_scout_time_freq(protocol_name, result_struct_file, StatThreshOptions, time_label_vector)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    brainstorm_anat_path = protocol.SUBJECTS;    
    
    % load result data structure
    if (strcmp(result_struct_file(1),'@'))
        file_name=fullfile(brainstorm_data_path, result_struct_file);
    else
        file_name=result_struct_file;        
    end
    res = load(file_name);
    
    bst_set('StatThreshOptions', StatThreshOptions);
    latencies_list='';  
    nfreq = size(res.pmap,3);
    for fr=1:nfreq    
        [pmask, corr_p] = brainstorm_stat_thresh_freq(res.pmap(:,:,fr));
        threshold_value=mean(corr_p);

        [nscouts, ntp] = size(res.pmap(:,:,fr));
        for tp=1:ntp
            latency_data = res.pmap(:,tp,fr);
            [val, id] = min(latency_data);
            if (val < corr_p(tp))
                latency_str=num2str(time_label_vector(tp));
                latencies_list=[latencies_list ',' latency_str];
                for sct=1:nscouts
                    if (latency_data(sct) < corr_p(tp))

                        disp(['latency: ' latency_str ', vertex: ' num2str(sct) ]);
                    end
                end
            end
        end
    end
    disp(['significant latencies: ' latencies_list]);
end
