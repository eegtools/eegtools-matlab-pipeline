function [vout len_array] = combn_all(v, k)
% combn_all All combinations of the N elements in V.
%   Inputs: v, a row or column vector,
%           k, a scalar or vector, see the MATLAB built-in function 
%              combnk for details
%
%   Outputs: vout, a cell array
n =length(v);

if nargin <2
    k =1:n;
end

if strcmpi(k, 'all')
    k =1:n;
end

len_array =factorial(n)./(factorial(k).*factorial(n-k));
vout =cell(1, sum(len_array));

for m =1:length(k)
    vn =combnk(v, k(m));
    if m ==1
        ind1 =1;
    else
    ind1 =sum(len_array(1:m-1))+1;
    end
    ind2 =ind1+len_array(m)-1;
    vout(ind1: ind2) =mat2cell(vn, ones(1, size(vn, 1)), size(vn, 2));
end