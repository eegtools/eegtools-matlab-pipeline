%% function [dataexpcols, dataexp] = text_export_ersp_continuous_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_ersp_onset_offset_sub_continuous_struct(out_file,ersp_struct)


%% inizialize
dataexp=[];
dataexpcols=[];




%% initialize parameters for tw statistic

cell_curve                                                                 = [];
cell_pvec_corrected                                                        = [];
cell_pvec_raw                                                              = [];
cell_sigvec                                                                = [];
cell_times                                                                 = [];
cell_sub                                                                   = [];
cell_roi                                                                   = [];
cell_f1                                                                    = [];
cell_f2                                                                    = [];
cell_band                                                                  = [];


if nargin < 2
    help text_export_ersp_onset_offset_sub_continuous_struct;
    return;
end;

if (length(ersp_struct.study_des.variable) > 1)
    
    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                for nl2=1:length(ersp_struct.study_des.variable(2).value) % for each level of factor 2
                    sub_list = ersp_struct.list_design_subjects{nl1,nl2};
                    for nsub=1:length(sub_list) % for each subject
                        data = ersp_struct.dataroi(nroi).databand(nband).datatw.onset_offset.sub{nl1,nl2,nsub}.continuous;
                        
                        if not(isempty(data))
                            curve                                                      = data.curve;
                            pvec_corrected                                             = data.pvec_corrected;
                            pvec_raw                                                   = data.pvec_raw;
                            sigvec                                                     = data.sigvec;
                            times                                                      = data.times;
                            
                            lc                                                         = length(curve);
                            
                            roi                                                        = repmat(ersp_struct.roi_names(nroi),lc,1);
                            f1                                                         = repmat(ersp_struct.study_des.variable(1).value(nl1),lc,1);
                            f2                                                         = repmat(ersp_struct.study_des.variable(2).value(nl2),lc,1);
                            band                                                       = repmat(ersp_struct.frequency_bands_names(nband),lc,1);
                            
                            sub                                                        = repmat(sub_list(nsub),lc,1);
                        end
                        
                        cell_curve                                                     = [cell_curve;                curve];
                        cell_pvec_corrected                                            = [cell_pvec_corrected;       pvec_corrected];
                        cell_pvec_raw                                                  = [cell_pvec_raw;             pvec_raw];
                        cell_sigvec                                                    = [cell_sigvec;               sigvec];
                        cell_times                                                     = [cell_times,                times];
                        
                        cell_sub                                                       = [cell_sub; sub];
                        cell_roi                                                       = [cell_roi; roi];
                        cell_f1                                                        = [cell_f1; f1];
                        cell_f2                                                        = [cell_f2; f2];
                        cell_band                                                      = [cell_band; band];
                    end
                end
            end
        end
    end
    cell_curve            = num2cell(cell_curve);
    cell_times            = num2cell(cell_times');
    cell_pvec_corrected   = num2cell(cell_pvec_corrected);
    cell_pvec_raw         = num2cell(cell_pvec_raw);
    cell_sigvec           = num2cell(cell_sigvec);
    
    
    
    
    if isempty(char(ersp_struct.study_des.variable(1).label))
        dataexpcols={ char(ersp_struct.study_des.variable(2).label) ,  'roi','band' ,'sub',...
            'times',    'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[cell_f2,                    cell_roi,cell_band, cell_sub,...
            cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
            ];
        
    elseif isempty(char(ersp_struct.study_des.variable(2).label))
        
        dataexpcols={ char(ersp_struct.study_des.variable(1).label) , 'roi','band' , 'sub',...
            'times',   'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData =  '%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        
        dataexp=[cell_f1,                    cell_roi,cell_band, cell_sub,...
            cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
            ];
        
    else
        dataexpcols={ char(ersp_struct.study_des.variable(1).label), char(ersp_struct.study_des.variable(2).label),'roi','band' , 'sub',...
            'times',    'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
            };
        
        formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
        
        formatSpecData = '%s\t%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
        
        dataexp=[                      cell_f1,                      cell_f2,                       cell_roi, cell_band,cell_sub,...
            cell_times, cell_curve,           cell_pvec_raw,                cell_pvec_corrected,           cell_sigvec,...
            ];
    end
else
    for nroi=1:length(ersp_struct.roi_names) % for each roi
        for nband=1:length(ersp_struct.frequency_bands_names) % for each frequency band
            for nl1=1:length(ersp_struct.study_des.variable(1).value) % for each level of factor 1
                sub_list = ersp_struct.list_design_subjects{nl1,1};
                for nsub=1:length(sub_list) % for each subject
                    data = ersp_struct.dataroi(nroi).databand(nband).datatw.onset_offset.sub{nl1,nsub}.continuous;
                    
                    if not(isempty(data))
                        curve                                                      = data.curve;
                        pvec_corrected                                             = data.pvec_corrected;
                        pvec_raw                                                   = data.pvec_raw;
                        sigvec                                                     = data.sigvec;
                        times                                                      = data.times;
                        
                        lc                                                         = length(curve);
                        
                        roi                                                        = repmat(ersp_struct.roi_names(nroi),lc,1);
                        f1                                                         = repmat(ersp_struct.study_des.variable(1).value(nl1),lc,1);
                        band                                                       = repmat(ersp_struct.frequency_bands_names(nband),lc,1);
                        
                        sub                                                        = repmat(sub_list(nsub),lc,1);
                    end
                    
                    cell_curve                                                     = [cell_curve;                curve];
                    cell_pvec_corrected                                            = [cell_pvec_corrected;       pvec_corrected];
                    cell_pvec_raw                                                  = [cell_pvec_raw;             pvec_raw];
                    cell_sigvec                                                    = [cell_sigvec;               sigvec];
                    cell_times                                                     = [cell_times,                times];
                    
                    cell_sub                                                       = [cell_sub; sub];
                    cell_roi                                                       = [cell_roi; roi];
                    cell_f1                                                        = [cell_f1; f1];
                    cell_band                                                      = [cell_band; band];
                end
            end
        end
    end
    cell_curve            = num2cell(cell_curve);
    cell_times            = num2cell(cell_times');
    cell_pvec_corrected   = num2cell(cell_pvec_corrected);
    cell_pvec_raw         = num2cell(cell_pvec_raw);
    cell_sigvec           = num2cell(cell_sigvec);
    
    
    
    
    
    
    dataexpcols={ char(ersp_struct.study_des.variable(1).label) , 'roi','band' , 'sub',...
        'times',   'curve',                    'pvec_raw',    'pvec_corrected',                  'sigvec', ...
        };
    
    formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];
    
    formatSpecData =  '%s\t%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\r\n';
    
    
    dataexp=[cell_f1,                    cell_roi,cell_band, cell_sub,...
        cell_times, cell_curve,                 cell_pvec_raw,    cell_pvec_corrected,              cell_sigvec,...
        ];
    
    
end
%     out_file = fullfile(plot_dir,'ersp_topo-stat.txt');
fileID = fopen(out_file,'w');
fprintf(fileID,formatSpecCols,dataexpcols{:});
[nrows,ncols] = size(dataexp);
for row = 1:nrows
    fprintf(fileID,formatSpecData,dataexp{row,:});
end


fclose(fileID);


%% export pvalues / significance for each time point


end