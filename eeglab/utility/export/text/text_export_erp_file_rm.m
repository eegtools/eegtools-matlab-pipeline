%% function [dataexpcols, dataexp] = text_export_erp_file(out_file,in_file)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_file_rm(in_file,out_file)

   
    %% inizialize
    data_mean       = [];  
    data_extr       = [];  
    data_extr_lat   = [];  
    subj            = [];
    cond_label      = ['subjects'];

    erpmean         = [];
    erp_extr        = [];
    erp_extr_lat    = [];
    
    [path, outname, ext] = fileparts(out_file);
    

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
        roi_name = erp_struct.roi_names{nroi}; roi_name = strrep(roi_name, ' ', '');
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2     
                for ntw=1:length(erp_struct.group_time_windows_names_design) % for each time window
                    tw_name = erp_struct.group_time_windows_names_design{ntw}; tw_name = strrep(tw_name, ' ', '');
                    
                    lab={[erp_struct.study_des.variable(1).value{nl1} '_' ...
                         erp_struct.study_des.variable(2).value{nl2} '_' ...
                         roi_name '_'                  ...
                         tw_name]};
                     
                    cond_label      = [cond_label lab]; 
                    erpmean         = [erpmean erp_struct.dataroi(nroi).datatw.curve{nl1,nl2}(ntw,:)'];                        
                    erp_extr        = [erp_extr erp_struct.dataroi(nroi).datatw.extr{nl1,nl2}(ntw,:)'];
                    erp_extr_lat    = [erp_extr_lat erp_struct.dataroi(nroi).datatw.extr_lat{nl1,nl2}(ntw,:)'];                       
                end             
            end 
        end         
    end 
    subj            = erp_struct.list_design_subjects{1,1}'; 
    erpmean         = num2cell(erpmean); 
    erp_extr        = num2cell(erp_extr);
    erp_extr_lat    = num2cell(erp_extr_lat);
   
    num_columns     = length(cond_label);
    formatSpecCols  = [repmat('%s ',1,num_columns),'\r\n'];
    formatSpecData  = ['%s ' repmat('%f ',1,num_columns-1),'\r\n'];

    data_mean       = [subj, erpmean];
    data_extr       = [subj, erp_extr];
    data_extr_lat   = [subj, erp_extr_lat];

    fp_mean         = fopen(fullfile(path, [outname '_mean' ext]),'w');
    fp_extr         = fopen(fullfile(path, [outname '_extr' ext]),'w');
    fp_extr_lat     = fopen(fullfile(path, [outname '_extr_lat' ext]),'w');
    
    fprintf(fp_mean,formatSpecCols,cond_label{:});
    fprintf(fp_extr,formatSpecCols,cond_label{:});
    fprintf(fp_extr_lat,formatSpecCols,cond_label{:});
    
    [nrows,ncols]   = size(data_mean);
    for row = 1:nrows
        fprintf(fp_mean,formatSpecData,data_mean{row,:});
        fprintf(fp_extr,formatSpecData,data_extr{row,:});
        fprintf(fp_extr_lat,formatSpecData,data_extr_lat{row,:});
    end
    
    fclose(fp_mean);
    fclose(fp_extr);
    fclose(fp_extr_lat);
end