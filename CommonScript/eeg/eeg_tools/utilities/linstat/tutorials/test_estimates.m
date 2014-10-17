%% tests parameters, least-squares means and confidence intervals
%
% ANACOVA models are supported, but I can't reproduce the SAS/JMP
% se (or ci, which depend on se) calculations. This is probably
% because SAS/JMP sets continuous variables to a neutral value
% in a way I don't understand. 

try
    % fixed effects 2 way anova with interactions
    load popcorn;

    glm   = encode( y, [3 3], 2, cols, rows );
    glm.stats = lsestimates(glm);

    load anova_test_results glm_est;
    stats_compare( glm.stats, glm_est.stats );

    disp('passed: lsestimates');
catch
    disp('failed: lsestimates' );
    m = lasterror;
    disp( m.message);
end;

%% confidence intervals

try
    % fixed effects 2 way anova with interactions
    load popcorn;

    glm       = encode( y, [3 3], 2, cols, rows );
    [u stats] = lscontrast(glm,1);  

    glm.ci = confidence_intervals( stats.se, stats.dfe, stats.dfr );
    
    load anova_test_results glm_ci;
    
    if ~mat_compare( glm.ci, glm_ci.ci)
        error( 'linstats:anova_compare:beta', 'error in bhat' );
    end;

    disp('passed: confidence_intervals');
catch
    disp('failed: confidence_intervals' );
    m = lasterror;
    disp( m.message);
end;



%% least-squares contrasts with unbalanced 2-way anova with
% 2nd degree interactions
try
    load popcorn;

    glm        = encode( y, [3 3], 2, cols, rows );
    [m,glm.stats]  = lscontrast( glm, 1 );

    load anova_test_results glm_contrast;
    stats_compare( glm.stats, glm_contrast.stats );

    % [P,T,S,M] = anovan( y, {cols, rows}, 'model', 2, 'sstype', 3, 'display', 'off' );
    % [c1] = multcompare(S,'ctype', 'lsd', 'disp','off' );
    disp('passed: lscontrast');
catch
    disp('failed: lscontrast' );
    m = lasterror;
    disp( m.message);
end;



