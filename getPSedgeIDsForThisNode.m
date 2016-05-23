function [psEIDs_thisNode,neighborNodeInds] ...
    = getPSedgeIDsForThisNode...
            (thisNodeInd,psuedoEdges2nodes,psuedoEdgeIDs)
        

if (size(psuedoEdges2nodes,1) ~= numel(psuedoEdgeIDs))
    error('Number of psEdges and psNodes2Edges')
end

% check if this node is psEdges2nodes
[psNeighborNodeListInds,c] = find(psuedoEdges2nodes==thisNodeInd);
% get it's partners and the corresponding psEdgeIDs
% in c, replace 1 by 2 and 2 by 1

c = c - 2;
c = c * (-1);
c = c + 1;

psEIDs_thisNode = psuedoEdgeIDs(psNeighborNodeListInds);

neighborNodeInds = psuedoEdges2nodes(psNeighborNodeListInds,c);


