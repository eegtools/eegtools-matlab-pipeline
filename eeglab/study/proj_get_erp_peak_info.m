%% function [extr_lat] = proj_get_erp_peak_info(project, out_file)
% open a results file and get the latencies of all the TW peaks in each condition
% ONLY suited for that design reporting all the plain conditions. not structured factors
%
% VARARGIN INPUTs
% list_windows_names :  {'P100', 'N330', etc...}
% list_subjects : {'aa', 'bb', ...etc}
%
% OUTPUT:
% a s


function [extr_lat] = proj_get_erp_peak_info(project, input_mat_file, varargin)


    if nargin < 1
           help get_erp_peak_info;
           return;    
    end;

    %% get correct structure
    load(input_mat_file);
    if  exist('erp_curve_roi_stat','var')
        erp_struct=erp_curve_roi_stat; 
    elseif exist('erp_compact','var')
        erp_struct= erp_compact.erp_curve_roi_stat; 
    else
        display('ERROR: missing data in the mat file!!!!')
        return;
    end
    
    %% set default
    list_windows_names  = erp_struct.group_time_windows_names_design;
    list_subjects       = erp_struct.list_design_subjects{1};
    condition_names     = project.epoching.condition_names;
    
    for par=1:2:length(varargin)
       switch varargin{par}
           case {'list_windows_names', 'list_subjects', 'condition_names'}
                if isempty(varargin{par+1})
                    continue;
                else
                    assign(varargin{par}, varargin{par+1});
                end
       end
    end    
    
    %% set subject filter
    subj_filter = [];
    for s=1:length(erp_struct.list_design_subjects{1})
        for ss=1:length(list_subjects)
            if strcmp(list_subjects{ss}, erp_struct.list_design_subjects{1}{s})
                subj_filter = [subj_filter s];
            end
        end
    end

    %% output allocation
    extr_lat = zeros(length(condition_names), length(list_windows_names), length(subj_filter)); ... NCOND x TIMEWINDOW x SUBJECT

    
    %%
    for ntw=1:length(list_windows_names) % for each input time window
        tw_name = list_windows_names{ntw};
        
        %% get time window ID within the results structure
        for ntw_in_struct=1:length(erp_struct.group_time_windows_names_design)
            if strcmp(tw_name, erp_struct.group_time_windows_names_design{ntw_in_struct})
                break;
            end
        end
        
        %% get 'reference rois' name for input window
        ref_roi = {};
        curr_des_num = 1; ...erp_struct.study_des.num;
        for ntw_in_proj=1:length(project.postprocess.erp.design(curr_des_num).group_time_windows)
            if strcmp(tw_name, project.postprocess.erp.design(curr_des_num).group_time_windows(ntw_in_proj).name)
                ref_roi = [ref_roi project.postprocess.erp.design(curr_des_num).group_time_windows(ntw_in_proj).ref_roi];
                break;
            end
        end
        if isempty(ref_roi)
            disp(['ERROR in get_erp_peak_info: the ref_roi of time window ' tw_name ' was not found !!']);
            return;
        end
        
        %% get 'reference rois' ID within results structure
        roi_id = [];
        for nroi=1:length(ref_roi)
            for nnroi=1:length(erp_struct.roi_names)
                if strcmp(ref_roi{nroi}, erp_struct.roi_names{nnroi})
                    roi_id = [roi_id nnroi];
                end
            end
        end
        
        
        %% get 
        data_rois = erp_struct.dataroi(roi_id);
        for dr=1:length(data_rois)
            roi_lat_struct{dr} = data_rois(dr).datatw.find_extrema.extr_lat;
        end        

        
        %% get conditions ID within results structure
        cond_id = []; ...zeros(1,length(condition_names));
        for cond=1:length(condition_names)
            for cnd=1:length(erp_struct.study_des.variable(1).value)
                if strcmp(condition_names{cond}, erp_struct.study_des.variable(1).value{cnd})
                    cond_id = [cond_id cnd];
                end
            end
        end
        
        %% get DATA
        for cond=1:length(condition_names) % for each CONDITION (level of factor 1)
            latencies = zeros(length(data_rois), length(subj_filter));
            for l=1:length(data_rois)
                latencies(l,:) = roi_lat_struct{l}{cond_id(cond)}(ntw_in_struct, subj_filter);
            end
            extr_lat(cond, ntw, :) = mean(latencies, 1);
        end
    end
end