function tbl = manova_table( stats, term )
%MANOVA_TABLE output results from a manova
% tbl = manova_table( stats, term )
%
% STATS is the results from manova
%
% TERM is a integer specifies which model term should be displayed
%
% TBL is a table showing 4 tests of the manova model
%
%Example:
% load carbig;        % load data
% X = [MPG Acceleration Weight Displacement];  % response variables
% glm = encode( X, 3, 1, Origin );         % Origin is explanatory variable
% m   = manova( glm );                       % manova   
% plot_table( manova_table(m) );
% title( 'Origin');

% $Id: manova_table.m,v 1.3 2006/12/26 22:53:18 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 2
    term = 1;
end;

tbl = table(stats.col_names,     ...
            stats.test_names,    ...
            stats.value(:,term), ...
            stats.F(:,term),     ...
            stats.dfr(:,term),   ...
            stats.dfe(:,term),   ...
            stats.pval(:,term));

