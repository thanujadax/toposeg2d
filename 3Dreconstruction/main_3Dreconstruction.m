% Given a set of 2D neuron segments corresponding to serial sections, this
% method reconstructs the dense 3D circuits using an integer linear program

% version 0.1 
% 2016.07.11

%% Inputs
inputDir = '/home/thanuja/projects/data/toyData/set8.2';
outputDir = '/home/thanuja/projects/RESULTS/3Dreconstructions/20160711';
%% Params
overlapRadius = 100; % radius (px) to search for overlapping slices on adjacent sections
%% 

inputFileList = dir(fullfile(inputDir,'*.tif'));
numFiles = length(inputfileList);
slices = struct([]); % row vector of slice-structures
% 'slices' is a structure array with the following fields
%       slices(i).sectionID
%       slices(i).sliceID
%       slices(i).pixelInds
slicesPerSection = zeros(numFiles,1);
for i=1:numFiles
% get slices from input 2D segments
    imageFileName = fullfile(inputDir,inputFileList(i).name);
    sectionID = sprintf('%03d',i);
    slicesNext = getSlicesFromSection(imageFileName,sectionID);
    % returns a structure array containing slices for the given section
    slices = [slices, slicesNext];
    slicesPerSection = length(slicesNext);
end
[sizeR,sizeC] = size(imread(imageFileName));
% get overlapping slices in the next section and add it in a new field of
% the slices structure
% 'overlapSlices',[] - contains absolute sliceIDs)
slices = getOverlappingSlices(...
            slices,slicesPerSection,searchRadius,sizeR,sizeC);

% define variables
% We define 3 types of variables for the optimization task. All variables
% are links between slices of adjacent sections
% 1. ends: slice has no continuation to the next section
% 2. continuations: one-to-one link
% 3. branches: this slice has two continuations into the next section
[continuations,stops,branches] = getAllLinks(slices,slicesPerSection);
%  ends.variableID
%  ends.startSliceID

%  continuations.variableID
%  continuations.startSliceID
%  continuations.stopSliceID

%  branches.variableID
%  branches.startSliceID
%  branches.stopSlice1ID
%  branches.stopSlice2ID

%% ILP
% ilpObjective =  get3DILPobjective();
% [constraintsA, constraintsB, constraintsSense] = get3DILPConstraints();
% solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,constraintsB,...
%                 constraintSense);
%             
% create3Dreconstruction(solutionVector,outputDir);
