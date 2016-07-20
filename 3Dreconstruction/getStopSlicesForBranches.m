function stopSlices = getStopSlicesForBranches(branchIDs,branches)

stopSlices = [];
if(~isempty(branchIDs))
    numBranchIDs = numel(branchIDs);
    stopSlices = zeros((numBranchIDs*2),1); % each branch has 2 stop slices
    k=0;
    for i = 1:numBranchIDs
        k = k+1;
        stopSlices(k) = branches(branchIDs(i)).stopSlice1ID;
        k = k+1;
        stopSlices(k) = branches(branchIDs(i)).stopSlice2ID;
    end 
    stopSlices = unique(stopSlices);
end

