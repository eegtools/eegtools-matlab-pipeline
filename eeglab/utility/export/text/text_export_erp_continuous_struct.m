%% function [dataexpcols, dataexp] = text_export_erp_continuous_struct(out_file,erp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_continuous_struct(out_file,erp_struct)


%% inizialize
dataexp=[];
subj=[];
f1=[];
f2=[];
time=[];
roi=[];
erpmean=[];
erp_extr=[];
erp_extr_lat=[];
dataexpcols=[];


if nargin < 2
    help text_export_erp_continuous_struct;
    return;
end

num_var_des = length(erp_struct.study_des.variable);
if(num_var_des > 1)
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2
                sub_list = erp_struct.list_design_subjects{nl1,nl2};
                for nsub=1:length(sub_list) % for each subject
                    erp_sub = erp_struct.dataroi(nroi).erp_curve_roi{nl1,nl2}(:,nsub);
                    les      = length(erp_sub);
                    erpmean=[erpmean; erp_sub];
                    roi=[roi; repmat(erp_struct.roi_names(nroi),les,1)];
                    f1=[f1; repmat(erp_struct.study_des.variable(1).value(nl1),les,1)];
                    f2=[f2; repmat(erp_struct.study_des.variable(2).value(nl2),les,1)];
                    time=[time, erp_struct.times];
                    subj=[subj; repmat(sub_list(nsub),les,1)];
                end
            end
        end
    end
    
    erpmean=num2cell(erpmean);
    time=num2cell(time)';
    
    
    if isempty(char(erp_struct.study_des.variable(1).label))
        dataexpcols={'subject', char(erp_struct.study_des.variable(2).label) ,'time_ms',  'roi', 'erp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f2, time,  roi, erpmean];
    elseif isempty(char(erp_struct.study_des.variable(2).label))
        dataexpcols={'subject', char(erp_struct.study_des.variable(1).label), 'time_ms',  'roi', 'erp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f1, time,  roi, erpmean];
    else
        dataexpcols={'subject', char(erp_struct.study_des.variable(1).label), char(erp_struct.study_des.variable(2).label), 'time_ms',  'roi', 'erp_mean'};
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        formatSpecData = '%s\t%s\t%s\t%f\t%s\t%f\r\n';
        dataexp=[subj, f1, f2, time,  roi, erpmean];
    end
else
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            %             for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2
            sub_list = erp_struct.list_design_subjects{nl1};
            for nsub=1:length(sub_list) % for each subject
                erp_sub = erp_struct.dataroi(nroi).erp_curve_roi{nl1}(:,nsub);
                les      = length(erp_sub);
                erpmean=[erpmean; erp_sub];
                roi=[roi; repmat(erp_struct.roi_names(nroi),les,1)];
                f1=[f1; repmat(erp_struct.study_des.variable(1).value(nl1),les,1)];
                %                     f2=[f2; repmat(erp_struct.study_des.variable(2).value(nl2),les,1)];
                time=[time, erp_struct.times];
                subj=[subj; repmat(sub_list(nsub),les,1)];
            end
            %             end
        end
    end
    
    erpmean=num2cell(erpmean);
    time=num2cell(time)';
    
    
    
    
    dataexpcols={'subject', char(erp_struct.study_des.variable(1).label), 'time_ms',  'roi', 'erp_mean'};
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    formatSpecData = '%s\t%s\t%f\t%s\t%f\r\n';
    dataexp=[subj, f1, time,  roi, erpmean];
    
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