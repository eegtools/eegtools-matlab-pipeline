function [singular, k, c0, txt, b] = issingular( A, cmat )
%ISSINGULAR returns singularity information about system of equations
%
%Example
%function [singular, k, c0, txt] = issingular( A, cmat )
%   determines whether the design is singular
%   if it is it returns the details of the sinularity
%   returns 
%      singular: a boolean indicator
%      k:   the linear dependent columns of A
%      c0:  the rational null space of cmat
%      txt: is a textual (barely readable) of the singularity
% See also lindc, coeff2eqn

% $Id: issingular.m,v 1.9 2006/12/26 22:53:16 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if ( nargin < 2 )
    cmat = [];
end;

if isstruct(A)
    cmat = A.cmat;
    glm  = A;
    A    = A.dmat;
    ls.source = glm.coeff_names;
else
    glm.coeff_names = cell(size(A,2),1);
    for i = 1:size(A,2)
        glm.coeff_names{i} = sprintf( 'X%d', i);
    end
end;

if ( ~isempty(cmat) && ~sum(cmat(:))==0)
    c0 = null(cmat, 'r');
    A0 = A*c0;
else
    c0 = [];    % this should be n x m diag matrix
    A0 = A;
end

nrows = size(A);
[q,r,e] = qr(A0,0); %#ok

%estimate rank, n, after qr
d = abs(diag(r));
if (nrows == 1 )
    d = r(1);
end;
tol = 100 * eps(class(d)) * max(size(r));
n = sum(d > tol*max(d));

if ( n < size(A0,2) )
    b = lindc( r );
    k = diag(b)~= 1;    % find the singular terms
    b = b(:,k);
    
    if isempty(c0)
        coeff_names = glm.coeff_names;
    else
        % calculate a name for a full-rank encoding method
        coeff_names = coeff2eqn( c0', glm.coeff_names, 1);
    end;
    
    % singularity details
    rhs = coeff2eqn( b', coeff_names, 1 );
    lhs = coeff_names(k);
    
    txt = strcat(lhs, ' = ', rhs);
    
    singular = true;
else
    b = eye(n);
    k = [];
    singular = false;
    txt = '';
end;

return 


