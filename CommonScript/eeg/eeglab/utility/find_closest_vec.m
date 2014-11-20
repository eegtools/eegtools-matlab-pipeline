function [out] = find_closest_vec(vec1, vec2)
%% function [out] = find_closest_vec(vec1, vec2)
% given vector 1 and vector 2 give a vector with the same length of vector
% 1 and with elemnts of vector 2 which are closest to vector 1
% 
% out.mst_dif       = mst_dif;                                               % matrix. crossed differences between vector 1 and vector 2  
% out.vec1          = vec1;                                                  % vector 1
% out.vec2          = vec2;                                                  % vector 2
% out.idx           = idx;                                                   % indices of vector 2 corresponding to closest elements to each element of vector 2 
% out.vec2_closest  = vec2_closest;
% 
mst_dif = abs(bsxfun(@minus, vec2', vec1));

[~,idx] = min(abs(mst_dif(:,1:size(mst_dif,2))));

vec2_closest = vec2(idx);

out.mst_dif       = mst_dif;                                               % matrix. crossed differences between vector 1 and vector 2  
out.vec1          = vec1;                                                  % vector 1
out.vec2          = vec2;                                                  % vector 2
out.idx           = idx;                                                   % indices of vector 2 corresponding to closest elements to each element of vector 2 
out.vec2_closest  = vec2_closest;                                          % vector. selected elements of vector 2 
end


