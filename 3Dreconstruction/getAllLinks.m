function [ends,continuations,branches] = getAllLinks(slices,slicesPerSection)
% define variables
% We define 3 types of variables for the optimization task. All variables
% are links between slices of adjacent sections
% 1. continuations: one-to-one link
% 2. ends: slice has no continuation to the next section
% 3. branches: this slice has two continuations into the next section

% Outputs:

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

numSlices = sum(slicesPerSection);

ends = struct([]);
continuations = struct([]);
branches = struct([]);

% counters
variableID = 0;
continuationsID = 0;
endsID = 0;
branchesID = 0;

for i=1:numSlices
    % define ends for this slice
    [ends,variableID,endsID] = updateEnds...
        (ends,i,variableID,endsID,slices(i).pixelInds);
    % get the overlapping partners for this slice
    overlapSlices = slices(i).overlapSlices;
    minOverlaps = slices(i).minOverlaps;
    % define continuations with each overlapping partner
    [continuations,variableID,continuationsID] = updateContinuations...
                (continuations,i,variableID,continuationsID,overlapSlices,...
                minOverlaps);
    % define branches with each unique pair of overlapping partners
    [branches,variableID,branchesID] = updateBranches...
                (branches,i,variableID,branchesID,overlapSlices,minOverlaps);
end