%% function [dataexpcols, dataexp] = text_export_erp_struct(out_file,erp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_struct(out_file,erp_struct)


 %% inizialize
    dataexp=[];  
    subj=[];
    f1=[];
    f2=[];   
    tw=[];
    roi=[];
    erpmean=[];
    erp_extr=[];
    erp_extr_lat=[];
    dataexpcols=[];


    if nargin < 2
       help text_export_erp_struct;
       return;
    end;

   
    for nroi=1:length(erp_struct.roi_names) % for each roi        
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2     
                for ntw=1:length(erp_struct.group_time_windows_names_design) % for each time window
                    roi=[roi; repmat(erp_struct.roi_names(nroi),length(erp_struct.list_design_subjects{nl1,nl2}),1)];                    
                    f1=[f1; repmat(erp_struct.study_des.variable(1).value(nl1),length(erp_struct.list_design_subjects{nl1,nl2}),1)];
                    f2=[f2; repmat(erp_struct.study_des.variable(2).value(nl2),length(erp_struct.list_design_subjects{nl1,nl2}),1)];                    
                    tw=[tw; repmat(erp_struct.group_time_windows_names_design(ntw),length(erp_struct.list_design_subjects{nl1,nl2}),1)];

                    subj=[subj; erp_struct.list_design_subjects{nl1,nl2}'];                        
                    erpmean=[erpmean; erp_struct.dataroi(nroi).datatw.curve{nl1,nl2}(ntw,:)'];                        
                    erp_extr=[erp_extr; erp_struct.dataroi(nroi).datatw.extr{nl1,nl2}(ntw,:)'];
                    erp_extr_lat=[erp_extr_lat; erp_struct.dataroi(nroi).datatw.extr_lat{nl1,nl2}(ntw,:)'];                       
                end             
            end 
        end         
    end 
    
    erpmean=num2cell(erpmean); 
    erp_extr=num2cell(erp_extr);
    erp_extr_lat=num2cell(erp_extr_lat);
    
    if isempty(char(erp_struct.study_des.variable(1).label))
        dataexpcols={'subject', char(erp_struct.study_des.variable(2).label) ,'time_window',  'roi', 'erp_mean', 'erp_extr', 'erp_extr_lat'};    
        formatSpecCols = [repmat('%s ',1,length(dataexpcols)),'\r\n'];
        formatSpecData = '%s  %s %s %s %f %f %f\r\n';
        dataexp=[subj, f2, tw,  roi, erpmean, erp_extr, erp_extr_lat];
    elseif isempty(char(erp_struct.study_des.variable(2).label))
        dataexpcols={'subject', char(erp_struct.study_des.variable(1).label), 'time_window',  'roi', 'erp_mean', 'erp_extr', 'erp_extr_lat'};    
        formatSpecCols = [repmat('%s ',1,length(dataexpcols)),'\r\n'];
        formatSpecData = '%s %s  %s %s %f %f %f\r\n';  
        dataexp=[subj, f1, tw,  roi, erpmean, erp_extr, erp_extr_lat];
    else
        dataexpcols={'subject', char(erp_struct.study_des.variable(1).label), char(erp_struct.study_des.variable(2).label), 'time_window',  'roi', 'erp_mean', 'erp_extr', 'erp_extr_lat'};    
        formatSpecCols = [repmat('%s ',1,length(dataexpcols)),'\r\n'];
        formatSpecData = '%s %s %s %s %s %f %f %f\r\n';
        dataexp=[subj, f1, f2, tw,  roi, erpmean, erp_extr, erp_extr_lat];
    end
    
%     out_file = fullfile(plot_dir,'erp_topo-stat.txt');
    fileID = fopen(out_file,'w');
    fprintf(fileID,formatSpecCols,dataexpcols{:});
    [nrows,ncols] = size(dataexp);
    for row = 1:nrows
        fprintf(fileID,formatSpecData,dataexp{row,:});
    end


    fclose(fileID);


end