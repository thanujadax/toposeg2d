function [continuations,variableID,continuationsID,var2slices] = updateContinuations...
                (continuations,startSliceID,variableID,continuationsID,...
                overlapSlices,minOverlaps,maxOverlaps,sizeDifferences,var2slices)

if(~isempty(overlapSlices))
    for i=1:numel(overlapSlices)
        
        variableID = variableID + 1;
        continuationsID = continuationsID + 1;

        continuations(continuationsID).variableID = variableID;
        continuations(continuationsID).startSliceID = startSliceID;
        continuations(continuationsID).stopSliceID = overlapSlices(i);
        continuations(continuationsID).minOverlap = minOverlaps(i);
        continuations(continuationsID).maxOverlap = maxOverlaps(i);
        continuations(continuationsID).sizeDifference = sizeDifferences(i);
        
        var2slices(variableID,1) = startSliceID;
        var2slices(variableID,2) = overlapSlices(i);
    end 
end