function l = boxcox(x,y,noecho, noplot)
% BOX/COX BoxCox procedure to evaluate the best transformation of the input
% data.  The values of Y cannot be negative.
%
% Examples
%   l = boxcox(X,Y)
%       % where X and Y are column vectors (Y>0), returns the optimum power
%       tranformation for Y and produces a plot of mse versus
%       transformation and echos a table of results
%       Y.^l is the box-cox recommended transformation
%
% author Mike Bass 2004
% mjb - added a return value, which is the lambda that minimizes sse
% mjb - added a quiet switch to turn off displays
% mjb - 1/19/2006 changed line 37 from figure to newplot
%       so instead of always creating a new figure, it will instead
%       "do the right thing" (i.e. behave like other matlab plots)
% mjb - added more options to verbosity 1/20/06

% $Id: boxcox.m,v 1.5 2006/12/26 22:53:12 Mike Exp $
% Copyright 2006 Mike Bass
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


if min(y) <= 0
    error('Error:  Range of Y values must be positive');
end

len = length(x);

% following equation sometimes overflows, so let's something else
% k2 = power(prod(y),1/len);
k2 = exp((1/len)*sum(log(y)));

%do a bounded search for the minimum
l = fminbnd( @(lambda) obj_boxcox(lambda, x,y, k2), -4,4 );

if nargin < 4
    noplot = 0;
end
if nargin < 3
    noecho = 0;
end;

%do the default graphs and print a table
lambdas = -2:0.25:2 ;
sse = nan( length(lambdas),1);
if ( ~noplot || ~noecho )
    j = 0;
    if ~noecho
        disp('  Lambda   SSE');
    end
    for i = lambdas
        j = j+1;
        sse(j) = obj_boxcox( i, x, y, k2 );
        if ~noecho
            disp(sprintf('  %5.2f    %6.4e',i,sse(j)));
        end
    end


    if ~noplot
        newplot;
        plot(lambdas, sse, 'o');
        axis([-2 2 0 min(sse)*10]);
        xlabel('Lambda');
        ylabel('SSE');
        title('Box-Cox Plot');
    end
end;

end


function sse = obj_boxcox( lambda, x, y, k2 )

if lambda==0
    yt = k2 * log(y);
else
    k1 = 1 / (lambda*power(k2,lambda-1));
    yt = k1 * (power(y,lambda) - 1);
end

if ~all(x==1)
    x = x2fx(x);
end;

[b,bi,r] = regress(yt,x);
sse = sum(r.^2);
%     disp( [lambda sse] );
end

