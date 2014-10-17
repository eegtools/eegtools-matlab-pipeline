%% test analysis of covariance
% tests package functions using the carsmall example
% from mathworks;
% functions tested are encode, mstats, anova sstype II
%   encode
%       encoding models for separate lines
%       encoding models for parallel lines
%       encoding models for same line, separate means and same mean
try
    load carsmall;


    % model with separate slopes and intercepts
    % for each Model Year
    glm = encode( MPG, [3 0], 2, Model_Year, Weight );
    glm.fit = mstats( glm );
    glm.anova = anova( glm, 2);

    load anova_test_results glm_aoc;
    anova_compare( glm.anova, glm_aoc.anova );
    disp('passed: 2-way anacova (separate lines)');
catch
    disp('failed: 2-way anacova (separate lines)' );
    m = lasterror;
    disp( m.message);
end;



try
    load carsmall;


    % model with separate intercept for each Model_Year
    glm = encode( MPG, [3 0], 1, Model_Year, Weight );
    glm.fit = mstats( glm );
    glm.anova = anova( glm, 2);

    load anova_test_results glm_aoc_si;
    anova_compare( glm.anova, glm_aoc_si.anova );
    disp('passed: 2-way anacova (parallel lines)');
catch
    disp('failed: 2-way anacova (parallel lines)' );
    m = lasterror;
    disp( m.message);
end;

try
    load carsmall;

    % model with same line all Model_Years
    % this can be thought of as leaving out Model_year altogether
    glm = encode( MPG, 0, 1, Weight ); 
    glm.anova = anova(glm);
    
    % or building a custom model that doesn't use model_year
    glm2 = encode( MPG, [3 0], [0 0; 0 1], Model_Year, Weight );
    glm2.anova = anova(glm2);
    
    anova_compare( glm.anova, glm2.anova);
    
    load anova_test_results glm_aoc_sl;
    anova_compare( glm.anova, glm_aoc_sl.anova );
    disp('passed: 2-way anacova (same line)');
catch
    disp('failed: 2-way anacova (same line)' );
    m = lasterror;
    disp( m.message);
end;


try
    load carsmall;

    % model with no slopes and separate intercepts
    % this can be thought of as leaving out Weight
    % which is a standard anova
    glm = encode( MPG, 3, 1, Model_Year ); 
    glm.anova = anova(glm);
    
    % or building a custom model that doesn't use Weight
    % which is also a standard anova
    glm2 = encode( MPG, [3 0], [0 0; 1 0], Model_Year, Weight );
    glm2.anova = anova(glm2);
    
    anova_compare( glm.anova, glm2.anova);
    
    % this is just a one way anova that was previously tested
    
    disp('passed: 2-way anacova (separate means)');
catch
    disp('failed: 2-way anacova (separate means)' );
    m = lasterror;
    disp( m.message);
end;


load carsmall;

% model with a single mean
glm = encode( MPG );
glm.ls = solve(glm);

if ( glm.ls.beta == mean(glm.y) )
    disp('passed: 2-way anacova (single mean)');
else
    disp('passed: 2-way anacova (single mean)');
end;


