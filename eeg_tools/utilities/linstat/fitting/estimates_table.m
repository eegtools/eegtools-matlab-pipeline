function [tbl a] = estimates_table(a, response, source_names )
%ESTIMATES_TABLE format parameter estimates into a table
%
%Example
%   display estimated parameters for a model
%   load carbig
%   glm = encode( Acceleration, 3,1, Cylinders );
%   tbl = estimates_table( mstats(glm) )
%   jplot_table( tbl );
%
%Example
%   multiple response (continued from above)
%   glm = encode( [Acceleration, MPG], 3, 1, Cylinders );
%   tbl = estimates_table(mstats(glm), 2 ); % tbl for 2nd response (MPG)
%   plot_table(tbl);
%

% $Id: estimates_table.m,v 1.10 2006/12/26 22:53:14 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

if ( nargin <2 || isempty(response) )
    i = 1;
else
    i = response;
end;

beta = cellstr(num2str( a.beta(:,i), '%10.6f'));
se   = cellstr(num2str( a.se(:,i), '%10.6f'));
ci   = cellstr(num2str( a.ci(:,i), '%8.4f'));
t    = cellstr(num2str( a.t(:,i), ' %8.4f'));

% round off pvals
r = a.pval(:,i)<0.0001;
p = cellstr(num2str(a.pval(:,i),'%8.4f'));
p(r) = {'<0.0001'};



if nargin < 3
    source = a.source;
elseif iscell(source_names)
    source = source_names;
elseif source_names == 1
    source = regexprep( a.source, '\|.*$', '' );
end;


tbl = table({'source', 'bhat', 'se', 'ci', 't', 'Prob>t'}, ...
             source, beta, se, ci, t, p );



    