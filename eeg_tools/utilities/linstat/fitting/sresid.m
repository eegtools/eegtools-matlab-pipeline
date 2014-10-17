function r = sresid( ls )
% SRESID cacluates studentized residuals
% Example:
%   load carbig
%   glm = encode( MPG, 3, 2, Origin );
%   r = sresid( mstats( glm ) );
%      given a linear model encoded in glm, solve the equation and pass the
%      results to sresid
% 

hatmat = ls.Q*ls.Q';
h      = diag(hatmat);
s2_i   = -center(scale((ls.resid.*ls.resid),(1-h),2), ls.dfe.*ls.mse )./(ls.dfe-1);
q      = sqrt( s2_i.*repmat(1-h, 1, size(s2_i,2) ) );

r      = ls.resid./q;