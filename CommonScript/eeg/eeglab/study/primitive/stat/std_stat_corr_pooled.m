%% function [pcond, pgroup, pinter, statscond, statsgroup, statsinter, pcond_single_rep,pgroup_single_rep,pinter_single_rep, statscond_single_rep, statsgroup_single_rep, statsinter_single_rep] = ...
%            std_stat_corr_pooled(cell_array,varargin)

% calculate statistics for a certain number of permutations (EEGLab naccu). Then,
% to obtain more robust estimations of P values do the process for a certain number of repetitions and calculate mean or median over repetitions.
% ====================================================================================================
% REQUIRED INPUT:
%
% ---------------------------------------------------------------------------------------------------- 
% cell_array
%
% ====================================================================================================
% OPTIONAL ARGUMENTS
% 'num_permutations', 'num_repetitions', 'stat_method', 'paired','num_tails','pool_mode'


function [pcond, pgroup, pinter, statscond, statsgroup, statsinter, pcond_single_rep,pgroup_single_rep,pinter_single_rep, statscond_single_rep, statsgroup_single_rep, statsinter_single_rep] =...
           std_stat_corr_mean(cell_array,varargin)

        num_permutations=20;
        num_repetitions=2000;
        stat_method='bootstrap';
        paired={'off','off'};
	pool_mode='mean';
         
         for par=1:2:length(varargin)
           switch varargin{par}
               case {'num_permutations', 'num_repetitions', 'stat_method', 'paired','num_tails'}
                    if isempty(varargin{par+1})
                        continue;
                    else
                        assign(varargin{par}, varargin{par+1});
                    end
           end
        end

        pcond_single_rep=[];
        pgroup_single_rep=[];
        pinter_single_rep=[];
        statscond_single_rep=[];
        statsgroup_single_rep=[];
        statsinter_single_rep=[];
        
        %% calcolo e salvo le statistiche per ogni ripetizione
        for repetition=1:num_repetitions
            [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat_corr(cell_array,'groupstats','on','condstats','on','mcorrect','none',...
                     'threshold',NaN,'naccu',num_permutations,'method', stat_method,'paired',paired);      

            pcond_single_rep=[pcond_single_rep;pcond];
            pgroup_single_rep=[pgroup_single_rep;pgroup];
            pinter_single_rep=[pinter_single_rep;pcond];
            statscond_single_rep=[statscond_single_rep;statscond];
            statsgroup_single_rep=[statsgroup_single_rep;statsgroup];
            statsinter_single_rep=[statsinter_single_rep;pcond];

        end

%         clear pcond pgroup pinter statscond statsgroup statsinter

     if strcmp(pool_mode,mean)

	%% calcolo le medie delle matrici dentro i cell array     
        if ~isempty(pcond)
            for nc=1:length(pcond)
                pcond{nc}=cell_mean(pcond_single_rep(:,nc));
                statscond{nc}=cell_single_rep(statscond_single_rep(:,nc));
            end    
        end

        if ~isempty(pgroup)
            for ng=1:length(pgroup)
                pgroup{ng}=cell_mean(pgroup_single_rep(:,ng));
                statsgroup{ng}=cell_mean(statsgroup_single_rep(:,ng));
            end    
        end

        if ~isempty(pinter)
            for ni=1:length(pinter)
                pinter{ni}=cell_mean(pinter_single_rep(:,ni));  
                statsinter{ni}=cell_mean(statsinter_single_rep(:,ni));   

            end
        end    


else


        %% calcolo le medie delle matrici dentro i cell array     
        if ~isempty(pcond)
            for nc=1:length(pcond)
                pcond{nc}=cell_median(pcond_single_rep(:,nc));
                statscond{nc}=cell_single_rep(statscond_single_rep(:,nc));
            end    
        end

        if ~isempty(pgroup)
            for ng=1:length(pgroup)
                pgroup{ng}=cell_median(pgroup_single_rep(:,ng));
                statsgroup{ng}=cell_median(statsgroup_single_rep(:,ng));
            end    
        end

        if ~isempty(pinter)
            for ni=1:length(pinter)
                pinter{ni}=cell_median(pinter_single_rep(:,ni));  
                statsinter{ni}=cell_median(statsinter_single_rep(:,ni));   

            end
        end    
end

end

 
