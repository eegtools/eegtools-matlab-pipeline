%% tests publish command on a jplot_table command
figure;

subplot( 2,1,1);
[tbl h] = jplot_table( {'a' 'b' 'c' }, randn( 3,3 ) );
subplot( 2,1,2);
jplot_table(tbl);



