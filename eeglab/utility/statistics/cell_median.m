%% function [meanArray] = cell_median(cell_array)
% given a cell array of m x n matrices, calculate the average m x n matrix
function [meanArray] = cell_median(cell_array)
    if nargin < 1
            help cell_mean;
            return;
    end;

         dim = ndims(cell_array{1});          %# Get the number of dimensions for your arrays
         M = cat(dim+1,cell_array{:});        %# Convert to a (dim+1)-dimensional matrix
         meanArray = median(M,dim+1);  %# Get the mean across arrays    
end