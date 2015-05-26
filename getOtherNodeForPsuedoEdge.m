function edgePixelInds = getOtherNodeForPsuedoEdge...
                (nodeInd,psuedoEdges2nodes)
            
% returns the other end of the psuedoEdge 

[r,c] = find(psuedoEdges2nodes==nodeInd);

if(isempty(r))
    error('nodeInd not found in psuedoEdges2nodes!!')
else
    if(c==1)
        edgePixelInds = psuedoEdges2nodes(r,2);
    else
        edgePixelInds = psuedoEdges2nodes(r,1);
    end
end