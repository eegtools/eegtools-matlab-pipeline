try
%one way anova

load alloy

glm       = encode( strength, [], [], alloy );
glm.ls    = mstats(glm);
glm.anova = anova(glm);

load anova_test_results glm_1way;
anova_compare( glm.anova, glm_1way.anova );

    disp('passed: 1-way anova');
catch
    disp('failed:1-way anova' );
end;