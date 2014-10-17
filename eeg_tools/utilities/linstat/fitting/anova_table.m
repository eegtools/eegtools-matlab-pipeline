function [tbl a] = anova_table(a, i, source_name )
% ANOVA_TABLE  builds a standard anova table 
%
% Example
%       load popcorn
%       glm       = encode( y, 3, 2, cols, rows );    % build linear model
%       a         = anova(glm);                       % sstype 3 anova tests
%       tbl       = anova_table(a)        % standard anova report
%       % returns a cell array tbl with the anova results in a, which is
%       the results from anova. If a has more than one response variable,
%       the results from the first are shown
%
%       tbl       = anova_table(a,2) 
%       % standard results table for the 2nd response variable. 
%
%       tbl       = anova_table(a, [], sourcenames )
%       % sourcenames is a cell array of strings or a scalar. If is cell array there
%       must be one element for each test in the anova results. If it is a
%       scalar = 1, then the default names given in a.source are
%       abbreviated
%       
%       [tbl a]  = anova_table( anova(glm), ...);
%       the second output argument is the first input argument. This style
%       was added to support the above syntax in one line, rather than two
%       steps as in example 1.
%         
% See also
%       anova, tests2eqn, plot_table, export, jplot_table

% $Id: anova_table.m,v 1.6 2006/12/26 22:53:12 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2 || isempty(i)
    i = 1;
end;

if nargin < 3
    source = [a.source; 'error'; 'total' ];
elseif iscell(source_name)
    source = [source_name; 'error'; 'total' ];
elseif source_name == 1
    source = [ regexprep( a.source, '\|.*$', '' );
               'error'; 'total'];
end;

ss  = cellstr(num2str( [a.ss(:,i); a.sse(i); a.sst(i)], '%10.6f'));
mss = [cellstr(num2str( [a.mss(:,i); a.mse(i)], '%9.6f')); ' '];
f   = [cellstr(num2str( a.ftest(:,i), '%7.4f')); ' '; ' '];
df  = [a.df a.dfe a.dft];
% round off pvals
r = a.pval(:,i)<0.0001;
p = [cellstr(num2str(a.pval(:,i),'%8.4f')); ' '; ' '];
p(r) = {'<0.0001'};

tbl =  table( {'source', 'ss', 'df', 'ms', 'f', 'p>f'}, ...
                source,   ss ,  df ,  mss,  f ,  p );
               

