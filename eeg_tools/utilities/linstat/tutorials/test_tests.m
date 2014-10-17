%% sums of squares tests
% the functions anova and gettests are tested using
% weather examples
% ss type 1. overdetermined encoding, 2 way anova 2nd order
% ss type 2. overdetermined encoding, 2 way anova 2nd order
% ss type 3 is tested in other unit tests
try
    load weather.mat

    glm   = encode( y, [ 3 3 3], 2, g1, g2, g3 );

    %% sstype 1
    glm.anova = anova(glm, 1);
    
    load anova_test_results glm_ss1;
    anova_compare( glm.anova, glm_ss1.anova );

    disp('passed: ss type I anova (overdetermined)');
catch
    disp('failed: ss type I anova (overdetermined)' );
    m = lasterror;
    disp( m.message);
end;

%% sstype 2
try
    load weather.mat

    glm   = encode( y, [ 3 3 3], 2, g1, g2, g3 );

    %% sstype 2
    glm.anova = anova(glm, 2);
    
    load anova_test_results glm_ss2;
    anova_compare( glm.anova, glm_ss2.anova );

    disp('passed: ss type II anova (overdetermined)');
catch
    disp('failed: ss type II anova (overdetermined)' );
    m = lasterror;
    disp( m.message);
end;

