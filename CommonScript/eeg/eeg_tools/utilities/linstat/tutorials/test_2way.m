% requires popcorn example from matlab

%% two way anova  - overdetermined
try
    load popcorn;
    y(1) = nan;

    glm       = encode( y, 3, 2, cols, rows );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_2way_od;
    anova_compare( glm.anova, glm_2way_od.anova );

    disp('passed: 2-way anova (overdetermined)');
catch
    disp('failed: 2-way anova (overdetermined)' );
    m = lasterror;
    disp( m.message);
end;

%% two way anova  - full-rank encoding 0/1
try
    load popcorn;
    y(1) = nan;
    glm       = encode( y, 1, 2, cols, rows );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_2way_fr;
    anova_compare( glm.anova, glm_2way_fr.anova );

    disp('passed: 2-way anova (nominal)');
catch
    disp('failed: 2-way anova (nominal)' );
    m = lasterror;
    disp( m.message);
end;

%% two way anova  - orginal encoding 
% the tests here are equivalent to the ordinal encoding
% of jmp.
try
    load popcorn;
    y(1) = nan;

    glm       = encode( y, 2, 2, cols, rows );
    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_2way_ord;    
    anova_compare( glm.anova, glm_2way_ord.anova );


    disp('passed: 2-way anova (ordinal)');
catch
    disp('failed: 2-way anova (ordinal)' );
    m = lasterror;
    disp( m.message);
end;
