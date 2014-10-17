function mm = addCluster(mm, M, s)
% ADDCLUSTER -  add a new cluster to the Mixture Model
% 
%       mm = addCluster(mm)
%            adds a new cluster at a location equal to the the column means 
%       mm = addCluster(mm, m)
%            adds a new cluster at the given starting location m
%            m is a d - vector
%       mm = addCluster(mm, m, s )
%            adds a new cluster at a starting location equal to m in
%            dimensions s, in other dimensions equal to the column means of
%            s.  s is a logical vector or integer index
%       
% Example
%   [X idx theta] = mmvn_gen( 1000, [0 5; 5 0; 5 5; 0 0] );
%   mm = MModel(X, [1 2], 1 );      % model with one cluster
%   mm = addCluster( mm, [ 0 5] );  % add new cluster at 0 5


% $Id: addCluster.m,v 1.2 2006/12/26 22:53:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


x  = mm.x;
[k d]  = size(mm.b0.M);

if nargin == 1
    % u defaults to the mean of each dimension (column)
    u  = nanmean( x );
elseif nargin == 2
    if ~isvector(M) || length(M) ~= d 
        error('linstats:Facs:addCluster', ...
              'M must be a vector of length d');
    end
    u = M;
else
    
    % interpret s as logical if it is the right length and all 0s and 1s
    if length(s) == size(x,2) && all(ismember(s,[0 1]))
        s = logical(s);
    end

    if (islogical(s) && (length(s) <= size(x,2) || sum(s) ~= size(M,2) ) ) || ...
       (isnumeric(s) && max(s) > size(x,2) )
            error('linstats:Facs:addCluster', ...
                'illegal or out of range s');
    end

   
    u = nanmean( x );
    u(s) = M;
    
end
        
k  = k + 1;
b0 = getTheta(mm);
b0.M(k,:)   = u(:,mm.s);
b0.V(:,:,k) = mean(mm.b0.V,3);      % average previous variances
b0.W(k)     = min(b0.W);
b0.W        = scale(b0.W(:));

%update labels
str           = num2str(k);
mm.knames{k} = str;

% set heirarchical constraints
if ~isempty( b0.h0 )
    b0.h0(end+1,:) = max(b0.h0(:))+1;
end;
if ~isempty(b0.v0)
    b0.v0(end+1,:) = max(b0.v0(:))+1;
end;

mm = setTheta( mm, b0 );

