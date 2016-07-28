function f = costOfContinuation(continuations,cID,w1,w2,w3)

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID
%  continuations.minOverlap
%  continuations.maxOverlap
%  continuations.sizeDifference


f = continuations(cID).minOverlap * w1 + ...
    continuations(cID).maxOverlap * w2 + ...
    continuations(cID).sizeDifference * w3;