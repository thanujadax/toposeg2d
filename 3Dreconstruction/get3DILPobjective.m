function f =  get3DILPobjective(weights,ends,continuations,branches)

% stateVector f: [ends continuations branches]

%  ends.variableID
%  ends.startSliceID
%  ends.numPixels

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID
%  continuations.minOverlap

%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID
%  branches.minOverlap

% weights = [10; -10; -5];

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

f = zeros(numStates,1);
j = 0;

% ends
for i = 1:numEnds
    j = j+1;
    f(j) = weights(1) * ends(i).numPixels;
end

% continuations
for i = 1:numContinuations
    j = j+1;
    f(j) = weights(2) * continuations(i).minOverlap;
end

% branches
for i = 1:numBranches
    j = j+1;
    f(j) = weights(3) * branches(i).minOverlap;
end