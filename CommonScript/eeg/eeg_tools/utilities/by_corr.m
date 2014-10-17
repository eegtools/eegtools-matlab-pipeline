function pcorr = by_corr(start_p, ncomp)
    somma=0; 
    for cnt=1:ncomp
        somma = somma + 1/cnt;
    end
    pcorr=start_p/somma;
end