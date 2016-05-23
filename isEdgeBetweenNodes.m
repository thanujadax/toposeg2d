function commonEdgeIDs = isEdgeBetweenNodes...
    (nodePixInd_1,nodePixInd_2,edgePixLabels,connectedJunctionIDs,sizeR,sizeC)

% inputs
% node pixel indices
% edgePixLabels: 1st col: edge pix inds, 2nd col: edgeID

edgeIDs_node1 = getEdgeIDsAttachedToNode(nodePixInd_1,edgePixLabels,...
    connectedJunctionIDs,sizeR,sizeC);

edgeIDs_node2 = getEdgeIDsAttachedToNode(nodePixInd_2,edgePixLabels,...
    connectedJunctionIDs,sizeR,sizeC);

commonEdgeIDs = intersect(edgeIDs_node1,edgeIDs_node2);

