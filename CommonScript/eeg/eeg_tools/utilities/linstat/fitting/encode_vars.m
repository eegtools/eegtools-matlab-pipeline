function glm = encode_vars( ivar, var_type, model, var_names, level_names  )
%ENCODE_VARS helper function for encode
%Example
%glm = encode_vars( dmat, var_type, var_names, level_names );
%allows different encoding schemes including scaled continuous variables
%allows for models without an intercept
%will allow for higher order models
% model works like this
%
%        x(1)  x(2) ... x(q)
% term(1)  0      0   ...  0     // intercept
% term(2)  1      0   ...  0     // variable 1. 
% ...
% term(k)                     // any mix of variables

% each variable, x(i), i = 1...q, has p(i) levels. 

% each variable gets expanded to p(i) columns (if using overdetermined
% encoding) otherwise it gets expanded to p(i)-1 columns using a full-rank
% method of encoding. Each column is a indicator variable and there are 
% a total so sum(p) = qc variables
% Each term in this model is associated with a distinct 
% coefficient and so this is the model we use to solve the coefficients
% there are a total of kc terms in the model
%
% emodel = x(1)(1) ... x(1)(p(1))  x(2)(1)...x(2)(p(2))
% term(1)= 1            0            0          0
% term(2)= 0            1            0          0
% ...
% term(kc)

% $Id%
% Mike Boedigheimer
% Amgen
% Department of Computational Biology
% mboedigh@amgen.com

%% to do
%   support higher order models

hasIntercept = 0;
if ( any( all(model==0,2)))
    hasIntercept = 1;
else
    warning('linstats:encode_vars:NoIntercept','model has no intercept term');
end

[k,mcols]      = size(model);
[nobs, q]      = size(ivar);

if ( q ~= mcols )
    error( 'linstats:encode_vars:InvalidArgument', 'model specification must have the same number of model variables');
end;


% encode variables as requested and store
% them in a cell array, vmat, so that we don't
% need to continually expand the design matrix
% later we will figure out the total size and
% move them all over at once
vmat        = [];
p           = zeros(1,q);         % number of levels for the ith variable
df0         = zeros(1,q);         % degrees of freedom for the ith variable
mu          = zeros(1,q);         % means
oset        = cell(1,q);          % offsets to expanded parameters
coeff_names = cell(1,1);

qc       = 0;
for i = 1:q
    gn = level_names{i};

    f = ivar(:,i);
    if (var_type(i) > 0 )
        tmat =  mdummy(f,var_type(i));
        p(i) = size(tmat,2);
        df0(i) = p(i) - (var_type(i)==3);
        vmat{i} = tmat;
        oset{i} = qc+1:(qc+p(i));
        if  var_type(i) == 2
            coeff_names( oset{i} ) = strcat( var_names(i), '=', gn(2:p(i)+1), '-', gn(1:p(i)) );
        else
            coeff_names( oset{i} ) = strcat( var_names(i), '=', gn(1:p(i)) );
        end

    else
        p(i)    = 1;
        oset{i} = qc+1;
        
        if ( var_type(i) < 0 )
            % center and scale the continuous variables
            mu(i)   = mean(f(~isnan(f)));
            f       = f - mu(i);
            if (var_type(i) < -1 )
                r    = mrange(f)/2;
                f    = f/r;
            end
            coeff_names( qc+1:(qc+q)) = {strcat( '(', gn, '-', sprintf('%.2f',mu(i)), ')' )};
        else %var_type == 0
           coeff_names( qc+1:(qc+q)) = {gn};
        end;
        vmat{i} = f;
    end;

    qc = qc+p(i);
    %     terms(end+1: end+q ) = i;
end

%calculate final size
t = model.*repmat( p, k, 1);
t(t==0) = 1;
eterms = prod(t,2);

t = model.*repmat( df0,k,1);
t(t==0) = 1;
df0  = prod(t,2);

kc = sum(eterms);

%expand the model
emodel = zeros( kc, qc );

currow = 1;
cmat  = 0;
cb    = [ 1 1];
terms = zeros( 1, kc );

C = {};

for i = 1:k
    tm = model(i,:);

    %% deal with intercept
    if (all(tm==0))
        terms(currow) = i-1;
        currow = currow+1;
        cb(2) = cb(2) + 1;
        continue;
    end;
    
    %% build emodel
    %%TODO add support for higher order models
    icol = sortrows(ffact(p(logical(tm))));
    dvar = mdummyx(icol);

    if ( size(dvar,2) == 1)
        dvar = dvar';
    end;
    erow = currow+eterms(i);
    emodel(currow:erow-1,cat(2,oset{logical(tm)})) = dvar;
    terms( currow:erow-1) = i-hasIntercept;
    currow = erow;

    %% build constraints
    if ( df0(i) == eterms(i) ) 
        C{i} = zeros( 1, eterms(i) );
        continue;
    end;
    
    tconstr = 0;       % empty constraints so far

    tm(var_type<=0) = 0;
    vars = find(tm);
    for varidx = 1:length(vars)
        % Process each variable participating in this term
        varnum     = vars(varidx);
        tm(varnum) = 0;

        % Construct the term name and constraints matrix
        if (tconstr==0)
            tconstr = ones(1,p(varnum));
        else
            tconstr = [
                kron(tconstr,eye(p(varnum)));
                kron(eye(size(tconstr,2)),ones(1,p(varnum)))
                ];
        end
    end

    % we don't need to build this up into an existing matrix because we can use blkdiag 
    % to build it at once below.
    C{i} = tconstr;

end

if ~isempty(C)
    if hasIntercept
        cmat = blkdiag( 0, C{:} );
    else
        cmat = blkdiag( C{:} );
    end;
end



%% build dmat
% maybe here is where I should center and scale continous 
% variables
x = cat(2,vmat{:});
m = size(x,1);
kc = size(emodel,1);
dmat = zeros( m, kc );

   for idx = 1:kc
      t = emodel(idx,:);
      tmp = x(:,t>0);
      if size(tmp,2) == 1
         dmat(:,idx) = tmp;
      else
         dmat(:,idx) = prod(tmp,2);
      end
   end


% here is an ugliness. it is necessary so that I don't constrain
% a single coefficient to equal 0.Otherwise this would happen
% in models that include an overdetermined variable and an full-rank
% variable. There must be a more elegant way to do this.

i = sum(cmat,2)==1;
cmat(i,:)  = 0;

glm.model      = model;             % model for unencoded variables
glm.emodel     = emodel;            % model for encoded variables 
glm.hasIntercept=hasIntercept;
glm.dmat       = dmat;              % encoding of each observation 
glm.cmat       = cmat;              % contrains on coefficients suming to zero
glm.terms      = terms;             % refers to terms included in the model
glm.var_names  = var_names;         % names of all possible variables even if they aren't in the model
glm.coeff_names= model2eqn( glm.emodel, coeff_names );  % names of associated coefficient in the emodel
glm.level_names= level_names;       % cell array of level names for all variable 
glm.var_types  = var_type;          % variable type for all variables
glm.ivar       = ivar;              % integer encoding of all variables

if hasIntercept
   eterms(1) = [];
end;
glm.nlevels    = eterms;            % nlevels for variables in the model 
glm.df0        = df0(hasIntercept+1:end)';              % expected degrees of freedom for each variable in the model

