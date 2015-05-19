%% function [dataexpcols, dataexp] = text_export_ersp_struct(out_file,ersp_struct)
% export from matlab structure in tab delimited text format data for further statistics.

function [dataexpcols, dataexp] = text_export_nb_struct(out_file,output)


%% inizialize
dataexp=[];
dataexpcols=[];
dfmin =[];
dfmax =[];
fmin =[];
fmax =[];
band_name =[];
ref_tw_name =[];
tmin =[];
tmax =[];
ref_roi_name =[];
ref_cond =[];
fnb = [];
centroid_mean = [];

realign_meaure =[];

if nargin < 1
    help text_export_nb_struct;
    return;
end;

tband = length(output.project.postprocess.ersp.frequency_bands_list);
tsub  = length(output.results.nb.band(1).sub);

for nband=1:tband % for each frequency band
    band_struct = output.project.postprocess.ersp.frequency_bands(nband);
    
    dfmin       = [dfmin;       repmat(band_struct.dfmin,tsub,1)];
    dfmax       = [dfmax;       repmat(band_struct.dfmax,tsub,1)];
    
    band_name   = [band_name;   repmat({band_struct.name},tsub,1)];
    fmin        = [fmin;        repmat(band_struct.min,tsub,1)];
    fmax        = [fmax;        repmat(band_struct.max,tsub,1)];
    
    
    ref_tw_name = [ref_tw_name; repmat({band_struct.ref_tw_name},tsub,1)];
    tmin        = [tmin;        repmat(band_struct.ref_tw_list(1),tsub,1)];
    tmax        = [tmax;          repmat(band_struct.ref_tw_list(2),tsub,1)];
    
    ref_roi_name     = [ref_roi_name;  repmat({band_struct.ref_roi_name},tsub,1)];
    ref_cond    = [ref_cond;      repmat({band_struct.ref_cond},tsub,1)];
    
    realign_meaure    = [realign_meaure;      repmat({band_struct.which_realign_measure},tsub,1)];
    
    fnb               = [fnb; [output.results.nb.band(nband).sub.fnb]'];
    centroid_mean     = [centroid_mean; [output.results.nb.band(nband).sub.centroid_mean]'];
end

sub = repmat( {output.results.nb.band(1).sub.sub_name}, 1,tband)';

fmin=num2cell(fmin);
fmax=num2cell(fmax);
dfmin=num2cell(dfmin);
dfmax=num2cell(dfmax);
tmin=num2cell(tmin);
tmax=num2cell(tmax);
fnb=num2cell(fnb);
centroid_mean=num2cell(centroid_mean);

dataexpcols    = {'subect', 'band_name', 'fmin','fmax', 'ref_tw_name','tmin','tmax','ref_roi','ref_cond','realign_meaure','fnb','dfmin','dfmax','centroid_mean'};
formatSpecCols = [repmat('%s\t',1,length(dataexpcols)-1),'%s\r\n'];

formatSpecData =  '%s\t%s\t%f\t%f\t%s\t%f\t%f\t%s\t%s\t%s\t%f\t%f\t%f\t%f\r\n';
dataexp        = [sub,       band_name,   fmin,  fmax,  ref_tw_name,   tmin,  tmax,  ref_roi_name,  ref_cond,realign_meaure,  fnb,  dfmin,  dfmax,centroid_mean];

fileID = fopen(out_file,'w');
fprintf(fileID,formatSpecCols,dataexpcols{:});
[nrows,ncols] = size(dataexp);
for row = 1:nrows
    fprintf(fileID,formatSpecData,dataexp{row,:});
end

fclose(fileID);


end