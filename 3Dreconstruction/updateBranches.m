function [branches,variableID,branchesID,var2slices] = updateBranches...
                (branches,startSliceID,variableID,branchesID,...
                overlapSlices,overlapSliceLabels,minOverlaps,maxOverlaps,...
                sizeDifferences,var2slices,originalLabel)

if(~isempty(overlapSlices))
    numOverlaps = numel(overlapSlices);
    if(numOverlaps>1)
        numBranches = nchoosek(numOverlaps,2);
        endCombinations = nchoosek(overlapSlices,2);
        minOverlapCombinations = nchoosek(minOverlaps,2);
        maxOverlapCombinations = nchoosek(maxOverlaps,2);
        sizeDifferenceCombinations = nchoosek(sizeDifferences,2);
        
        overlapSliceLabelCombinations = nchoosek((1:numOverlaps),2);

    % each row gives two elements which are the sliceIDs of the 2 ends
        for i=1:numBranches

            variableID = variableID + 1;
            branchesID = branchesID + 1;

            branches(branchesID).variableID = variableID;
            branches(branchesID).startSliceID = startSliceID;
            branches(branchesID).stopSlice1ID = endCombinations(i,1);
            branches(branchesID).stopSlice2ID = endCombinations(i,2);
                       
            endSlice1label = overlapSliceLabels(overlapSliceLabelCombinations(i,1),:);
            endSlice2label = overlapSliceLabels(overlapSliceLabelCombinations(i,2),:);
            
            branches(branchesID).isSameLabel = ...
            (isequal(endSlice1label,originalLabel) && ...
            isequal(endSlice2label,originalLabel));
            
            branches(branchesID).minOverlap = sum(minOverlapCombinations(i,:));
            branches(branchesID).maxOverlap = sum(maxOverlapCombinations(i,:));
            branches(branchesID).sizeDifference = sum(sizeDifferenceCombinations(i,:));

            var2slices(variableID,1) = startSliceID;
            var2slices(variableID,2) = endCombinations(i,1);
            var2slices(variableID,3) = endCombinations(i,2);
        end
    end
end