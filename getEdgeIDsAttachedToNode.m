function edgeIDsForNode = getEdgeIDsAttachedToNode...
    (nodePixInd,edgePixLabels,connectedJunctionIDs,sizeR,sizeC)

% edgePixLabels: 1st col: edge pix inds, 2nd col: edgeID
edgeIDsForNode = [];
neighborPixInds = getNeighbors(nodePixInd,sizeR,sizeC);
for i=1:numel(neighborPixInds)
    neighborListInd = find(edgePixLabels(:,1)==neighborPixInds(i));
    if(~isempty(neighborListInd))
        edgeId = edgePixLabels(neighborListInd,2);
        edgeIDsForNode = [edgeIDsForNode; edgeId];
    end
    
end
% check if it has directly neighboring nodes
connectedJInd = find(connectedJunctionIDs(:,1)==nodePixInd);
if(~isempty(connectedJInd))
    % this junction has other directly neighboring junctions
    duplicateLabel = connectedJunctionIDs(connectedJInd,2);
    neighboringCJListInd = find(connectedJunctionIDs(:,2)==duplicateLabel(1));

    numNeighJ = numel(neighboringCJListInd);
    for m=2:numNeighJ      % start with 2 to skip the current junction node
        % for each neighboring junction,
        neighJ_ind = connectedJunctionIDs(neighboringCJListInd(m),1);
        % get its edges and,
        % add its edges to the list of edges under 'thisNodeIndex'
        jNeighborInd = getNeighbors(neighJ_ind,sizeR,sizeC);
        jNeighborInd = jNeighborInd(jNeighborInd~=nodePixInd);
        numJNeighbors = numel(jNeighborInd);
        for j=1:numJNeighbors
            jNeighborListInd = find(edgePixLabels(:,1)==jNeighborInd(j));
            if(~isempty(jNeighborListInd))
                % there's an edge for this neighbor
                % check first, if this edge is already in the list for
                % thisNodeIndex
                edgeId = edgePixLabels(jNeighborListInd,2);
                edgeIDsForNode = [edgeIDsForNode; edgeId];
            end
        end                        
    end
end


edgeIDsForNode = unique(edgeIDsForNode);
