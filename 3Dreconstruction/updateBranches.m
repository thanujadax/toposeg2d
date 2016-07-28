function [branches,variableID,branchesID,var2slices] = updateBranches...
                (branches,startSliceID,variableID,branchesID,...
                overlapSlices,minOverlaps,maxOverlaps,sizeDifferences,var2slices)

if(~isempty(overlapSlices))
    numOverlaps = numel(overlapSlices);
    if(numOverlaps>1)
        numBranches = nchoosek(numOverlaps,2);
        endCombinations = nchoosek(overlapSlices,2);
        minOverlapCombinations = nchoosek(minOverlaps,2);
        maxOverlapCombinations = nchoosek(maxOverlaps,2);
        sizeDifferenceCombinations = nchoosek(sizeDifferences,2);

    % each row gives two elements which are the sliceIDs of the 2 ends
        for i=1:numBranches

            variableID = variableID + 1;
            branchesID = branchesID + 1;

            branches(branchesID).variableID = variableID;
            branches(branchesID).startSliceID = startSliceID;
            branches(branchesID).stopSlice1ID = endCombinations(i,1);
            branches(branchesID).stopSlice2ID = endCombinations(i,2);
            branches(branchesID).minOverlap = sum(minOverlapCombinations(i,:));
            branches(branchesID).maxOverlap = sum(maxOverlapCombinations(i,:));
            branches(branchesID).sizeDifference = sum(sizeDifferenceCombinations(i,:));

            var2slices(variableID,1) = startSliceID;
            var2slices(variableID,2) = endCombinations(i,1);
            var2slices(variableID,3) = endCombinations(i,2);
        end
    end
end