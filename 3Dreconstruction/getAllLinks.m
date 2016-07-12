function [continuations,stops,branches] = getAllLinks(slices)
% define variables
% We define 3 types of variables for the optimization task. All variables
% are links between slices of adjacent sections
% 1. continuations: one-to-one link
% 2. stops: slice has no continuation to the next section
% 3. branches: this slice has two continuations into the next section

% Outputs:
%   continuations.variableID
%   continuations.startSliceID
%   continuations.stopSliceID

%  stops.variableID
%  stops.startSliceID

%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID
