function [b,c] = indexof( v, d )
%INDEXOF indices of set members
%
% [b,c] = indexof( v, d )
% V is a M x 1 vector of values to test for membership
% D is a N x 1 vector of values in a set (possible non-unique)
%
% returns the first index into d for each element of v. 
% so that
%   v = d(b), for v in d
% c is a boolean MxN array, of all tests of V against D. It contains the
% results of comparing the Ith elmenent of v ( I = 1..M) to the Jth element
% of d (J = 1..N).
%
%Example
% set = [0 2 4 6 8 10 12 14 16 18 20];
% a   = reshape(1:5, [5 1]);
% [b c] = indexof(a, set);
%
% see also ismember

% $Id: indexof.m,v 1.3 2006/12/26 22:54:09 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

v = v(:);
d = d(:);
b = repmat(NaN, size(v) );

if ( iscell(v) && iscell(d) )
    for i = 1:length(v)
        try
        b(i) = find( strcmp( v(i), d ),1 );
        catch
            disp(i);
        end;
        
            
    end;
    return;
end;
    


[v_rows] = length( v );
[d_rows] = length( d );

v_rep = repmat( v, 1, d_rows);
d_rep = repmat( d', v_rows, 1 );

c = v_rep == d_rep;
[I,J] = find( c);
b(I) = J;


    


