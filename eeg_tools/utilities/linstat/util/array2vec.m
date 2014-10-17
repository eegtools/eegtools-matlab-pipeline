function [y, f] = array2vec( y, varargin )
% ARRAY2VEC converts an ndim table headers into column vectors 
%
% data manipulation routine to convert table (hypercube) style data to
% vectors.
%
% V = ARRAY2VEC(y, row_names, column_names, ... )
%   Y is a array of dimensions n(1), n(2), ...n(i)
%   the jth varargin in is an n(j) x 1 array or a cell array of n(j) x 1
%   arrays 
%   return V a prod(n) x 1 vector of values from Y. 
%
%
% Example
%   load popcorn
%   row_names = {'air' 'air' 'air', 'oil', 'oil', 'oil' };
%   col_names = {'Gourmet' 'National' 'Generic' };
%   [y, f] = array2vec(popcorn, row_names, col_names );
%    %anovan takes vector style input
%    p1 = anovan(y, f, 'model', 2 ); 
%    %anova2 takes table style input
%    p2 = anova2( popcorn, 3 ); 
%    
% See also
%   vec2array

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


i = ndims(y);
if nargin > i+1
        error('linstats:mrepmat:InvalidArgument', ...
            'nargin must be less or equal ndims of y');
end

[dim{1:ndims(y)}] = size(y);
dim = cell2mat(dim);


% grow cell array of factors as we go
f = {};

for i = 1:nargin-1;
    v = varargin{i};
    if ~iscell(v) || iscellstr(v)
        c = {v};       % make a cell array to simplify code below
    else
        c = v;
    end;
    
    
    k = length(c);
    for j = 1:k
        v = c{j};


        if numel(v) ~= dim(i)
            error('linstats:mrepmat:InvalidArgument', ...
                'varargin(%d) must be compatible with dimensions of y', i);
        end;
        rdim = dim;
        rdim(i) = 1;
        
        sdim = ones( 1,ndims(y));
        sdim(i) = dim(i);

        v = repmat( reshape(v,sdim), rdim );
        f{end+1} = v(:); %#ok
    end;

end;



y = y(:);

