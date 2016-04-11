function [pcond_corr, pgroup_corr, pinter_corr] = eeglab_study_correct_pvals(pcond, pgroup, pinter,correction)

pcond_corr        = pcond;
pgroup_corr       = pgroup;
pinter_corr       = pinter;
pinter_corr_mat   = [];

correct_pinter = not(isempty(pinter));

% if required, correct for multiple comparisons
for ind = 1:length(pcond),   pcond_corr{ind}   =  mcorrect(pcond{ind},  correction) ; end;
for ind = 1:length(pgroup),  pgroup_corr{ind}  =  mcorrect(pgroup{ind}, correction) ; end;

if correct_pinter
    for ind = 1:length(pinter),  pinter_corr{ind}  =  mcorrect(pinter{ind}, correction) ; end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORREGGO BACO INTERAZIONE

% if correct_pinter
%     for ind = 1:length(pcond)
%         pinter_corr_mat(:,:,ind) =  pcond_corr{ind};
%     end;
%     
%     for ind = 1:length(pgroup)
%         pinter_corr_mat(:,:,(ind+length(pcond))) = pgroup_corr{ind};
%     end;
%     
%     pinter_corr_m = mean(pinter_corr_mat,3);
%     pinter_corr_r = pinter_corr{3};
%     
%     p_m = pinter_corr_m < pinter_corr{3};
%     
%     pinter_corr_r(p_m) =  pinter_corr_m(p_m);
%      
%     
%     pinter_corr{3} = pinter_corr_r;
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




end