function V = mmvn_R2V( R )
% MMVN_R2V convert chol decomposed variances from a vector to variance matrix
%
% converts R, an k x d^2 matrix of chol decomposed variances in vector form
% into v, a d x d x k array of variances
% 
% Example
%   load carbig
%   X = [MPG Acceleration Weight Displacement];
%   V = nancov(X);
%   r = chol(V);
%   r = r(:);               % greedy em stores variances in this form
%   Vnew = mmvn_R2V(r');    
%   isequal(Vnew, V)

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


[k,d] = size(R);
d     = sqrt(d);

V = zeros( [ d d k ] );
for i = 1:k
    Rk =  reshape(R(i,:),d,d); 
    V(:,:,i) = Rk'*Rk;
end