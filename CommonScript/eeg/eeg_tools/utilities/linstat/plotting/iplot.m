function [lsq, h, lh] = iplot( glm, terms, response )
%IPLOT interaction plot
% 
% interaction plot
% plots the lsmeans estimates for the given interaction terms in the model
% along with 95% lsd confidence intervals. lsmeans are the estimated
% response at each particular combination of factor levels. 
% Interaction plots are intended to show graphically whether
% there is a signficiant interaction between the factors in a fixed effects
% model. If there is an interaction, it can make interpretting the primary
% effects difficult. Also keep in mind that interpretting lsmeans in a
% model with continuous variables is complicated: at which level of the
% continous variable should the mean response be estimated? 
%
% [lsq, h, lh] = iplot( glm, terms, response )
%   GLM is a linear model created using encode
%   TERMS are the terms for which an interaction plot is created
%   RESPONSE is selection which response variable of glm to plot (when
%   there are multiple responses);
% Returns
%   LSQ the results from lsestimates(glm)
%   H   a handle to the plot
%   LH  handles to the legends
%
% Example
%      load popcorn
%      glm       = encode( y, 3, 2, cols, rows );    % build linear model
%      iplot(glm, 1:2); % plot response verus cols colored by rows
% 
% Example 2
%      % continued from above
%      iplot(glm, [2 1]); % plot response versus rows colored by cols
%
% See also lsestimates, encode, mstats

% $Id: iplot.m,v 1.13 2006/12/26 22:53:26 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% changes
%   added support to allow user to control ordering of terms. input is now
%   sensitive to the ordering of the input argument "terms".
% todo
%   test added features
%   test with numerical data encoded as categorical
%   check that all terms are encoded in overdetermined form (or other
%   suppoported form)
%   support different ordering of terms and interpret the order as a way to
%   for the user to choose which factors go on which axis and how they get
%   drawn in the figure

if nargin < 2 || isempty(terms);
    terms = 1;
end;

if length(terms)>4
    error('linstats:iplot:InvalidArgument', 'only supports up to 4 way interactions');
end;

if nargin < 3
    response = 1;
end;



glm.y = glm.y(:,response);


[terms order] = sort(terms);    % ignore order

M = glm.model;

% find the interaction term of interest
term = find(all(M(:,terms)==1,2) & sum(M,2) == length(terms) ) -1 ;

if isempty(term)
    error('linstats:iplot:InvalidArgument', 'the specified interaction term is not included in the model');
end;

if any(glm.var_types(terms) ~= 3)
    error('linstats:iplot:InvalidArgument', 'all variables must be overdetermined form');
end;

ls = lsestimates( glm, term );

source = ls.source;
ln = cell(length(terms),1);
for i = 1:length(terms)
    ln{i} = regexprep( regexprep( source, '\*.*$', '' ), '^.*=', '' );
    source = regexprep( source, '[^\*]*\*', '', 'once' );
end;

ln = ln(order);
[gi,gn] = grp2ind( ln{1} );

xi = terms(order(1));

[h lh] = ciplot( gi(:,1), ls.beta, ls.ci, ln{2:end} );
set( gca, 'xtick', 1:length(gn), 'xticklabel', gn );

xlabel( glm.var_names{xi} );
ylabel('marginal response');

% add legend labels
for i = 2:length(terms)
    set(lh(i-1), 'xticklabel', glm.var_names{terms(order(i))} );
end;


if nargout > 0
    lsq = ls;
end;
    

