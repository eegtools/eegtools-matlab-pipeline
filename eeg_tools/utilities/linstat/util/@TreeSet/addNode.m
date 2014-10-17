function ts = addNode( ts, parent, node )
% ADDNODE adds node to the tree as a child of parent
%
% Example
%  ts = deleteNode( ts, p_node, ch_node);
%  ts is class treeset
%  p_node is the value of an existing node in the tree
%  ch_node is a node to be added
%  returns ts a tree with ch_node added as a descendant of p_node

if ts.nextnode == 1
    ts.nodeclass = class(node);
    if ~isempty(parent)
        error('FasMM:TreeSet:addNode', 'set parent null to add root node');
    end
    % the root doesn't get added to the tree
    % add it to the first element in nodes
    ts.nodes{ts.nextnode} = node;
    ts.nextnode = ts.nextnode + 1;
    return;
elseif ~isa(node,ts.nodeclass)
    error('FasMM:TreeSet:addNode', 'class of all nodes must be the same');
end

i = findNode( ts, parent );
if i == 0
    error('FasMM:TreeSet:addNode', 'parent not found');    
end

j = findNode( ts, node );
if j ~= 0
    error('FasMM:TreeSet:addNode', 'duplicate node');
end

ts.nodes{ts.nextnode}    = node;
ts.tree( i, ts.nextnode ) = 1;

ts.nextnode = ts.nextnode + 1;    