function psuedoEdges2nodeLIDs = getNodeLIDsForNodeIDs(psuedoEdges2nodes,nodeInds)

% numPsEdges = size(psuedoEdges2nodes,1);
% 
% psNodeIndsVect = reshape(psuedoEdges2nodes,numel(psuedoEdges2nodes),1);
% 
% [~,~,psNodeListIndsVect] = intersect(nodeInds,psNodeIndsVect);
% 
% psuedoEdges2nodeLIDs = reshape(psNodeListIndsVect,numPsEdges,2);

psuedoEdges2nodeLIDs = psuedoEdges2nodes;

for i=1:numel(psuedoEdges2nodes)
    nodeLID = find(nodeInds==psuedoEdges2nodes(i));
    if(~isempty(nodeLID))
        psuedoEdges2nodeLIDs(i) = nodeLID;
    else
        error('Node pixel not found in nodeInds !!')
    end
end