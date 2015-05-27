function edgePixelInds = getOtherNodeForPsuedoEdge...
                (nodeInd,psuedoEdges2nodes,edgeID,psuedoEdgeIDs)
            
% returns the other end of the psuedoEdge 

pEdgeLID = find(edgeID==psuedoEdgeIDs);

if(isempty(pEdgeLID))
    error('nodeInd not found in psuedoEdges2nodes!!')
else
    nodes2 = psuedoEdges2nodes(pEdgeLID);
    if(nodes2(1)==nodeInd)
        edgePixelInds = psuedoEdges2nodes(pEdgeLID,2);
    else
        edgePixelInds = psuedoEdges2nodes(pEdgeLID,1);
    end
end