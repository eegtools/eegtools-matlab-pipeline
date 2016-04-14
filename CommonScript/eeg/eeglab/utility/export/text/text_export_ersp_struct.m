%% function [dataexpcols, dataexp] = text_export_ersp_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_struct(out_file,ersp_struct)


  %% inizialize
    dataexp=[];  
    subj=[];
    f1=[];
    f2=[];
    band=[];
    tw=[];
    roi=[];
    erspmean=[];
    ersp_extr=[];
    ersp_extr_lat=[];
    dataexpcols=[];


    if nargin < 1
       help text_export_ersp_struct;
       return;
    end;
   
    
  

    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2     
                    for ntw=1:length(ersp_struct.group_time_windows_names_design) % for each time window
                        roi=[roi; repmat(ersp_struct.roi_names(nroi),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];
                        band=[band; repmat(ersp_struct.frequency_bands_names(nband),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];                                                
                        f1=[f1; repmat(ersp_struct.study_des.variable(1).value(nl1),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];
                        f2=[f2; repmat(ersp_struct.study_des.variable(2).value(nl2),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];                    
                        tw=[tw; repmat(ersp_struct.group_time_windows_names_design(ntw),length(ersp_struct.list_design_subjects{nl1,nl2}),1)];
                        
                        subj=[subj; ersp_struct.list_design_subjects{nl1,nl2}'];         
                        
                        erspmean=[erspmean; ersp_struct.dataroi(nroi).databand(nband).datatw.find_extrema.curve{nl1,nl2}(ntw,:)'];                        
                        ersp_extr=[ersp_extr; ersp_struct.dataroi(nroi).databand(nband).datatw.find_extrema.extr{nl1,nl2}(ntw,:)'];
                        ersp_extr_lat=[ersp_extr_lat; ersp_struct.dataroi(nroi).databand(nband).datatw.find_extrema.extr_lat{nl1,nl2}(ntw,:)'];                       
                    end             
                end 
            end 
        end 
    end 
    
    erspmean=num2cell(erspmean); 
    ersp_extr=num2cell(ersp_extr);
    ersp_extr_lat=num2cell(ersp_extr_lat);
    
    if isempty(char(ersp_struct.study_des.variable(1).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(2).label), 'band_name' ,'time_window',  'roi', 'ersp_mean', 'ersp_extr', 'ersp_extr_lat'};    
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\r\n';
        dataexp=[subj, f2, band, tw,  roi, erspmean, ersp_extr, ersp_extr_lat];
    elseif isempty(char(ersp_struct.study_des.variable(2).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), 'band_name' ,'time_window',  'roi', 'ersp_mean', 'ersp_extr', 'ersp_extr_lat'};    
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\r\n';  
        dataexp=[subj, f1, band, tw,  roi, erspmean, ersp_extr, ersp_extr_lat];
    else
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label), 'band_name' ,'time_window',  'roi', 'ersp_mean', 'ersp_extr', 'ersp_extr_lat'};    
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\r\n';
        dataexp=[subj, f1, f2, band, tw,  roi, erspmean, ersp_extr, ersp_extr_lat];
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