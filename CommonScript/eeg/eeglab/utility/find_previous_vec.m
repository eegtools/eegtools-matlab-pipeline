function [out] = find_previous_vec(vec1, vec2)
%% function [out] = find_previous_vec(vec1, vec2)
% given vector 1 and vector 2 give a vector with the same length of vector
% 1 and with elemnts of vector 2 which are closest and preceding vector 1
% 
% out.mst_dif_raw   = mst_dif_raw;                                           % matrix. crossed differences between vector 1 and vector 2 
% out.mst_dif       = mst_dif;                                               % matrix. crossed differences between vector 1 and vector 2 with positive differences set to nan
% out.vec1          = vec1;                                                  % vector 1
% out.vec2          = vec2;                                                  % vector 2
% out.idx           = idx0;                                                  % indices of vector 2 corresponding to previous elements to each element of vector 2. if no previous element exist, nan
% out.vec2_previous = vec2_previous;                                         % vector. selected elements of vector 2 
% 
% 
mst_dif_raw = bsxfun(@minus, vec2', vec1);

mst_dif  = mst_dif_raw;
mst_dif(mst_dif_raw >= 0)=nan;

idx0 = min(abs(mst_dif(:,1:size(mst_dif,2))));
[a,idx] = min(abs(mst_dif(:,1:size(mst_dif,2))));

vec2_previous = vec2(idx);

vec2_previous(isnan(idx0)) = nan;

out.mst_dif_raw   = mst_dif_raw;                                           % matrix. crossed differences between vector 1 and vector 2 
out.mst_dif       = mst_dif;                                               % matrix. crossed differences between vector 1 and vector 2 with positive differences set to nan
out.vec1          = vec1;                                                  % vector 1
out.vec2          = vec2;                                                  % vector 2
out.idx           = idx0;                                                  % indices of vector 2 corresponding to previous elements to each element of vector 2. if no previous element exist, nan
out.vec2_previous = vec2_previous;                                         % vector. selected elements of vector 2 

end


