function stopSlices = getStopSlicesForContinuations(continuationIDs,continuations)

stopSlices = [];
if(~isempty(continuationIDs))
    numContinuationIDs = numel(continuationIDs);
    stopSlices = zeros(numContinuationIDs,1);
    for i = 1:numContinuationIDs
        stopSlices(i) = continuations(continuationIDs(i)).stopSliceID;
    end 
end