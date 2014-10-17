function eq = mat_compare( x, y, tol )
% function, comare two matrices to see
% where one is a copy of the other to a given tolerance


if ndims(x) ~= ndims(y) || any( size(x) ~= size(y) )
    eq = false;
    return
end

if nargin < 3
    tol = 1e-8;
end

eq = rank( x-y, tol)==0;
