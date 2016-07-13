function [continuations,variableID,continuationsID] = updateContinuations...
                (continuations,startSliceID,variableID,continuationsID,...
                overlapSlices,minOverlaps)

if(~isempty(overlapSlices))
    for i=1:numel(overlapSlices)
        
        variableID = variableID + 1;
        continuationsID = continuationsID + 1;

        continuations(continuationsID).variableID = variableID;
        continuations(continuationsID).startSliceID = startSliceID;
        continuations(continuationsID).stopSliceID = overlapSlices(i);
        continuations(continuationsID).minOverlap = minOverlaps(i);
    end 
end