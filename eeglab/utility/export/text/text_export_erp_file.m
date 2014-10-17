%% function [dataexpcols, dataexp] = text_export_erp_file(out_file,in_file)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_file(in_file,out_file)

   
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
           help text_export_erp_file;
           return;    
    end;

    load(in_file);
    if  exist('erp_curve_roi_stat','var')
        erp_struct=erp_curve_roi_stat; 
    elseif exist('erp_compact','var')
        erp_struct= erp_compact.erp_curve_roi_stat; 
    else
        display('ERROR: missing data in the mat file!!!!')
        return;
    end

    
    
    for nroi=1:length(erp_struct.roi_names) % for each roi        
        roi_name = erp_struct.roi_names{nroi}; roi_name = strrep(roi_name, ' ', '_');
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2     
                for ntw=1:length(erp_struct.group_time_windows_names_design) % for each time window
                    tw_name = erp_struct.group_time_windows_names_design{ntw}; tw_name = strrep(tw_name, ' ', '_');
                    
                    roi=[roi; repmat({roi_name},length(erp_struct.list_design_subjects{nl1,nl2}),1)];                    
                    f1=[f1; repmat(erp_struct.study_des.variable(1).value(nl1),length(erp_struct.list_design_subjects{nl1,nl2}),1)];
                    f2=[f2; repmat(erp_struct.study_des.variable(2).value(nl2),length(erp_struct.list_design_subjects{nl1,nl2}),1)];                    
                    tw=[tw; repmat({tw_name}, length(erp_struct.list_design_subjects{nl1,nl2}),1)];

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