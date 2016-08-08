function [ends,continuations,branches,var2slices] = getAllLinks(slices,slicesPerSection)
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
%  continuations.maxOverlap
%  continuations.sizeDifference
%  continuations.isSameLabel - only makes sense for GT data (sbmrm)

%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID
%  branches.minOverlap
%  branches.maxOverlap
%  branches.sizeDifference
%  branches.isSameLabel - only makes sense for GT data (sbmrm)

numSlices = sum(slicesPerSection);

ends = struct([]);
continuations = struct([]);
branches = struct([]);

% counters
variableID = 0;
continuationsID = 0;
endsID = 0;
branchesID = 0;
var2slices = zeros(1,1);
% each row corresponds to the varID. col1: start slice, col2: stop slice,
% col3: stop slice2

for i=1:numSlices
    % define ends for this slice
    [ends,variableID,endsID,var2slices] = updateEnds...
        (ends,i,variableID,endsID,numel(slices(i).pixelInds),var2slices);
    % get the overlapping partners for this slice
    overlapSlices = slices(i).overlapSlices;
    overlapSliceLabels = slices(i).overlapSliceLabels;
    minOverlaps = slices(i).minOverlaps;
    maxOverlaps = slices(i).maxOverlaps;
    sizeDifferences = slices(i).sizeDifferences;
    originalLabel = slices(i).originalLabel;
    % define continuations with each overlapping partner
    [continuations,variableID,continuationsID,var2slices] = updateContinuations...
                (continuations,i,variableID,continuationsID,overlapSlices,...
                overlapSliceLabels,minOverlaps,maxOverlaps,...
                sizeDifferences,var2slices,originalLabel);
    % define branches with each unique pair of overlapping partners
    [branches,variableID,branchesID,var2slices] = updateBranches...
                (branches,i,variableID,branchesID,overlapSlices,...
                overlapSliceLabels,minOverlaps,maxOverlaps,...
                sizeDifferences,var2slices,originalLabel);
end