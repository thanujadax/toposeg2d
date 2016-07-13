function [branches,variableID,branchesID] = updateBranches...
                (branches,startSliceID,variableID,branchesID,...
                overlapSlices,minOverlaps)

if(~isempty(overlapSlices))
    numOverlaps = numel(overlapSlices);
    numBranches = nchoosek(numOverlaps,2);
    endCombinations = nchoosek(overlapSlices,2);
    overlapCombinations = nchoosek(minOverlaps,2);
    % each row gives two elements which are the sliceIDs of the 2 ends
    for i=1:numBranches
        
        variableID = variableID + 1;
        branchesID = branchesID + 1;

        branches(branchesID).variableID = variableID;
        branches(branchesID).startSliceID = startSliceID;
        branches(branchesID).stopSlice1ID = endCombinations(i,1);
        branches(branchesID).stopSlice2ID = endCombinations(i,2);
        branches(branchesID).minOverlap = sum(overlapCombinations(i,:));
    end 
end