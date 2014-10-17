%% hypothesis testing tutorial
% this tutorial will go over some of the functions available for making
% inferences and testing hypothesis.
% I assume that you know how to construct a model using encode. If not see
% the model_building tutorial. Before using a model to test hypothesis, it
% is a good idea to make sure the model is reasonable. 
% See also model_validation_tutorial 
% See also model_building tutorial 

%% testing parameter estimates
% a common question people pose is whether there is a relationship between
% a preditor variable and a response variable. For example, in the
% following plot horsepower of several different cars is plotted against
% displacement. As is apparent from the data horsepower generally goes up
% as displacement goes up. If there were no relationship then the
% horsepower would be random with respect to displacement and there would
% be no slope. We can conduct a formal test of the hypothesis that there is
% no slope using mstats mstats does several tests. This is done by testing
% whether the slope parameter is different from zero. Here we will focus on
% the tests done on the estimates for the slope.
% The estimated relationship is shown in the figure along with a table
% The values in each row correpond to one of the coefficients in the model.
% The row called displacement refers to the coefficient that is multiplied
% by the value of displacement. In this case the estimated coefficient, in
% the column called bhat is .3706. If the assumptions of the model are
% valid, this is an unbiased estimate of the coefficient. This means that
% the expected value of beta is equal to the estimate.
% The second column is the standard error of the estimate. This value is
% useful if we want to do our own tests or create our own confidence
% intervals. The next column, ci, is the 95% confidence limits, under the
% assumptions of our testing. This means that if we can be 95% sure that 
% the actual slope falls inside the limits of .3706 +/- .00333. 
% The next two columns in the table is the t-value and associated pval at
% n-1 degrees of freedom. This is a test that beta is the same as zero. We
% can be very sure that .3706 is different than 0, since the pval is very 
% small 

load carsmall
clf
a1 = subplot(2,1,1);
set(a1,'pos', [0.13 0.44048 0.775 0.48452]);
plot(Displacement, Horsepower,'.');
xlabel('displacement');
ylabel('horsepower');
% encode Displacement as continuous
glm = encode( Horsepower, 0, 1, Displacement );
% solve and get stats
stats = mstats(glm);
% plot ls line
h = refline( stats.beta(2), stats.beta(1) );
set(h,'linestyle', '-.', 'color','k');

% make a table and display on graph
tbl = table( {'stat', 'bhat', 'se', 'ci', 't' 'pval'}, stats.source, ...
              [stats.beta stats.se stats.ci stats.t stats.pval] );
a2 = axes;
plot_table(tbl);
set(a2, 'pos', [0.042857 0.050476 0.91071 0.34116], ...
       'box', 'off', ...
       'ycolor', get(gcf,'color'), ...
       'xcolor', get(gcf,'color'), ...
       'color', 'none' );
       
%% Testing qualitative parameter estimates
% here will do a similar test but instead of treating displacement as a
% continous variable will divide it into three groups of low, medim and
% high displacement and use an ordinal model to test the hypothesis that
% there is no relationship between displacement and horsepower at each
% level compared to the next lower level. In the table the source is listed
% as intercept, 2-1 and 3-2. I've used numbers to indicate low medium and
% high in the model so that 1=low, 2=med and 3=high. bhat for the intercept
% is interpretted similarly to before, but the other two are relative to
% other levels. For example 2-1 tests wether the difference between medium
% and low displacement is 0. Since the p-value is small we can reject that
% hypothesis.
clf;

% divide the displacemnt into three groups
[n,bidx] = histc( Displacement, [0 150 300 500] );
bn = {'low', 'med', 'high'};
displacement = bn(bidx)';

% encode an ordinal model. In an ordinal model each level is compared to
% the next level down. Thus there is a natural order to the levels as is
% the case here with displacement. By using numbers to indicate the levels
% of displacement we control the relative order of the levels. If they are
% cell array of strings, then the order of appearance in the list
% determines the order of the levels.
glm = encode( Horsepower, 2, 1, bidx );

% plot the results
a1 = subplot(2,1,1);
set(a1,'pos', [0.13 0.44048 0.775 0.48452]);
[l,lh] = mscatter( bidx(~glm.missing), glm.y, displacement(~glm.missing) );
set( gca, 'xtick', 1:3, 'xticklabel', bn );
set( lh(1), 'location', 'northwest', 'xticklabel', 'displacement');

a2 = axes;
tbl = estimates_table( mstats(glm) );   % solve and build standard table
plot_table(tbl);                        % plot table to figure window
set(a2, 'pos', [0.042857 0.050476 0.91071 0.34116], ...
       'box', 'off', ...
       'ycolor', get(gcf,'color'), ...
       'xcolor', get(gcf,'color'), ...
       'color', 'none' );

%% Testing qualitative parameters using ANOVA
% here we will encode our categorical displacement levels into
% overdetermined form by setting the second input parameter of encode to 3.
% In this case we are testing whether all three levels of displacment are
% equal. The table is a standard anova table. The source indicates which
% variables are being tested. Linstats uses a comprehensive description for
% source so that you can see exactly what is being tested. For more
% information on reading source see the help for tests2eqn. In this case
% there is only one variable. the source is bidx (the binned displacement
% variable) given that the intercept is in the model. The test compares how
% much variability is reduced by adding bidx to a model that already
% contains an intercept. (a model with only an intercept is sometimes
% called the null model).
% The second column is the Sum Squares of the regression. This is the
% between group variation or the amount of variation explained by adding 
% the variable. 
% The third column is the degrees of freedom associated with that variable.
% It is typically the number of levels-1. 
% The column labeled ms is the mean square error for the term. This is the
% ANOVA equivalent of variance between groups. 
% F is Fisher's F statistic. Like many great statisticians Fisher was not a
% statistian, but rather a geneticist. The F ratio is the between group
% variance divided by the within group variance. The within group variance
% details are shown in the next row.
% The p-val is the probability that the given F value with the associated
% degrees of freedom could have occurred by chance if all levels were equal
% The row with source equal to 'error' is the model error. The F ratio is
% the within group error. the columns have the same meaning as before but
% there is no F statistic or test for the model error
% The row with 'total' in the source is the total error. 
clf
glm = encode( Horsepower, 3, 1, bidx );

% run the anova
a   = anova(glm);

% plot the results
a1 = subplot(2,1,1);
set(a1,'pos', [0.13 0.44048 0.775 0.48452]);
[l,lh] = mscatter( bidx(~glm.missing), glm.y, displacement(~glm.missing) );
set( gca, 'xtick', 1:3, 'xticklabel', bn );
set( lh(1), 'location', 'northwest', 'xticklabel', 'displacement');

a2 = axes;
tbl = anova_table(a);         % standard format table
plot_table( tbl);               % plot it to figure window
set(a2, 'pos', [0.042857 0.050476 0.91071 0.34116], ...
       'box', 'off', ...
       'ycolor', get(gcf,'color'), ...
       'xcolor', get(gcf,'color'), ...
       'color', 'none' );
   
%% Contrasts
% After having run the anova using overdetermined for we may be interested
% in asking whether one level is higher than another level. This is called
% a contrast. As we did in the ordinal form we will ask about the effect
% that adjacent levels of "displacement" have on Horsepower. Specifically,
% we will test each one to see whether it is equal to the adjacent one. The
% table below shows the results. You will notice that the results are
% identical to the ones above for the ordinal model. In other words testing
% the coefficients in an ordinal model is equivalent to contrasting
% adjacent levels in an overdetermined model.
clf

% build model as befoer
glm = encode( Horsepower, 3, 1, bidx );

% run the anova
a   = anova(glm);

% The anova returned a field called beta which is the parameter estimates
% for each term in the model. Here we are interested in finding and
% comparing the estimates associated with the first variable. 
% the model, glm, has two fields that describe the coefficients and map
% them to the estimates, coeff_names and terms. 
% for the first variable they are accessed like this
var_number = 1; % for the first variable
table( {'name', 'value'}, ...
             glm.coeff_names( glm.terms== var_number ), ...
             a.beta( glm.terms==1) );
         
 % Here we will compare the first displacement, low, to the 2nd
 % displacment, med; and the 2nd to the 3rd
 %
 
 % To see how this is done, it is useful to look at the output of 
 % getcontrasts, which is called by lscontrasts. It builds common forms of
 % contrasts such as all pairwise, adjacent pairs and comparisons to
 % baseline
 L = getcontrasts( 3, 2 );  % compare adjacent levels
 
 % we don't need to call getcontrasts, because ls contrasts would does it for
 % us, but lsconstrasts can also take a matrix of contrasts that we can use
 % to build custom constrasts.
 [lsmeans, stats] = lscontrast( glm, 1, L );
 
 plot_table(estimates_table( stats) ); 
 set( gcf, 'pos', [ 360   502   680   450]);
 
%% ANOVA (n-way)
% n-way anova is when then there is more than one explanatory variable to
% consider. Building these models is very similiar to previous models. For
% example, say we want to test the effects of three factors on temperature.
% We have three factors, g1, g2, and g3 and we will start with a simple
% model considering only main effects. As you can see from the table below,
% factor 2 appears to have a significant effect on temperature. 
load weather

glm = encode( y, 3, 1, g1, g2, g3);     %1st degree
a   = anova( glm);
plot_table( anova_table( a ) );

%% ANOVA (n-way with interactions)
% For this will reuse the weather example and this time include full
% factorial design, which considers all possible interactions up to 3-way.
% This result is considerable different from before. Now the factor g1 
% appears to be signficant. You also notice that g1*g2 interaction is
% significant. An interaction effect can greatly complicate the
% interpretation of an ANOVA. When you see one you can investigate the
% interactino using iplot. 
load weather

glm = encode( y, 3, 3, g1, g2, g3);     % 3rd degree
a   = anova( glm);                      % ss III anova
% I could plot this directly but I want to make the 
% information about the source of error a little shorter
a.source = regexprep( a.source, '\|.*$', '' );
plot_table( anova_table( a ) );




%% Visualize interactions
% we found the g1 and g2 had signficant interactions. Lets take a look at
% this using an interaction plot. This shows the least squares means of the
% the relevant interactions. In this plot you will see that the 2nd level
% of g1 can have a positive or negative effect on the temperature depending
% on the level of g2. If there were no interaction between g1 and g2 the
% lines in this plot would be roughly parallel
% See also model_validation_tutorial to get one idea of how to interpret
% interactions. 
[lsq h lh] = iplot( glm, [ 1 2 ] ); 
set(lh,'location', 'northwest', 'xticklabel', 'g2' );

newplot
iplot( glm, [1 2] );


%% Multiple Tests
% if there are more than one comparison being made then
% you may want protection against multiple-tests. Simply put, if you do
% twenty tests each at a p-value threshold of 0.05 then you shouldn't be
% surprised to find 1 of these occuring by chance. You can correct for
% multiple tests in a variety of ways. In linstats the function is called
% confidence_intervals
% There are several ways to do multiple test correction and which one you
% choose depends on what you are trying to do. 
%    minimum ci from all tests (except t-test)
%    Scheffe        for general contrast of factor level means. It is always
%                   conservative. You are allowed to take min of Scheffe
%                   and Bonferonni and you will still be conservative
%    Dunn-Sidak     
%    Bonferonni     always conservative
%    Tukey-Kramer   can be used for pairwise data-snooping
%    t-test         aka least signficant difference - not a correction
%                   for multiple tests
% the confidence intervals can be used when plotting to give a visual
% representation of the certainty of a particular estimate or comparison

% fixed effects 2 way anova with interactions
load popcorn;

glm       = encode( y, [3 3], 2, cols, rows );
[u stats] = lscontrast(glm,1,-getcontrasts(3,1));
[ci names]= confidence_intervals( stats.se, stats.dfe, stats.dfr );

% build a table
tbl = table( ['source' names], stats.source, ci )';
figure
plot_table(tbl);
[x,y] = getAxisInset( .1, .90 );
pos = [360   502   670   420];
set( gcf,'pos', pos );
text(x,y, 'Table of confidence intervals', 'fontsize', 14,'fontweight', 'bold');

figure
ls = lsestimates( glm, 1 );
columns = glm.level_names{1};
ciplot( 1:3, ls.beta, ci(:,1)/2, columns );
set( gca, 'xtick', 1:3, 'xticklabel', columns );


%% Sequential tests
% An anova is simple a set of comparisons of different models. The tests
% are whether a given model explains signficantly more variation than
% another model. By default anova uses a set of tests called sum squares
% type III. Some people prefer to use type I tests, which are also called
% sequential tests. The anova function in linstats supports these as well
% as type II and also supports custom tests. The table shows the results of
% the anova. First lets deal with the monstrous 'source' column.  The
% terms before the '|' are added to a model that already contains the terms
% to the right of the '|'. The first row tests the effect of g1 given that
% the intercept is in the model. the second row tests the effect of g2
% given that g1 is in the model the 3rd tow tests the effect of g3 given
% that both g1 and g2 are in the model and so on. Each term is added one at
% a time so the effects are tested sequentially. If you compare the
% results of this table to the SS type III table you will notice that g3
% has a signficant effect in this test whereas it did not before. This
% should tell you how important it is to understand exactly what you are
% testing when you run an anova. The reason for the difference is that in
% the ss type III there are signficant interaction terms already in the
% model and the addition of g3 does not explain much more variability.
% Without these interaction terms in the model adding g3 can explain some
% of the variation. 
load weather
glm = encode( y, 3, 3, g1, g2, g3 );    % same model as before

% 2nd input to anova says which tests to do
% it can be a scalar for type 1,2 or 3 or a matrix for custom tests. Custom
% tests will be covered below
a   = anova( glm, 1 );       
a.source = regexprep( a.source, '\(.*\)', '' );
plot_table( anova_table( a ) );
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );


%% SS type II
% SS type II is also called higher terms omitted. The reason it gets this
% name is that the main effects are considered without their associated 
% interaction terms. then the second degree interaction terms are
% considered without their associated higher degree interaction terms. 
% running a ss type II is analagous to what we've seen before. the difference is that
% the second parameter to anova is a 2. 
% As you can see in the table. The results are different that either the
% type I or type III SS. This is expected whenever the design is unbalanced
% (a balanced design produces the same results for all 3 types of tests).
% As I mentioned above, testing g3 in the presence of the g1*g2 terms makes
% the contribution of g3 insignificant. 
load weather
glm = encode( y, 3, 3, g1, g2, g3 );    % same model as before

% 2nd input to anova says which tests to do
% it can be a scalar for type 1,2 or 3 or a matrix for custom tests. Custom
% tests will be covered below
a   = anova( glm, 2 );       
a.source = regexprep( a.source, '\(.*\)', '' );
plot_table( anova_table( a ) );
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );

%% Introduction to Custom Tests
% you can create custom tests if you want to see the effect of more than
% one term to the model has. 
% To do this you need to understand the test matrix. 
% A test matrix describes whichi terms to include and exclude from the
% current model. Each row of the test matrix describes a different model.
% There is also a reference vector. The ith element of the vector is
% associated with the ith row in the current model. the value of the ither
% element indicates which model# to compare to the ith model.
% The table shows an example using type I sums of squares. 
% The column header indicates which term the column refers to. 
% The first row of the test matrix consists of all 1s. A 1 under any terms
% means that it should EXCLUDED from the model. so the model #1 contains
% only the intercept term. The reference column says that model #1 should
% be compared to model #2. Model #2 has 1s everywhere except under g1. Thus
% g1 should be included in Model #2. If we compare models #1 and #2 we are
% testing the effect of adding g1 to a model that has only the intercept. 
load weather
glm = encode( y, 3, 3, g1, g2, g3 );    % same model as before

% there is a utility to generate common tests (ss type 1,2, and 3)
[tests, reference] = gettests( glm, 1 );
term = model2eqn( glm.model, glm.var_names);
term(1) = [];
tbl = table( ['model #' 'ref', term'], 1:8, [ reference nan], tests );
plot_table(tbl);
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );

%% Building a Custom Test
% as an example lets tests the effect of adding g3 and all associated 
% interaction terms to a model that contains everything else. 
% We will also test adding g1, g2 and g1*g2 to a model with only the
% intercept for comparison. Odd tests perhaps, but you can see that
% dropping all things related to g3 from the model does not significantly
% effect the fit. Based on this it might be worth considering eliminating
% g3 from the model
load weather
glm = encode( y, 3, 3, g1, g2, g3 );    % same model as before

i = glm.model(2:end,3)==1;    % find all terms with g3 in them

tests = zeros( 3, 7 );          % three full models
tests(1,i) = 1;                 % model#1 drops g3 and interactions
tests(2,~i) = 1;                % model#2 drops all but g3 and interactions
reference = [3 3];              % compare model#1 and #2 to model#3

a = anova(glm, tests, reference );
plot_table(anova_table(a));
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );

%% ANACOVA (1-way)
% an anacova model is similar to an anova model, but also include a
% continuos variable. The reason it is often treated separately may be
% because the interpretation of the parameter estimates is complicated. In
% a standard anova it makes sense to ask for the mean reponse of a
% particular level. In an anacova this is more difficult because the mean
% reponse takes on different values depending on the covariate.
% We will use the carsmall example to illustrate ANACOVA
% The figure shows a scatter plot of Weight versus MPG stratified by model
% year. Below the figure is a table showing the parameter estimates and
% a test of whether they are equal to zero. This table shows that the
% intercept is not zero. Also the model years are all different from 0.
% which means that they differ from the intercept. 
% The Weight term is the overall slope, which is different from zero. 
% The other slope terms are offsets from the overall slope. The test for
% these is whether they differ from the overall slope. 
% the second table is a ssytpe II anova test for the effects Model_year,
% Weight and Model_year*Weight, all of these effects are significant.
% The null hypothesis here is whether the levels are all equal. 
figure
load carsmall;
ModelYear = Model_Year; % makes displays prettier (could also shut off text interpreter)
[h lh]= mscatter( Weight, MPG, ModelYear, ModelYear );
delete(lh(2));
h = refline;
set(h,'linestyle', ':');

glm = encode( MPG, [3 0], 2, ModelYear, Weight );
figure
plot_table( estimates_table( mstats(glm ) ));
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );

figure
plot_table(anova_table( anova( glm, 2) ));
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );

%% ANACOVA (n-way)
% This shows that setting up a n-way anacova is the same as setting up an
% anova. When SAS/JMP does this they center the numeric continuous
% variables. you can get a similar effect using the -1 encoding. Although
% this isn't quite the way SAS/JMP does the centering. 
figure
load carsmall;
i = Cylinders < 8;
ModelYear = Model_Year(i); % makes displays prettier (could also shut off text interpreter)
Cylinders = Cylinders(i);
Weight    = Weight(i);
MPG       = MPG(i);
[h lh]    = mscatter( Weight, MPG, ModelYear, Cylinders );
set(lh(2),'location', 'east');

glm = encode(MPG, [ 3 3 -1], 2, ModelYear, Cylinders, Weight );

figure
a = anova( glm, 2);
a.source = regexprep( a.source, '\|.*$', '' );
plot_table(anova_table( a ));
set( gca, 'pos', [0, 0, 1, 1] )
pos = get( gcf, 'pos');
pos(3:4) = [680, 450];
set( gcf, 'pos', pos );
















