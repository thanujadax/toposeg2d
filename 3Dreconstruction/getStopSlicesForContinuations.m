function stopSlices = getStopSlicesForContinuations(continuationIDs,continuations)
% this method is obsolete if we already have var2slices
% rowID = sliceID, col1=startSliceID, col2=stop1sliceID, col3=stop2sliceID
stopSlices = [];
if(~isempty(continuationIDs))
    numContinuationIDs = numel(continuationIDs);
    % sanity check + debug
    numContinuations = length(continuations);
    
    stopSlices = zeros(numContinuationIDs,1);
    for i = 1:numContinuationIDs
        cID_i = continuationIDs(i);
        if(cID_i>numContinuations)
            error('Problem with continuationIDs!!')
        end
        stopSlices(i) = continuations(continuationIDs(i)).stopSliceID;
    end 
end