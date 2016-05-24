function [adjacencyMat, edges2nodes,selfEdgeIDs,nodelessEdgeIDs,listOfEdgeIDs]...
    = getAdjacencyMat(nodeEdges)
% Input:
%   nodeEdges: gives the list of edgeIDs connected to each junction node
%       each row is -> junctionInd,edge1, edge2, edge3, edge4, ..
[numNodes, numEdgesPerNode] = size(nodeEdges);
adjacencyMat = zeros(numNodes);

numEdges = max(max(nodeEdges(:,2:numEdgesPerNode)));
edges2nodes = zeros(numEdges,2);

selfEdgeIDs = [];
nodelessEdgeIDs = [];
listOfEdgeIDs = [];
for i=1:numEdges
    % for each edge, find the two corresponding nodes at its ends
    [R,C] = find(nodeEdges(:,2:numEdgesPerNode)==i);
    % R has the list indices of the junctions corresponding to edge i (R =
    % nodeListIndsForEdge
    % usually an edge has two nodes attached. therefore,
    if(numel(R)==2)
        % assign to adjacencyMat
        % nodeIndsForEdge = nodeEdges(R,1);
        % j1 = find(nodeEdges(:,1)==nodeIndsForEdge(1)); % = R(1)
        % j2 = find(nodeEdges(:,1)==nodeIndsForEdge(2)); % = R(2)       
        j1 = R(1);
        j2 = R(2);
        if(j1~=j2)
            % assign edgeId to the adjMat
            adjacencyMat(j1,j2) = i; 
            adjacencyMat(j2,j1) = i;
            % also add the entries to edges2nodes
            edges2nodes(i,1) = j1;  % should we use i or k??. i since we need to collect the nodes for each edgeID
            edges2nodes(i,2) = j2;
            % also, add the edgeID to the listOfEdgeIDs
            listOfEdgeIDs(end+1) = i;
        else
            
            selfEdgeIDs(end+1) = i;
        end
    elseif(numel(R)==1)
        % if 1, it contains a self edge.
        % disp('warning:getAdjacencyMat - edge skipped')       
        
        selfEdgeIDs(end+1) = i;
        
    elseif(numel(R)==0)
        % disp('warning:getAdjacencyMat - edge skipped')
        % i
        % sid = sid + 1;
        % selfEdgeIDs(sid) = i;
        nodelessEdgeIDs(end+1) = i;
        str1 = sprintf('warning: nodeless: edgeID %d not found in nodeEdges!',i);
        disp(str1)
    else
        error('edgeID %d found in more than 2 nodes in nodeEdges!',i);       
    end
end