%% three way anova  - overdetermined
try
    load weather.mat

    glm       = encode( y, 3, 2, g1, g2, g3 );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_3way_od;
    anova_compare( glm.anova, glm_3way_od.anova );

    disp('passed: 3-way anova (overdetermined)');
catch
    disp('failed: 3-way anova (overdetermined)' );
    m = lasterror;
    disp( m.message);
end;

%% 3-way nominal
try
    load weather.mat

    glm       = encode( y, 1, 2, g1, g2, g3 );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_3way_fr;
    anova_compare( glm.anova, glm_3way_fr.anova );

    disp('passed: 3-way anova (nominal)');
catch
    disp('failed: 3-way anova (nominal)' );
    m = lasterror;
    disp( m.message);
end;

%% 3-way ordinal
try
    load weather.mat

    glm       = encode( y, 2, 2, g1, g2, g3 );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_3way_ord;
    anova_compare( glm.anova, glm_3way_ord.anova );

    disp('passed: 3-way anova (ordinal)');
catch
    disp('failed: 3-way anova (ordinal)' );
    m = lasterror;
    disp( m.message);
end;

