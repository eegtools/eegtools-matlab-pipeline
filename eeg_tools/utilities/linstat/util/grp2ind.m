function [gi,gn,i] = grp2ind( varargin )
%GRP2IND converts grouping variables in integer indices
%
%function [gi,gn,i] = grp2ind( varargin )
% varargin is a set of n mgrouping variables of length m. They can be
% integer, char or cell arrays of strings. 
% gi is an m x n matrix of integer grouping varibles
% gn is a n x 1 cell array of unique levels names for each grouping
%    variable.
% i is an index into A such that gn = A(i,:);
%
%Example
%  load weather
%  [fi, fn] = grp2ind( g1, g2, g3 ); 
%  factors  = ind2grp( fi, fn{:} );   % and back
%
% see also grp2idx, ind2grp
% 

% $Id: grp2ind.m,v 1.10 2006/12/26 22:54:08 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


m = length(varargin);
A = varargin{1};
n = size(A,1);
gi = nan(n,m);
gn = cell(m,1);
i  = cell(m,1);
for j = 1:m
    A = varargin{j};
    if ischar(A)
        A = cellstr(A);
    end;
    if ( iscell(A) )
        A = A(:);
        n = length(A);
        [a,b,c]   = unique( A );
        [arev,brev]   = unique( flipud(A) );
        % a = arev, both in alphabetically order
        % brev is the highest index is flipud(A), and can be converted
        % to the lowest index in A
        bstar  = n - brev + 1;
        % now we have
        % A(b) = A(bstar),  bstar uses the lowest available index
        
        % sort b to get the original order
        [bsort,order] = sort(bstar);


        % sort a into the order of appearance in A
        gn{j}     = a(order);   
        
        % sort c using the same order
        x(order)  = 1:length(b); %#ok
        gi(:,j)   = x(c);
        i{j}      = b;
        
        % account for missing values
        % This is where missing factors are identified
        % when building models. 
        k = find(strcmp(gn{j},''));
        if ~isempty(k)
            G = gn{j};
            G(k) = [];         % delete from levels
            gn{j} = G;
            q = gi(:,j);
            gi(q==k,j) = nan;    % change gi to nan
            gi(q>k,j)  = gi(q>k,j)-1;  % correct for deletion of gn(k)
        end;
    else
        A = A(:);
        [a,b,c]   = unique( A );
        k         = isnan(a);     % find missing values
        q         = find(k);
        if ( ~isempty(q) )
            if length(q>1)
                c(ismember(c,q)) = nan;
            else
                c( c==q ) = nan;       % set index to nan
            end;
            a(k) = [];
        end;
        gi(:,j)   = c;
        gn{j}     = cellstr(num2str(a));    
        i{j}      = b;
    end;

end
if m == 1
    gn = gn{:};
    i  = i{:};
end;