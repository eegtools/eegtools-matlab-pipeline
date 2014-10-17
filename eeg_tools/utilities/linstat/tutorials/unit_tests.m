% UNIT_TESTS master script to run through all unit tests
%
% these are designed to test the overall function of the package and to
% show how to use some functions in comparison to equivalent matlab and/or
% SAS/JMP functions


% anova
test_1way
test_2way
test_3way

%building custom linear models
test_custom

% anacova
test_aoc

% test least-squares estimates
test_estimates

%tests the detection and reporting of singularities
test_singularity

% test other types of anova tests (e.g. ssI, ssII, custom
test_tests

% manova
test_manova



