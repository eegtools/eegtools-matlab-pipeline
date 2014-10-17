%% test vtable

row_names = {'a', 'b', 'c', 'd', 'e'};
col_names = {'1', '2', '3', '4', '5'};
ndata     = magic(5);

T0 = vtable( row_names, col_names, ndata );
T1 = vtable( row_names, col_names(1:3), row_names, row_names );
T2 = vtable( row_names, [], row_names, ndata, row_names );
T3 = vtable( [], [], row_names, ndata );
T4 = vtable( row_names, [], ndata, ndata );