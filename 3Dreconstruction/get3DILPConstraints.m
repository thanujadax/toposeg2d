function [constraintsA, constraintsB, constraintsSense, slice2var] = ...
    get3DILPConstraints(ends,continuations,branches,numSlices)

%  ends.variableID
%  ends.startSliceID
%  ends.numPixels

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID
%  continuations.minOverlap
%  continuations.sizeDifference


%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID
%  branches.minOverlap

slice2var = cell(numSlices,1);
% stores the varIDs corresponding to each sliceID in a cell array

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);

for i=1:numEnds
    sliceID = ends(i).startSliceID;
    varID = ends(i).variableID;
    slice2var{sliceID}(end+1) = varID;
end

for i=1:numContinuations
    sliceID = continuations(i).startSliceID;
    varID = continuations(i).variableID;
    slice2var{sliceID}(end+1) = varID;
end

for i=1:numBranches
    sliceID = branches(i).startSliceID;
    varID = branches(i).variableID;
    slice2var{sliceID}(end+1) = varID;
end

%% constraint 1
% For a given slice, only one link variable (varID) can be active
numConstraints = numSlices;
numStates = numEnds + numContinuations + numBranches;

constraintsA = sparse(numConstraints,numStates);
constraintsB = ones(numConstraints,1);
constraintsSense(1:numConstraints) = '=';

for i=1:numSlices
    sliceStates = slice2var{i};
    constraintsA(i,sliceStates) = 1;
end
