% tests singularity detection
% there should be a warning whenever a term in an equations
% is not estimable. This happens when there are no observations
% for that term
% for example if we the following table of observations

% suppose we were studying salaries of people and
% had the following observations

%           IQ
%           hi  lo
% brown     2   2
% blonde    0   2

% we wouldn't be able to estimate the salary of smart blonde people because
% we didn't run across any


errors = 0;
total_errors = errors;

load weather.mat
% build a model and impute the missing values
glm = encode([], [3 3],2,g1,g2);
y = impute(y, glm);

% get the interaction terms
glm       = encode( y, 3, [ 0 0; 1 1], g1, g2  );

% and a unique index for each combination
i = decode(glm);

% labels for the interaction terms
eqn = glm.coeff_names;
labels = eqn(i+1);

% find all occurences of combination 1
i = find(i==1);



% change the responses to nans one at a time.
% until the solution is unattainable
% solve will issue a warning when a cell
% is empty and will have an extra field
try
    for j = 1:length(i);
        y(i(j)) = nan;
        glm = encode(y, 3,2,g1,g2);
        if  xor( issingular( glm ), j == 4)
            error( 'linstats:test_singularity:singular', 'error finding singulars' );
        end;
    end;
    issingular( glm.dmat);
    issingular( glm.dmat, glm.cmat );

    disp('passed: test_singularity');

catch
    disp('failed: test_singularity');
end


