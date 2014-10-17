function anova_compare( x, y )
%ANOVA_COMPARE internal callback to compare stats structures
%
% example
% anova_compare(x,y), 
%   x and y are results from anova

if ~isequal( size(x.ssr), size(y.ssr) )
    error( 'linstats:anova_compare:dims', 'error in dimensions' );
end;

[k,k,p] = size(x.ss);

if ~isequal( x.dft, y.dft )
    error( 'linstats:anova_compare:dft', 'error in dft' );
end;

if ~isequal( x.dfe, y.dfe )
    error( 'linstats:anova_compare:dfe', 'error in dfe' );
end;

if ~isequal( x.dfe, y.dfe )
    error( 'linstats:anova_compare:dfe', 'error in dfe' );
end;

if ~isequal( x.dfr, y.dfr )
    error( 'linstats:anova_compare:dfr', 'error in dfr' );
end;

if ~isequal( x.df, y.df )
    error( 'linstats:anova_compare:df', 'error in df for f-tests' );
end;

if ~mat_compare( x.beta, y.beta)
    error( 'linstats:anova_compare:beta', 'error in bhat' );
end;

if  ~mat_compare( x.sse, y.sse)
    error( 'linstats:anova_compare:sse', 'error in sse for f-test' );
end


if  ~mat_compare( x.sst, y.sst);
    error( 'linstats:anova_compare:sst', 'error in sst for f-test' );
end

if  ~mat_compare( x.ssr, y.ssr)
    error( 'linstats:anova_compare:ssr', 'error in ssr for f-test' );
end

if  ~mat_compare( x.pval, y.pval)
    error( 'linstats:anova_compare:ssr', 'error in pval' );
end

for i = 1:p
    if  ~mat_compare( x.ss(:,:,i), y.ss(:,:,i) );
        error( 'linstats:anova_compare:sst', 'error in ss for f-test' );
    end
end