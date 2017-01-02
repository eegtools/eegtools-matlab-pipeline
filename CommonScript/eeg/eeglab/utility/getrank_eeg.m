function tmprank_eeg = getrank_eeg(tmpdata_eeg)

tmprank = rank(tmpdata_eeg);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here: alternate computation of the rank by Sven Hoffman
%tmprank = rank(tmpdata(:,1:min(3000, size(tmpdata,2)))); old code
covarianceMatrix = cov(tmpdata_eeg', 1);
[E, D] = eig (covarianceMatrix);
rankTolerance = 1e-7;
tmprank_eeg=sum (diag (D) > rankTolerance);
if tmprank ~= tmprank_eeg
    fprintf('Warning: fixing rank computation inconsistency (%d vs %d) most likely because running under Linux 64-bit Matlab\n', tmprank, tmprank_eeg);
    tmprank_eeg = min(tmprank, tmprank_eeg);
end;