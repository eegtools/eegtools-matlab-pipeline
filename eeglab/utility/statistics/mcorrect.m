function pvals = mcorrect(pvals, method);

switch method
    case 'none', return;
    case 'bonferoni', pvals = pvals*prod(size(pvals));pvals(pvals>1)=1;
    case 'holms',     [tmp ind] = sort(pvals(:)); [tmp ind2] = sort(ind); pvals(:) = pvals(:).*(prod(size(pvals))-ind2+1);pvals(pvals>1)=1;
    case 'fdr',       pvals = fdr_eeglab(pvals);pvals(pvals>1)=1;
    otherwise error(['Unknown method ''' method ''' for correction for multiple comparisons' ]);
end;  