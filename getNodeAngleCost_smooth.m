function nodeAngleCost = getNodeAngleCost_smooth(alpha,gsigma)

% the node cost for a node with an angle b between the two active edges
% concerned:
% cost = f(b) = Gaussian(alpha1,alpha2)
% perform this calculation for all nodes in matrix alpha and return the
% values in matrix nodeAngleCost. Each row is the individual node, and each
% column is a different node configuration

% Input
% alpha is a matrix with each row being a different node and each column is
% a different edge. Thus, each element is the angle (alpha) of the edge
% position of the graph relative to the current node.

% gsigma - spread for the gaussian function used to calculate the
% smoothness score 

[numNodes,numEdgesPerNode] = size(alpha);

if(alpha==0)
    nodeAngleCost = nan;
    % nodeAngleCost = 0;	
else
    if(numEdgesPerNode>0)
        numCombinations = nchoosek(numEdgesPerNode,2);
        edgeIDvect = 1:numEdgesPerNode;
        combinations = nchoosek(edgeIDvect,2);

        nodeAngleCost = zeros(numNodes,numCombinations);
        for i=1:numNodes
            for j=1:numCombinations
                edge1LInd = combinations(j,1);
                edge2LInd = combinations(j,2);
                alpha1 = alpha(i,edge1LInd);
                alpha2 = alpha(i,edge2LInd);
                nodeAngleCost(i,j) = angleSmoothness(alpha1,alpha2,gsigma);
            end 
        end

    else
        nodeAngleCost = 0;
    end
end
