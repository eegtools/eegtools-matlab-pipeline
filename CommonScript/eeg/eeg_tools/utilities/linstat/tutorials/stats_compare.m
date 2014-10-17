function stats_compare( x, y )
%STATS_COMPARE internal callback to compare stats structures
%
% example
% stats_compare(x,y), 
%   x and y are stats structures (e.g. from lsestimates)

if ~isequal( x.dfe, y.dfe )
    error( 'linstats:stats_compare:dfe', 'error in dfe' );
end;

% if ~isequal( x.dfr, y.dfr )
%     error( 'linstats:stats_compare:dfr', 'error in dfr' );
% end;

if ~mat_compare( x.beta, y.beta)
    error( 'linstats:stats_compare:beta', 'error in bhat' );
end;

if ~mat_compare( x.ci, y.ci )
    error( 'linstats:stats_compare:ci', 'error in confidence intervals' );
end;

if ~mat_compare( x.se, y.se )
    error( 'linstats:stats_compare:se', 'error in standard errror' );
end;

if ~mat_compare( x.t, y.t )
    error( 'linstats:stats_compare:t', 'error in t stastic' );
end;

if ~mat_compare( x.pval, y.pval )
    error( 'linstats:stats_compare:pval', 'error in p-val' );
end;

