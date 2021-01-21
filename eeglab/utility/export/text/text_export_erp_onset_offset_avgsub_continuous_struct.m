%% function [dataexpcols, dataexp] = text_export_erp_continuous_struct(out_file,erp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_erp_onset_offset_avgsub_continuous_struct(out_file,erp_struct)


%% inizialize
dataexp=[];
dataexpcols=[];




%% initialize parameters for tw statistic

cell_curve                                                                 = [];
cell_pvec_corrected                                                        = [];
cell_pvec_raw                                                              = [];
cell_sigvec                                                                = [];
cell_times                                                                 = [];
cell_roi                                                                   = [];
cell_f1                                                                    = [];
cell_f2                                                                    = [];

if nargin < 2
    help text_export_erp_onset_offset_avgsub_continuous_struct;
    return;
end

if (length(erp_struct.study_des.variable) > 1)
    
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            for nl2=1:length(erp_struct.study_des.variable(2).value) % for each level of factor 2
                
                data = erp_struct.dataroi(nroi).datatw.onset_offset.avgsub{nl1,nl2}.continuous;
                
                if not(isempty(data))
                    curve                                                      = data.curve;
                    pvec_corrected                                             = data.pvec_corrected;
                    pvec_raw                                                   = data.pvec_raw;
                    sigvec                                                     = data.sigvec;
                    times                                                      = data.times;
                    
                    lc                                                         = length(curve);
                    
                    roi                                                        = repmat(erp_struct.roi_names(nroi),lc,1);
                    f1                                                         = repmat(erp_struct.study_des.variable(1).value(nl1),lc,1);
                    f2                                                         = repmat(erp_struct.study_des.variable(2).value(nl2),lc,1);
                end
                
                cell_curve                                                     = [cell_curve;                curve];
                cell_pvec_corrected                                            = [cell_pvec_corrected;       pvec_corrected];
                cell_pvec_raw                                                  = [cell_pvec_raw;             pvec_raw];
                cell_sigvec                                                    = [cell_sigvec;               sigvec];
                cell_times                                                     = [cell_times,                times];
                
                
                cell_roi                                                       = [cell_roi; roi];
                cell_f1                                                        = [cell_f1; f1];
                cell_f2                                                        = [cell_f2; f2];
            end
        end
    end
    
    cell_curve            = num2cell(cell_curve);
    cell_times            = num2cell(cell_times');
    cell_pvec_corrected   = num2cell(cell_pvec_corrected);
    cell_pvec_raw         = num2cell(cell_pvec_raw);
    cell_sigvec           = num2cell(cell_sigvec);
    
    
    
    
    if isempty(char(erp_struct.study_des.variable(1).label))
        dataexpcols={ char(erp_struct.study_des.variable(2).label) ,  'roi',...
            'times',    'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[cell_f2,                    cell_roi, ...
            cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
            ];
        
    elseif isempty(char(erp_struct.study_des.variable(2).label))
        
        dataexpcols={ char(erp_struct.study_des.variable(1).label) , 'roi',...
            'times',   'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData =  '%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[cell_f1,                    cell_roi, ...
            cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
            ];
        
    else
        dataexpcols={ char(erp_struct.study_des.variable(1).label), char(erp_struct.study_des.variable(2).label),'roi',...
            'times',    'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        dataexp=[                      cell_f1,                      cell_f2,                       cell_roi, ...
            cell_times, cell_curve,           cell_pvec_raw,                cell_pvec_corrected,           cell_sigvec,...
            ];
    end
    
    %     out_file = fullfile(plot_dir,'erp_topo-stat.txt');
    fileID = fopen(out_file,'w');
    fprintf(fileID,formatSpecCols,dataexpcols{:});
    [nrows,ncols] = size(dataexp);
    for row = 1:nrows
        fprintf(fileID,formatSpecData,dataexp{row,:});
    end
else
    
    for nroi=1:length(erp_struct.roi_names) % for each roi
        for nl1=1:length(erp_struct.study_des.variable(1).value) % for each level of factor 1
            
            data = erp_struct.dataroi(nroi).datatw.onset_offset.avgsub{nl1}.continuous;
            
            if not(isempty(data))
                curve                                                      = data.curve;
                pvec_corrected                                             = data.pvec_corrected;
                pvec_raw                                                   = data.pvec_raw;
                sigvec                                                     = data.sigvec;
                times                                                      = data.times;
                
                lc                                                         = length(curve);
                
                roi                                                        = repmat(erp_struct.roi_names(nroi),lc,1);
                f1                                                         = repmat(erp_struct.study_des.variable(1).value(nl1),lc,1);
            end
            
            cell_curve                                                     = [cell_curve;                curve];
            cell_pvec_corrected                                            = [cell_pvec_corrected;       pvec_corrected];
            cell_pvec_raw                                                  = [cell_pvec_raw;             pvec_raw];
            cell_sigvec                                                    = [cell_sigvec;               sigvec];
            cell_times                                                     = [cell_times,                times];
            
            
            cell_roi                                                       = [cell_roi; roi];
            cell_f1                                                        = [cell_f1; f1];
            
        end
    end
    
    cell_curve            = num2cell(cell_curve);
    cell_times            = num2cell(cell_times');
    cell_pvec_corrected   = num2cell(cell_pvec_corrected);
    cell_pvec_raw         = num2cell(cell_pvec_raw);
    cell_sigvec           = num2cell(cell_sigvec);
    
    
    
    
    
    
    
    dataexpcols={ char(erp_struct.study_des.variable(1).label) , 'roi',...
        'times',   'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData =  '%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
    
    
    dataexp=[cell_f1,                    cell_roi, ...
        cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
        ];
    
    
    
    %     out_file = fullfile(plot_dir,'erp_topo-stat.txt');
    fileID = fopen(out_file,'w');
    fprintf(fileID,formatSpecCols,dataexpcols{:});
    [nrows,ncols] = size(dataexp);
    for row = 1:nrows
        fprintf(fileID,formatSpecData,dataexp{row,:});
    end
    
end

fclose(fileID);


%% export pvalues / significance for each time point


end