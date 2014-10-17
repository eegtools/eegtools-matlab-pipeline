function dvplot( glm, tests, reference )
%DVPPLOT dropped variable plot
%
% plots predicted versus expected response for a series of models related
% to the model in glm. each plot will drop one or more variables from the
% model and a plot will be generated showing the predicted response with
% the reduced model. By visual inspection you can tell which variables are
% important to the model. 
%
% dvplot( glm, tests, reference )
%    GLM is a model created using encode
%    the input arguments tests and reference are optional (see anova for help)
%
% Example
%   % In the panel in the upper left you can see how much variance is
%   % explained when cols is dropped from the model
%   load popcorn
%   glm       = encode( y, 3, 2, cols, rows );    % build linear model
%   dvplot(glm)
%
% See also anova, gettests

% $Id: dvplot.m,v 1.4 2006/12/26 22:53:24 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


%default is type III
if (nargin < 2  || isempty(tests))
    tests = 3;
end;

if ( isscalar(tests) )
    [tests, reference] = gettests( glm, tests );

    % find the full model and add it to the reference
    % so that tests2eqn will build an equation for it
    i = find(all(tests==0,2));
    reference(end+1) = i;
end;

% build text that can be used in the titles
eqns    = strcat( '~', model2eqn( glm.model, glm.var_names));
if glm.hasIntercept
    eqns(1) = [];    
end;
eqns    = model2eqn( tests, eqns, ',', 'all' );

ntests   = length(reference);

% force the last test to be a full-model
tests(ntests,:) = 0;

% calculate the number of rows and columns needed to display
% at least ntests. Also make it close to square as possible

m = sqrt( ntests );
n = ceil(ntests/m);
m = ceil(ntests/n);

% leave out each term and calculate its marginal
% reduction in the sum of squared errors
[d, ymin, ymax] = range( glm.y );
y0      = glm.y;
ylim(1) = min(y0);
ylim(2) = max(y0);


for i = 1:ntests
    j = ~ismember( glm.terms, find(tests(i,:) ));
    ls =  mstats( glm.dmat(:,j), glm.y, glm.cmat(:,j) );
    subplot(m,n,i);
    mscatter( ls.yhat, y0 );
    set(gca, 'ylim', ylim );
    title(sprintf('y = f(%s)', eqns{i} ));

    % a indexes columns, while b indexes rows
    [a,b] = ind2sub( [n m], i );
    if ( b == m )   % last row
        xlabel('predicted');
    end;
    if ( a == 1 )  % first column
        ylabel('observed');
    end;

    h = refline(1,0);
    set(h,'linestyle', '-.', 'color', 'k');

end;

