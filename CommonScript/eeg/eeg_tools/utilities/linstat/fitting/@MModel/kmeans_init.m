function mm = kmeans_init(mm, k)
% KMEANS_INIT sets starting parameters using kmeans
%
% Example
%   [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
%   mm = MModel(X, [1 2], 4 );  % initilize using kmeans
%   [X idx theta] = mmvn_gen( 1000, [0 5 0; 5 0 0; 5 5 0; 0 0 0] );
%   mm = setData(mm, X);
%   mm = kmeans_init(mm,4);     % reset parameters using kmeans


% $Id: kmeans_init.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com

if isempty(mm.x)
    return;
end;

if nargin < 2
    k = size(mm.b0.M,1);
end

n = size(mm.x,1);
d = sum(mm.s);

if k > 1
    [Ci,C] = kmeans(mm.x(:,mm.s), k,...
        'Start','cluster', ...
        'Maxiter',100, ...
        'EmptyAction','drop', ...
        'Display','off'); 
else
    C = mean(mm.x(:,mm.s));
    Ci = ones( n, 1);
end;
M = C';
V = zeros(d,d,k);
W = zeros(k,1);
for i=1:k,
    j = Ci==i;
    W(i) = sum(j)/n;
    V(:,:,i) = cov(mm.x(j,mm.s));
end
theta.M = M';
theta.V = V;
theta.W = W;

mm = setTheta(mm, theta);
mm.knames = cellstr( num2str( (1:k)' ) );