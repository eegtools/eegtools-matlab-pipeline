function s = model2eqn( model, coeff_names, delim, null_name )
%MODEL2EQN creates a text representation of a model
%
% s = model2eqn( model, coeff_names, delim, null_name  )
% returns the parameter (or effect) names from 
% a model and a set of names
% The coeff_names corresond to columns in the model
% if there is an intercept term in the model, a name for can be specified
% in the null name
%
% Example:
%   load carbig
%   glm = encode( MPG, 3, 2, Origin, Cylinders );         % Origin is explanatory variable
%   model2eqn( glm.model, glm.var_names )
%
% See also coeff2eqn

% $Id: model2eqn.m,v 1.5 2006/12/26 22:53:20 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


% todo
% add support for models of higher degree
% add support for models with no intercept

if ( nargin < 3)
    delim = '*';
end;

if (nargin < 4)
    null_name = 'intercept';
end;

nterms = size(model,1);
s   = cell(nterms,1);

% whether model has intercept

for i = 1:nterms
    beta = model(i,:);
    if (all(beta==0))
        s{i} = null_name;
    else
        j   = find(beta~=0);

        
        % set leading sign 
        if ( (delim == '+' &&  model(i,j(1))<0) ) || ( delim == '*' &&  prod(model(i,j))<0  )
            s(i) = {'-'};
        else 
            s(i) = {''};
        end

        % for each term we are including
        for k = 1:length(j)
            % if this isn't the first term, insert the delimiter
            if ( k > 1 )
                d = delim;
                if ( delim == '+' && model(i,j(k))<0 )
                    d = '-';
                end;
                s{i}  = sprintf( '%s%s%s', s{i}, d, coeff_names{j(k)});
            else
                s{i}  = sprintf( '%s%s', s{i}, coeff_names{j(k)});
            end
        end
    end;
end;