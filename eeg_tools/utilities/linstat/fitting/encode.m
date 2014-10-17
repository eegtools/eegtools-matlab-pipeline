function glm = encode( y, var_type, model, varargin  )
%ENCODE encode a linear model
%Example
% glm = encode( response, var_type, model, varargin  )
%       response - an m x 1 vector or m x n matrix of system responses
%                - used during model building to find and remove missing 
%                - values
%       var_type - a scalar or k-vector specifying the type of each of k
%                - variables given in varargin. See below for details
%       model    - a scalar or q x k matrix. See below for details
%       varagin  - k model variables. These can be m vectors, or m x 1
%                - cellarrays of strings. missing values (nans or empty
%                - strings) are removed from all observations
%                   
% flexibly encodes predictor variables, varargin, into a design matrix that
% can be used in several functions. the model is returned in glm. 
%
% DETAILS
% The values of the response variable (independent variable) are given
% in y. y is used in the encoding step only to filter missing values.
% a missing response variable removes an entire row from the design matrix
% If all responses of a certain level of a categorical variable are
% missing, then an entire column of the design matrix is removed.
% missing responses are indicated by nan in the vector. If y is empty
% then all the values are assumed to be present
%
% The predictor variables in varargin may be continous or categorical
% (discrete). They are cell arrays or numerical vectors of the same length
% as the response variable (if provided)
% You can specify how these are encoded by providing a vector of variable
% types (one element for each predictor variable) in var_type
% The value of the var_type is one of the following
%   var_type = 3 means coding 0/1, overdetermined, implies creation of cmat
%   var_type = 2 means coding 0/1, full rank (aka ordinal encoding)
%   var_type = 1 means coding 0/-1/1, full rank (aka nominal encoding)
%   var_type = 0 means continous. use predictor variable directly
%   var_type = -1 means continuous centered
%   var_type = -2 means continuous centered and scaled to range 2
% var_type is optional. If var_type is empty the type is guessed using
% the function isdiscrete. If var_type is present it must be the same
% length as varargin or be a scalar. If it is a scalar it applies to all
% variables
%
% The model is either a scalar or a matrix of terms. If it is a scalar it
% refers to the degree of the model. 1 indicates a 1st degree model which
% contains only main effects. A 2nd degree model contains main effects and
% all pairwise interactions. For more complex models a matrix of terms can
% be used. Each row of the matrix represents one term in a factor effects
% model. Each column represents a predictor variable. A column containing a
% non-zero value will be included in the given term of the model. a row
% with all zeros is a global intercept term. If present it must be the
% first row. 
%
% The design matrices can be used in other matlab functions
% See also anova, solve, mstats, glmfit, polyfit, rstool, nlinfit, et al.

% output is a structure with the following fields
%   model       - matrix of terms to include in the model. each row
%                 represents one term in a factor effects model. each
%                 column refers to a predictor variable. a 1 indicates the
%                 variable is included in the term. Some columns may be all
%                 zeros thus some variables may be excluded from the model.
%                 A row with all zeros, if present, must be the first row
%                 and is a global intercept
%   emodel      - expanded matrix of parameterized terms. each row
%                 represents one term in the fully parameterized model.
%                 Each column refers to a column in the design matrix
%   dmat        - the design matrix
%   cmat        - constraints
%                 matrix. each row indicates a group of columns
%                 in the design matrix whose coefficients will be
%                 contstrained to sum to 0
%   terms       - vector with one element for each column in dmat.
%                 indicates with term in the factor effects model the
%                 column refers to.
%   var_names   - names of the variables in varargin (or x1,x2,x2..., if
%                 the names cannot be determined.
%   coeff_names - a cell arrary containing the names of each level of a
%                 categorical variable, or the variable name of a continous
%                 one.
%   var_types   - the type of variable encoding used for each variable. This is the
%                 same as the input parameter if it was present, otherwise
%                 it is the value that was guessed by isdiscrete.
%   T           - intermediate output. It is the numerical encoding 1:r of
%                 each categorical variable, or the numeric values of a
%                 continous variable.
%   nlevels     - a vector with one element for each variable. The value
%                 shows the number of columns used in the design matrix.
%                 This will be a 1 for continous variables. For categorical
%                 variable the value depends on the number of levels of the
%                 variable and the type of encoding.
%   y           - a copy of the response variable with missing values
%                 removed
%   dft         - the length of y after removing missing values minus 1
%   missing     - a boolean vector the same length as the input variables
%                 indicating the location of missing values in the input
%                 variables
%   df0         - degress of freedom for each predictor variable included
%                 in the model
%
% See also model_building_tutorial, solve, mstats, anova, manova

% $Id: encode.m,v 1.13 2006/12/26 22:53:14 Mike Exp $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
% TODO
%   Warn about duplicate effects?
%   Warn about nesting?
%   Warn about missing effects (i.e. encoding and interaction without one
%   of the terms?)
%   support higher degree (x.^2) models. work-arounds possible
%   mixed encodings 
%   automatically find nesting terms
%   allow some predictor variables be matrices so 10s or even 100s can be
%      input at once - mat2cell is helpful with this
%   reproduce jmp results with nominal and ordinal variables in a anacova setting
%   rename functions and variables consistently


%   Setting a default response maybe a bad idea...
if (isempty(y))
    f = varargin{1};
    nobs = length(f);       % y is empty
elseif isvector(y)
    y = y(:);
    nobs = length(y);     % y is vector
else                        % y is matrix
    nobs = size(y,1);
end;

% number of terms in the model
nvars = length(varargin);

% initially, dmat is the design matrix with numerical, but unencoded, data.
% it contains a grouping index for categorical variables and it uses
% continuous variables directly
if nvars == 0
    dmat = ones(nobs, 1);
else
    dmat = zeros(nobs,nvars);

    guess_var_type = false;
    if ( isempty( var_type ) )
        guess_var_type = true;
        var_type       = ones(1,nvars);
    elseif length(var_type) == 1
        var_type = repmat( var_type, 1, length(varargin) );
    elseif length(var_type) ~= length(varargin)
        error('linstats:encode:InvalidArgument', 'variable types must be the same length as the number of variables');
    end;

end;

%% part one
%   capture term names from inputname
%   capture variable names from levels of term names
%   encode qualitative data as index variables
%   guess term types if not given
var_names = cell(nvars,1);
coeff_names_cell = cell(nvars,1);
for i = 1:nvars
    var_names{i} = inputname(3+i);
    if ( isempty(var_names{i}) )
        var_names{i} = sprintf( 'x%d', i );
    end;
    f = varargin{i};
    if (isvector(f))
        f = f(:);
    end;

    if ( length(f) ~= nobs )
        istr = num2ord(i);
        error('linstats:encode:InvalidArgument', '%s factor must be a vector of length %d', istr, nobs );
    end;

    if ( guess_var_type )
        % may want to make a separate function for
        % this. It is useful to call and edit
        % particular nice if isdiescrete could take
        % multiple inputs
        [var_type(i), gi, gn ] = isdiscrete( f );
        if (var_type(i)==0)
            gi = f;
            gn = var_names{i};
        end;
    elseif (var_type(i) > 0 && var_type(i) < 4)
        [gi, gn] = grp2ind( f );
    elseif (var_type(i) == 4)
        [gn, ignore, gi] = unique(f);
        if (isnumeric(gn))
            gn = num2cell(gn);
        end;
    else % var_type is 0 (continuous)
        gi = f;
        gn = var_names{i};
    end;

    dmat(:,i) = gi;
    coeff_names_cell{i} = gn;
end;


%% part two
%       find and remove observations with missing values
missing = any(isnan(dmat),2);   %listwise deletion
if ~isempty(y)
    missing = missing | any(isnan(y),2) ; %listwise deletion of response
    y(missing,:)       = [];
end

if ( all(missing==1) )
    error('linstats:encode:NoResponse', 'all responses were removed during listwise deletion.\n To avoid listwise deletion first encode a model without a response and then\n add the resopnse to field y');
else
    dmat(missing,:)    = [];
end;

% move this into encode_vars?
if nvars == 0
    glm.y = y;
    glm.missing = missing;
    glm.dft = length(y)-1;
    glm.dmat = dmat;
    glm.cmat = 0;
    glm.coeff_names = {'intercept'};
    glm.model = 0;
    glm.hasIntercept = 1;
    glm.terms = 0;
    return;
end

%% part three
%   build a matrix representation of the model
if (isempty(model) || isscalar(model) )
    model = lmodel( nvars, model );
end;


%   encode variables into indicator variable matrix
glm = encode_vars( dmat, var_type, model, var_names, coeff_names_cell );


glm.y        = y;
glm.dft      = length(y)-1;
glm.missing  = missing;


% this is ugly. Basically if dmat is not full rank, glm provides a constraints
% matrix, cmat. Here I am assuming that if var_type is
% not 3, then cmat will be all zeros. In other functions
% it can be empty. encode_vars allows it to be empty.
if ( all(var_type ~= 3))
    glm.cmat   = zeros(1,size(glm.dmat,2));
end;





