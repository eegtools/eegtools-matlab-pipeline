%% tests encode decode mechanisms for categorical encoding
% 
try
levels =  { 'a' 'b' 'c'; '3' '2' '1'; 'B' 'C' 'A' };
i      = fullfact( [3 3 3 ]);
j      = repmat( 1:3, size(i,1), 1 );
factors = levels(sub2ind( [3 3], j, i ) );


y  = randn( [27 1] );
y( all(i(:,1:2)==1,2) ) = nan ;


glm = encode( y, 3, 2, factors(:,1), factors(:,2) );
d   = decode( glm );


for a = 1:3
    if ~isequal( factors( i(m,a), a ), factors(d(:,a),a) )
        error( 'failed encode' )
    end
end;

    disp( 'passed encode/decode' );
catch
    disp('failed:1-way anova' );
end;