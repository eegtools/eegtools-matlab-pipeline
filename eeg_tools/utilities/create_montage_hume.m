function [montage_path_hume, montage_path_project] = create_montage_hume(filename,montagedir_hume,montagedir_project)
%CREATE_MONTAGE_HUME Summary of this function goes here
%   Detailed explanation goes here
[fpath,fname,fext] = fileparts(filename);
EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
montage_name = [EEG.filename(1:end-4),'_Montage'];



montage_path_hume = fullfile(montagedir_hume, [montage_name,'.m']);
fid_hume = fopen(montage_path_hume,'w+');

montage_path_project = fullfile(montagedir_project, [montage_name,'.m']);
fid_project = fopen(montage_path_project,'w+');



str_cat_chanlab = [];
for nch =1:EEG.nbchan
    str_cat_chanlab = [str_cat_chanlab, '''' EEG.chanlocs(nch).labels,'''','; '];
end
chancol = {'[1  0  0]','[0  1  0]','[0  0  1]'};
str_cat_chancol = [];
ncol = 1;
for nch =1:EEG.nbchan
    if ncol > 3
        ncol = 1;
    end
    str_cat_chancol = [str_cat_chancol, '' chancol{ncol},'','; '];
    ncol = ncol + 1;
end


chanscale = '150';
str_cat_chanscale = [];
for nch =1:EEG.nbchan
    str_cat_chanscale = [str_cat_chanscale, '''' chanscale,'''','; '];
end



str_cell = ...
    {...
    'function CurrMontage = sleep_Montage(handles)',...
    '% channels to hide',...
    'CurrMontage.hideChans = {};',...
    '%electrode names that should be ploted.',...
    ['CurrMontage.electrodes = flipud({',str_cat_chanlab '});'],...
    '% channels to plot negative up',...
    'CurrMontage.negChans = {};',...
    '% channels to plot as second-to-second numeric data (e.g., SpO2) data',...
    'CurrMontage.o2satChs = {};',...
    '%colors for each electrode. The order and length must match the electrode list',...
    ['CurrMontage.colors = flipud({',str_cat_chancol,'});'],...
    '%scale for each electrode. The order and length must match the electrode list',...
    ['CurrMontage.scale = flipud({',str_cat_chanscale,'});'],...
    '% channels to add scale lines to',...
    'CurrMontage.scaleChans = {};',...
    'CurrMontage.bigGridMat = {};',...
    };

for nstr = 1:length(str_cell)
    str = [str_cell{nstr}];....
        fprintf(fid_hume,'%s\n',str);
        fprintf(fid_project,'%s\n',str);
end
fclose(fid_hume);
fclose(fid_project);

end

