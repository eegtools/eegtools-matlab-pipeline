%% function [dataexpcols, dataexp] = text_export_ersp_fb_realign(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data about narrouband realignment for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_fb_realign(out_file,ersp_struct)


  %% inizialize
    dataexp=[];  
    subj=[];
    f1=[];
    f2=[];
    band=[];    
    roi=[];
    
    realign_freq=[]
    realign_freq_measure=[];
    realign_freq_measure_lat=[];
    
    erspmean=[];
    ersp_extr=[];
    ersp_extr_lat=[];
    dataexpcols=[];


    if nargin < 1
       help text_export_ersp_fb_realign;
       return;
    end;
   
    
  

    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2     
                    
                        roi=[roi; repmat(ersp_struct.roi_names(nroi),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];
                        band=[band; repmat(ersp_struct.frequency_bands_names(nband),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];                                                
                        f1=[f1; repmat(ersp_struct.study_des.variable(1).value(nl1),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];
                        f2=[f2; repmat(ersp_struct.study_des.variable(2).value(nl2),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];                    
                       
                        
                        subj=[subj; ersp_struct.list_design_subjects{nl1,nl2}'];                        
               
                        adjusted_fmin=[adjusted_fmin,ersp_struct.dataroi(nroi).databand(nband).narrow_band.adjusted_frequency_band{nl1,nl2}(:,1)];
                        adjusted_fmax=[adjusted_fmax,ersp_struct.dataroi(nroi).databand(nband).narrow_band.adjusted_frequency_band{nl1,nl2}(:,2)];
                        adjusted_realign_freq=[adjusted_realign_freq,ersp_struct.dataroi(nroi).databand(nband).narrow_band.adjusted_realign_freq{nl1,nl2}];
                        adjusted_realign_freq_value=[adjusted_realign_freq_value,ersp_struct.dataroi(nroi).databand(nband).narrow_band.adjusted_realign_freq_value{nl1,nl2}];
                        adjusted_realign_freq_value_lat=[adjusted_realign_freq_value_lat,ersp_struct.dataroi(nroi).databand(nband).narrow_band.adjusted_realign_freq_value_lat{nl1,nl2}];
                        mean_centroid_group_fb=[mean_centroid_group_fb,ersp_struct.dataroi(nroi).databand(nband).narrow_band.mean_centroid_group_fb{nl1,nl2}];
                        mean_centroid_sub_realign_fb=[mean_centroid_sub_realign_fb,ersp_struct.dataroi(nroi).databand(nband).narrow_band.mean_centroid_sub_realign_fb{nl1,nl2}];
                        median_centroid_group_fb=[median_centroid_group_fb,ersp_struct.dataroi(nroi).databand(nband).narrow_band.median_centroid_group_fb{nl1,nl2}];
                        median_centroid_sub_realign_fb=[median_centroid_sub_realign_fb,ersp_struct.dataroi(nroi).databand(nband).narrow_band.median_centroid_sub_realign_fb{nl1,nl2}];
                        

                        
                        
                        
                        
                end 
            end 
        end 
    end 
    
    erspmean=num2cell(erspmean); 
    ersp_extr=num2cell(ersp_extr);
    ersp_extr_lat=num2cell(ersp_extr_lat);
    
    
    adjusted_fmin=num2cell(adjusted_fmin);
    adjusted_fmax=num2cell(adjusted_fmax);
    adjusted_realign_freq=num2cell(adjusted_realign_freq);
    adjusted_realign_freq_value=num2cell(adjusted_realign_freq_value);
    adjusted_realign_freq_value_lat=num2cell(adjusted_realign_freq_value_lat);
    mean_centroid_group_fb=num2cell(mean_centroid_group_fb);
    mean_centroid_sub_realign_fb=num2cell(mean_centroid_sub_realign_fb);
    median_centroid_group_fb=num2cell(median_centroid_group_fb);
    median_centroid_sub_realign_fb=num2cell(median_centroid_sub_realign_fb);
                       
    
    if isempty(char(ersp_struct.study_des.variable(1).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(2).label), ...
            'band_name' ,'time_window',  'roi', ....
            'adjusted_fmin', 'adjusted_fmax', 'adjusted_realign_freq','adjusted_realign_freq_value',...
            'adjusted_realign_freq_value_lat',' mean_centroid_group_fb',' mean_centroid_sub_realign_fb',' median_centroid_group_fb','median_centroid_sub_realign_fb'};    
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
        dataexp=[subj, f2, band, tw,  roi,...
            adjusted_fmin, adjusted_fmax, adjusted_realign_freq, adjusted_realign_freq_value,...
           adjusted_realign_freq_value_lat, mean_centroid_group_fb, mean_centroid_sub_realign_fb, median_centroid_group_fb, median_centroid_sub_realign_fb];
       
    elseif isempty(char(ersp_struct.study_des.variable(2).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), 'band_name' ,'time_window',  'roi', ....
           'adjusted_fmin', 'adjusted_fmax', 'adjusted_realign_freq','adjusted_realign_freq_value',...
            'adjusted_realign_freq_value_lat',' mean_centroid_group_fb',' mean_centroid_sub_realign_fb',' median_centroid_group_fb','median_centroid_sub_realign_fb'};  
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';  
        dataexp=[subj, f1, band, tw,  roi,...
            adjusted_fmin, adjusted_fmax, adjusted_realign_freq, adjusted_realign_freq_value,...
           adjusted_realign_freq_value_lat, mean_centroid_group_fb, mean_centroid_sub_realign_fb, median_centroid_group_fb, median_centroid_sub_realign_fb];
       
    else
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label), 'band_name' ,'time_window',  'roi', ...
            'adjusted_fmin', 'adjusted_fmax', 'adjusted_realign_freq','adjusted_realign_freq_value',...
            'adjusted_realign_freq_value_lat',' mean_centroid_group_fb',' mean_centroid_sub_realign_fb',' median_centroid_group_fb','median_centroid_sub_realign_fb'};  
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n';
        dataexp=[subj, f1, f2, band, tw,  roi,...
            adjusted_fmin, adjusted_fmax, adjusted_realign_freq, adjusted_realign_freq_value,...
           adjusted_realign_freq_value_lat, mean_centroid_group_fb, mean_centroid_sub_realign_fb, median_centroid_group_fb, median_centroid_sub_realign_fb];
       
    end
    
%     out_file = fullfile(output_file,'ersp_tf_topo-stat.txt');
    fileID = fopen(out_file,'w');
    fprintf(fileID,formatSpecCols,dataexpcols{:});
    [nrows,ncols] = size(dataexp);
    for row = 1:nrows
        fprintf(fileID,formatSpecData,dataexp{row,:});
    end


    fclose(fileID);


end