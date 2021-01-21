%% function [dataexpcols, dataexp] = text_export_ersp_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_continuous_struct(out_file,ersp_struct)


%% inizialize
dataexp=[];
subj=[];
f1=[];
f2=[];
band=[];
time=[];
roi=[];
erspmean=[];
ersp_extr=[];
ersp_extr_lat=[];
dataexpcols=[];


if nargin < 1
    help text_export_ersp_struct;
    return;
end;



if(length(ersp_struct.study_des.variable) > 1)
    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2
                    
                    sub_list = ersp_struct.list_design_subjects{nl1,nl2};
                    
                    for nsub=1:length(sub_list) % for each subject
                        ersp_sub = ersp_struct.dataroi(nroi).databand(nband).ersp_curve_roi_fb{nl1,nl2}(:,nsub);
                        les      = length(ersp_sub);
                        
                        erspmean=[erspmean; ersp_sub];
                        
                        roi=[roi; repmat(ersp_struct.roi_names(nroi),les,1)];
                        band=[band; repmat(ersp_struct.frequency_bands_names(nband),les,1)];
                        f1=[f1; repmat(ersp_struct.study_des.variable(1).value(nl1),les,1)];
                        f2=[f2; repmat(ersp_struct.study_des.variable(2).value(nl2),les,1)];
                        time=[time, ersp_struct.times];
                        subj=[subj; repmat(sub_list(nsub),les,1)];
                        
                        
                    end
                end
            end
        end
    end
    
    erspmean=num2cell(erspmean);
    time=num2cell(time)';
    
    if isempty(char(ersp_struct.study_des.variable(1).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(2).label), 'band_name' ,'time_ms',  'roi', 'ersp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f2, band, time,  roi, erspmean];
    elseif isempty(char(ersp_struct.study_des.variable(2).label))
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), 'band_name' ,'time_ms',  'roi', 'ersp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f1, band, time,  roi, erspmean];
    else
        dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label), 'band_name' ,'time_ms',  'roi', 'ersp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f1, f2, band, time,  roi, erspmean];
    end
else
    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                
                sub_list = ersp_struct.list_design_subjects{nl1,1};
                
                for nsub=1:length(sub_list) % for each subject
                    ersp_sub = ersp_struct.dataroi(nroi).databand(nband).ersp_curve_roi_fb{nl1,1}(:,nsub);
                    les      = length(ersp_sub);
                    
                    erspmean=[erspmean; ersp_sub];
                    
                    roi=[roi; repmat(ersp_struct.roi_names(nroi),les,1)];
                    band=[band; repmat(ersp_struct.frequency_bands_names(nband),les,1)];
                    f1=[f1; repmat(ersp_struct.study_des.variable(1).value(nl1),les,1)];
                    time=[time, ersp_struct.times];
                    subj=[subj; repmat(sub_list(nsub),les,1)];
                    
                    
                end
            end
        end
    end
    
    erspmean=num2cell(erspmean);
    time=num2cell(time)';
    
    
    dataexpcols={'subject', char(ersp_struct.study_des.variable(1).label), 'band_name' ,'time_ms',  'roi', 'ersp_mean'};
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    formatSpecData = '%s\t%s\t%s\t%f\t%s\t%f\r\n';
    dataexp=[subj, f1, band, time,  roi, erspmean];
    
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