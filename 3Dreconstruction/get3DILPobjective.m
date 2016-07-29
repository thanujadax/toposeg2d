function f =  get3DILPobjective(weights,ends,continuations,branches,endSizeCostOffset)

% stateVector f: [ends continuations branches] - not in this order. The
% order is determined by the indivicual variableIDs assigned at the time of
% extracting the link variables

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
% variables are not in the order of ends,continuations,branches
% each of ends, continuations and branches have a field .variableID
% arrange them in that order in the objective

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

f = zeros(numStates,1);

eSizeW = weights(1);
cMinOverlapW = weights(2);
cMaxOverlapW = weights(3);
cSizeDiffW = weights(4);
bMinOverlapW = weights(5);
bMaxOverlapW = weights(6);
bSizeDiffW = weights(7);


% ends
for i = 1:numEnds
    j = ends(i).variableID;
    f(j) = eSizeW * (ends(i).numPixels + endSizeCostOffset);
end

% continuations
for i = 1:numContinuations
    j = continuations(i).variableID;
    % f(j) = weights(2) * continuations(i).minOverlap;
    f(j) = costOfContinuation(continuations,i,cMinOverlapW,cMaxOverlapW,cSizeDiffW);
end

% branches
for i = 1:numBranches
    j = branches(i).variableID;
    % f(j) = weights(3) * branches(i).minOverlap;
    f(j) = costOfContinuation(continuations,i,bMinOverlapW,bMaxOverlapW,bSizeDiffW);
end