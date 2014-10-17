%% custom model
try
    load weather.mat

    model = [
        0 0 0   % intercept
        eye(3)  % main effects
        1 1 0   % x1*x2
        1 1 1 ];% x1*x2*x3

    glm   = encode( y, [ 3 3 3], model, g1, g2, g3 );

    glm.ls    = mstats(glm);
    glm.anova = anova(glm);

    load anova_test_results glm_custom;
    anova_compare( glm.anova, glm_custom.anova );
    disp('passed: anova custom model');
catch
    disp('failed: anova custom model' );
end;


%% test nested effects
% This is currently hard to set up.
% but it can be done.
% See also model_building_tutorial
try
    load nested
    glm = encode( y, 3,[ 0 0 0; eye(3); 1 0 1], outer, inner, other );
    glm.cmat(end+1,4:6) = 1;            % constrain inner(outer==1)
    glm.cmat(end+1,7:9) = 1;            % constrain inner(outer==2)
    glm.cmat(3,:)       = [];
    
    warning('off', 'linstats:anova:NotFullRank');
    glm.anova = anova(glm);
    warning('on', 'linstats:anova:NotFullRank');
    
    load anova_test_results glm_nested;
    anova_compare( glm.anova, glm_nested.anova );
    disp('passed: anova nested model');
catch
    disp('failed: anova nested model' );
end;


