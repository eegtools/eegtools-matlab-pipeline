function mm = setMeans(mm, i, M, s)
% setMeans -  sets the centroids
% example
%       mm = setMeans(mm, i, M)
%            i is a q x 1 logical or integer vector 
%            M is a q x d matrix which becomes the centroid
%       mm = setMeans(mm, i, M, s )
%            sets the means of the kth cluster for dimensions specified in
%            s. s is a logical vector or integer index
%

% $Id: setMeans.m,v 1.2 2006/12/26 22:53:10 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com


b0 = getTheta(mm);

[k d]  = size(b0.M);

if nargin < 3
    error('linstats:MModel:setMeans', ...
        'M must be a vector of length d');
end


if nargin == 3
    q = max( max(i), length(i) );
    if q > k
        error('linstats:MModel:setMeans', ...
            'cluser index out of range');
    end;

    if size(M,1) ~= q || size(M,2) ~= d 
        error('linstats:MModel:setMeans', ...
            'M must be a q x d matrix ');
    end

    b0.M(i,:) = M;

elseif nargin == 4
    [s order] = ind2logical( s, size(mm.x,2) );
    if size(M,2) ~= sum(s) || ~isvector(M)
        error('linstats:MModel:setMeans', ...
            'M must be a sum(s)-vector');
    end
    
    b0.M(i,s) = M(order);

end

%%TODO apply constraints (iff applicable)

mm = setTheta( mm, b0 );

