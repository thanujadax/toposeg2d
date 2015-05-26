function psuedoEdgeIDs = getPsuedoEdgeLID...
                (thisNodeIndex,psuedoEdgeIDs,psuedoEdges2nodes)
                
% if thisNode has any psuedo edges attached to it, return the corresponding
% psuedo edge ID. else return zero.

[r,c] = find(psuedoEdges2nodes==thisNodeIndex);

if(~isempty(r))
    psuedoEdgeIDs = psuedoEdgeIDs(r);
else
    psuedoEdgeIDs = 0;
end