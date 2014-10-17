function ts = deleteNode( ts, node )
% DELETENODE - removes the give node and all direct descendants
%
% Example
%  ts = deleteNode( ts, p_node);
%  ts is class treeset
%  p_node is the value of a node in the tree
%  returns ts a tree with p_node and all descendants removed

% $Id $
% Copyright 2006 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 


i = findNode(ts,node);
if i ~= 0
    [ch j] = getDescendants(ts, node);
    i = [i; j];
    ts.tree(i,:) = 0;
    ts.tree(:,i) = 0;
end


