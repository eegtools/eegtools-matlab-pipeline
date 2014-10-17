%% the properties of trace


%% Definition
%  trace of a matrix is defined as the sum of the diagnol elements
%
pos = [0 0 1 1];
figure,

xpos = .03; ypos = .9;
text( xpos, ypos, 'defintion $tr \mathbf{A} = \sum{a_{ii}}$', 'interpreter', 'latex', 'fontsize', 20 );

set( gca, 'pos', pos, 'xtick', [], 'ytick', [] );

%% properites
figure
text( xpos, ypos, 'properties', 'interpreter', 'latex', 'fontsize', 20 );
text( xpos+.03, ypos-.1, 'for $\mathbf{A}_{pxp}$  $\mathbf{B}_{pxp}$  $\mathbf{C}_{pxn}$  $\mathbf{D}_{nxp}$  and scalar $\alpha$', 'interpreter', 'latex', 'fontsize', 16 );
text( xpos+.03, ypos-.18, 'tr $\alpha = \alpha$,  tr $\mathbf{A}\pm\mathbf{B}$ = tr $\mathbf{A} \pm tr \mathbf{B}$, tr $\alpha\mathbf{A} = \alpha$ tr $\mathbf{A}$' , 'interpreter', 'latex', 'fontsize', 16 );
text( xpos+.03, ypos-.26, 'tr $\mathbf{CD}$ = tr $\mathbf{DC}$' , 'interpreter', 'latex', 'fontsize', 16 );
text( xpos+.03, ypos-.34, '$\sum\mathbf{x''_iA}$ $\mathbf{x_i}$ = tr($\mathbf{AT}$), where $\mathbf{T}$ = $\sum\mathbf{x_ix''_i}$' , 'interpreter', 'latex', 'fontsize', 16 );
set( gca, 'pos', pos, 'xtick', [], 'ytick', [] );


%% Examples
p = 3; n = 2; A = rand(p,p); B = rand(p,p); C = rand(p,n); D = rand(n,p);
figure
pfmt = [repmat( '%.2f ', 1, p ) '\n'];
nfmt = [repmat( '%.2f ', 1, n ) '\n'];
text( xpos, ypos, 'Examples', 'interpreter', 'latex', 'fontsize', 20 );
text( xpos+.03, ypos-.2, 'C = '); text( xpos+.09, ypos-.22, sprintf( nfmt, C') ); text( xpos+.29, ypos-.18, ['    tr $\mathbf{C}$ = ' num2str(trace(C))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.4, 'D = '); text( xpos+.09, ypos-.41, sprintf( pfmt, D') ); text( xpos+.29, ypos-.38, ['    tr $\mathbf{D}$ = ' num2str(trace(D))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.6, 'CD = '); text( xpos+.09, ypos-.62, sprintf( pfmt, (C*D)') ); text( xpos+.29, ypos-.58, ['    tr $\mathbf{CD}$ = ' num2str(trace(C*D))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.8, 'DC = '); text( xpos+.09, ypos-.82, sprintf( nfmt, (D*C)') ); text( xpos+.29, ypos-.78, ['    tr $\mathbf{DC}$ = ' num2str(trace(D*C))], 'interpreter', 'latex', 'fontsize', 14 );


%% More Examples
figure
pfmt = [repmat( '%.2f ', 1, p ) '\n'];
nfmt = [repmat( '%.2f ', 1, n ) '\n'];
text( xpos, ypos, 'Examples', 'interpreter', 'latex', 'fontsize', 20 );
text( xpos+.03, ypos-.2, 'C = '); text( xpos+.09, ypos-.22, sprintf( nfmt, C') ); text( xpos+.29, ypos-.18, ['    tr $\mathbf{A}$ = ' num2str(trace(A))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.4, 'D = '); text( xpos+.09, ypos-.41, sprintf( pfmt, D') ); text( xpos+.29, ypos-.38, ['    tr $\mathbf{B}$ = ' num2str(trace(B))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.6, 'CD = '); text( xpos+.09, ypos-.62, sprintf( pfmt, (C*D)') ); text( xpos+.29, ypos-.58, ['    tr $\mathbf{A+B}$ = ' num2str(trace(A+B))], 'interpreter', 'latex', 'fontsize', 14 );
text( xpos+.03, ypos-.8, 'DC = '); text( xpos+.09, ypos-.82, sprintf( nfmt, (D*C)') ); text( xpos+.29, ypos-.78, ['    tr $\mathbf{A} + $ tr $\mathbf{B}$ = ' num2str(trace(A) + trace(B))], 'interpreter', 'latex', 'fontsize', 14 );
