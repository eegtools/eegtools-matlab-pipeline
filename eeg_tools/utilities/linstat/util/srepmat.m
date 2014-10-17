function A = srepmat( form, a, siz )
% SREPMAT replicate standard matrices 
%
%

m = size(siz,1);
A = cell(m,1);
for i = 1:m
    A{i} = repmat( a, siz(i,:) );
end

switch form
    case 'd' 
        A = blkdiag(A{:});
    case 'c' 
        A = cat(1, A{:});
    case 'r' 
        A = cat(2, A{:} );
    case 'm' 
        A = cell2mat(A);
end