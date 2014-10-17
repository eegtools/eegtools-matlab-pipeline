% FITTING
%
% Files
%   anova                - - n-way analysis of variance and analysis of covariance
%   anova_table          - builds a standard anova table 
%   boxcox               - Box-Cox procedure to evaluate the best transformation of the input
%   breusch_pagan        - constant variance tests for categorical models
%   brown_forysthe       - constant variance test for continuous x. 
%   coeff2eqn            - - text representatino of a set of equations
%   confidence_intervals - confidence interval for multiple-test correction
%   constrain            - orthogonal basis for the null space c
%   decode               - decodes a model into index dummy variables 
%   encode               - encode a linear model
%   encode_vars          - helper function for encode
%   estimates_table      - format parameter estimates into a table
%   fdr_calc             - helper function to calculate the false discovery rate from a set
%   getcontrasts         - returns a set of common constrasts. helper for lsconstrasts
%   gettests             - help function to return test matrices used by anova 
%   gmean                - - efficiently calculate group means
%   impute               - imputes missing values using least-squares predictions
%   ind2grp              - recreates factors from dummy variables and labels
%   issingular           - function [singular, k, c0, txt] = issingular( A, cmat )
%   lindc                - function b = lindc( A )
%   lmodel               - function model = lmodel(nterms,order)
%   lof                  - function t = lof( glm )
%   lscontrast           - function [lsmeans, stats] = lscontrast( glm, term, L, alpha, tail )
%   lsestimates          - function [lsm, L] = lsestimates( glm, term, response, alpha )
%   manova               - function m = manova( glm, M )
%   manova_table         - function tbl = manova_table( stats )
%   mdummy               - function [d, D] = mdummy(x, method)
%   mdummyx              - for a set of grouping indices in x, create
%   mineffect            - returns e, the smallest estimated change for each coefficient estimate
%   mm_anova             - function [stats] = anova( glm, tests, reference )
%   mmvn_expectation     - calculates an expectation that each obs belongs to  each class
%   mmvn_fit             - uses an EM algorithm to estimate parameters for a mixture of multivariate 
%   mmvn_fit_movie       - 
%   mmvn_gen             - generative process to produce a random sample of m individuals from 
%   mmvn_likelihood      - Calculates the log(likelihood ) of a mixture of mutlivariate gaussians
%   mmvn_logl_surface    - calculates the log likelihodd surface for the kth class in X
%   mmvn_maximization    - calculates current weights, means and variances
%   mmvn_pdf             - Mixture of multivariate nomral probabilities
%   model2eqn            - function s = model2eqn( model, coeff_names, delim, null_name  )
%   mstats               - function ls = mstats( glm, y, cmat )
%   solve                - function ls = solve( glm )
%   solvem               - solves a mixed effects equation 
%   sresid               - cacluates studentized residuals
%   stdrcdf              - calls matlab's stdrcdf function
%   stdrinv              - function x = stdrinv(p, v, r)
%   subtract_effect      - function [glm]  = subtract_effect( glm, terms )
%   summary              - function [s, tbl] = summary( y )
%   tests2eqn            - function source = tests2eqn( glm, tests, reference )
