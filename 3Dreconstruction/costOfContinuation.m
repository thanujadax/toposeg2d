function f = costOfContinuation(continuations,cID,w1,w2,w3)

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID
%  continuations.minOverlap
%  continuations.maxOverlap
%  continuations.sizeDifference

f = zeros(3,1);
f(1) = continuations(cID).minOverlap * w1;
f(2) = continuations(cID).maxOverlap * w2;
f(3) = continuations(cID).sizeDifference * w3;