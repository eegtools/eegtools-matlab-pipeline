function [ statscond, statsgroup, dfcond, dfgroup, pcond, pgroup, compcond, compgroup]=pairwise_compairsons_stats(data_roi_sub,stat_method,num_permutations,num_tails)
    

%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a
%           STUDY for epochs of 800 frames in two conditions from three
%           groups of 12 subjects:
%
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
%           >> pcond = std_stat(data, 'condstats', 'on');


% for each subject take the average of the selected roi
    pcond=[];
    pgroup=[];
    statscond=[];
    statsgroup=[];
    dfcond=[];
    dfgroup=[];
    compcond=[];
    compgroup=[];
    
    
    tot_cond=size(data_roi_sub,1);
    tot_group=size(data_roi_sub,2);
     
    if tot_cond>1 % if more than one condition (rows), for each group (clumn) compare its conditions (rows, i.e. cells because only one column is considered)  
        for ngroup=1:tot_group
            comparisons = combn_all(1:tot_cond,2);
            num_comparisons = length(comparisons);

            tvec=[];
            dfvec=[];
            pvec=[];
            compmat=[];
            for ncomp=1:num_comparisons                            
                [tvals dfvals pvals] = statcond_corr(data_roi_sub(comparisons{ncomp},ngroup),num_tails, 'method', stat_method, 'naccu', num_permutations);
                tvec=[tvec, tvals];
                dfvec=[dfvec, dfvals];
                pvec=[pvec, pvals];   
                compmat=[compmat,comparisons{ncomp}'];
            end
            pcond{ngroup}=pvec;
            statscond{ngroup}=tvec;
            dfcond{ngroup}=dfvec;
            compcond{ngroup}=compmat;
        end
    end % pcond has for each group (column), the comparison between conditions (rows)
    
    
    
    if tot_group>1  % if more than one group (columns), for each condition (row) compare its groups (columns, i.e. cells beacause only one row is considered)  
        for ncond=1:tot_cond
            comparisons = combn_all(1:tot_group,2);
            num_comparisons = length(comparisons);
            tvec=[];
            dfvec=[];
            pvec=[];
            compmat=[];           
            
            for ncomp=1:num_comparisons    
                [tvals dfvals pvals] = statcond_corr(data_roi_sub(ncond,comparisons{ncomp}), num_tails, 'method', stat_method, 'naccu', num_permutations);
                tvec=[tvec, tvals];
                dfvec=[dfvec, dfvals];
                pvec=[pvec, pvals];
                compmat=[compmat,comparisons{ncomp}'];
            end
            pgroup{ncond}=pvec;
            statsgroup{ncond}=tvec;
            dfgroup{ncond}=dfvec;
            compgroup{ncond}=compmat;
        end
    end % pgroup has for each condition (row), the comparison between groups (columns)
    
    
    
    
    
    
    
    
    
    
    
    
    
end
