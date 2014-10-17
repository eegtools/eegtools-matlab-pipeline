function [b order] = ind2logical( i, d )
% IND2LOGICAL converts integer index into logical of size d
% 
% Example
%       b = ind2logical( i )
%           where i is an integer index, b is a boolean vector of
%           length(max(i)) x 1
%
%       b = ind2logical( i, d)
%           i can be numberic and all i in (0,1) or a logical vector of
%           length(d). returns b is simply the logical version of i
%           where i is an integer index <= d, b is a logical vecotr of size
%           dx1
%   [b order] = ind2logical(i,d)
%           if i is unsorted, then order sort order of i

if isnumeric(i) && all(ismember(i,[0 1]) ) 
    i = logical(i);
end

b(i) = true;

if nargin >= 2
    if length(b) > d
        error( 'linstats:ind2logical:indexoutofbounds', 'index i exceeds dimension d');
    end
    b(end+1:d) = false;
end
         
if nargout > 1 
    if isnumeric(i)
        [isort order] = sort(i);
    else
        order = 1:sum(s);
    end
end;