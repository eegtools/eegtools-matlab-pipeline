%% Disclaimer
% This software is offered as is with no warranty expressed or implied. 

%% What Is Linstats
% Linstats is a toolbox for building, testing and making statistical
% inferences from linear models. There are many features in this toolobx
% that are not available in the matlab statistical toolbox including n-way
% ANACOVA and n-way MANOVA as well numerous diagnostic plots. There is also
% support multiple responses and linstats efficiently supports fiting
% models with up to 100s of thousands of responses. All the features share
% a unified model building approach. 

%% Whats new 
% mixture of multivariate normal toolkits
% many new examples for every major function 
% many new functions for plotting, fitting models and for data manipulation

%% Getting Started With Linstats
% Unizip linstats.zip into a working directory. There should be four
% subdirectories. IN each of these is a readme files that document the 
% purpose of each .m file. Additional documentation can be obtained by
% typing help "function_name" at the Matlab prompt 
% 
% I've include some tutorials to illustrate the major 
% functionality of linstats
%
% How to use the mixture of multivariate normal toolkit
% <tutorials\html\mmvn_tutorial.html>	 
% 
% how to use encode to build a linear model
% <tutorials\html\model_building_tutorial.html> 
%
% how to perform statistical inference on your model
% <tutorials\html\model_inference_tutorial.html> 
%
% how to test your model
% <tutorials\html\model_validation_tutorial.html>	    
%


%% Requirements
% Linstats requires the statistical toolbox for complete functionality.
% Model building is still present and useful in combination with core
% matlab functions such as lscov
% Alternatively, if you have Satbox4.2, available from the matlab file 
% exchange server you can get most of the statistical inference functions
% See the section below for Statbox users

%% Installation
% Unzip the file and move the contents into a directory of your choice. Add
% the subdirectories to the top of your matlab path. Your done. 
%
% Linstats has been tested using a series of unit_tests provided with
% this package. The unit tests are designed to demonstrate that
% major program functionality is working correctly. 
% Each test compares results from a current run against previously saved
% hand-checked answers. The tests are run before any release, and any
% applicable bug reports are incorporated into the tests so that once
% irradicated they do not return. 
% 
% To run the tests just type unit_tests at the prompt. You should see a
% series of messages saying passed: testname. If you see any warnings or
% errors then something has gone wrong. Try moving linstats to the top of
% your matlab path. 
%
%% Statbox Users
%   Linstats has been unit tested using Statbox. if you have statbox, you
%   can use its probability and cumulative density function routines to
%   substitute for Matlab's toolbox. There are 4 files in the fitting
%   subdirectory that wrap Statbox density functions. these files all end
%   in '.statbox' Remove the '.statbox' suffix from these files and make
%   sure statbox is in your matlab path. Most linstats functionality should
%   now be available.


%% Integration with Other Toolboxes
% Linstats is modular in design and it exposes many of its
% inner workings though publically available functions and data structures.
% This allows more flexibility in building and testing models and will
% allow easier integration with other packages including some in matlab and
% others available on the file-exchange (e.g. mixed.m, ffmanova.m). For
% example the design matrix from a full-rank model can be used in a call to
% regstats. Alternatively the design matrix can be easily split into fixed
% and random submatrices and used in mixed.m. 
% 


%% References
% Major sources of information include
%
% Applied Linear Satistical Models (5th Edition). Kutner, Nachtsheim, Neter
% and Li. 
%
% Multivariate Analysis (2003). Mardia, Kent and Bibby. 
%
% JMP v5.1 documentation. JMP is a registered trademarks of SAS Institute
%
% Matlab v7 documentation


%% Unit tests 
% these are used for regression testing whenever a change is made to the
% core statistical routines if you enounter a bug that produces a wrong
% answer or a model that doesn't build correctly, a test for it will be
% inserted into one of these files and it will always be tested for after
% every change 

% unit_tests.m	% runs the whole set of unit_tests
% test_1way.m
% test_2way.m
% test_3way.m
% test_aoc.m
% test_custom.m
% test_estimates.m
% test_plots.m
% test_singularity.m
% test_sphericity.m
% test_table.m
% test_tests.m
% test_two.m
% 
% test_vtable.m
% vtest_plots.m
% 
% data_sources.m		description of the example data in this directory
% 
% % used in the tutorials
% reflines.m
% rotate2d.m	 



