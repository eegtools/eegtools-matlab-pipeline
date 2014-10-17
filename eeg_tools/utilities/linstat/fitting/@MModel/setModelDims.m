function mm = setModelDims( mm, s )
% sets the dimensions of x to use in the model
% example
%       mm = setModelDims( mm, s )
%            s is a logical vector of length n and mm.x is a data matrix
%            of size m x n
%            if s ~= mm.s then sets mm.s equal to s and creates new 
%            default model with sum(s) dimensions. 
%       mm = setModelDims( mm, s )
%            s is a logical vector of length n and mm.x is empty
%            sets s and creates a default parameter structure
%            with k taken from the size of existing b0.M

% $Id: setModelDims.m,v 1.2 2006/12/26 22:53:11 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 
b0 = getTheta(mm);

if isempty( mm.x )
    mm.s = s;
    k    = size(b0.M,1);
    d    = sum(s);
    checkTheta( s, zeros( k, d ) );
    return
end


s  = ind2logical( s, size(mm.x,2) );
    
ps = mm.s;              % current s

% start with k x n array of weighted means
M       = mm.u;
M(:,ps) = b0.M;        % copy over means from existing model
M       = M(:,s);      % use new dims
[k d]   = size(M);    % new k x d

d2 = mah( mm.x(:,s), M, repmat( eye(sum(s)), [1 1 k] ));
n = size(mm.x,1);
[mind2, idx] = min(d2,[],2);

V = nan( [d d k] );

for i = 1:k
    V(:,:,i) = cov( mm.x(idx==i,s) );
end;
    
    
% constratints
h0 = [];
if ~isempty(b0.h0)
    h0 = repmat( (1:k)', 1, d );
    h0(:,ps) = b0.h0;
end


v0 = [];
if ~isempty(b0.v0)
    v0 = repmat( (1:k)', 1, n );
    v0(:,ps) = b0.v0;    
end

b0.M = M;
b0.V = V;
b0.h0 = h0;
b0.v0 = v0;

mm.s = s;

mm = setTheta( mm, b0 );







