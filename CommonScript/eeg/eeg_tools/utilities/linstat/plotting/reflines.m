function [b, h] = reflines(glm, x1, f1)
% REFLINES plots a series of reference lines for an ANACOVA model
%
%     reflines(glm, x1, f1)
%       glm is a structure from encode
%       x1 is a scalar refering to the continuous variable in the eqn
%       f1 is a scalar refering to the categorical variable in the eqn
%
% Example 
%   % draw separate lines for each of 3 model years
%   load carsmall;
%   glm = encode( MPG, [3 0], 2, Model_Year, Weight );
%   s   = mstats(glm);
%   plot( Weight(~glm.missing), s.yhat, '.' );
%   reflines( glm, 2, 1 ) ;

% $Id: reflines.m,v 1.3 2006/12/27 16:52:32 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

% todo
%   check input parameter validity. 
%   generalize

ls = solve(glm);

% global intercepts
if ( glm.hasIntercept == 0 )
    i = 0;
else
    i = ls.beta(1);
end

if nargin < 3
    f1 = find( glm.var_types > 0, 1);
end;

if nargin < 2
    x1 = find( glm.var_types <=0, 1 );
end;

% slopes for each level in f1
i = i + ls.beta(glm.terms==f1);

% global slope for x1
s = ls.beta(glm.terms==x1);

% slope for each level in f1
M  = glm.model;
j  = find(M(:,x1) == 1 & M(:,f1) == 1 & sum(M,2)==2) - 1;
s = s + ls.beta(glm.terms==j);


% expand slopes and intercepts to the common size
m = length(i);
n = length(s);

if ( m ~= n )
    if m > 1 && n > 1 
        error('I''ve Never seen this error before. It looks like there somethings wrong with the number of slopes and intercepts. ');
    end
    i = repmat( i, n, 1 );
    s = repmat( s, m, 1 );
end

b = [s i];

h = zeros(size(b,1),1);
for j = 1:size(b,1)
    h(j) = refline( s(j), i(j) );
end;

