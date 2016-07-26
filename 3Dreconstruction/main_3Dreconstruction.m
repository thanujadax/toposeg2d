% Given a set of 2D neuron segments corresponding to serial sections, this
% method reconstructs the dense 3D circuits using an integer linear program

% version 0.1 
% 2016.07.11

%% Inputs
inputDir = '/home/thanuja/projects/RESULTS/contours/20160721/000/png';
outputDir = '/home/thanuja/projects/RESULTS/3Dreconstructions/20160711';
outputFormat = 'png';
%% Params
weights = [10; -10; -5];
overlapRadius = 100; % radius (px) to search for overlapping slices on adjacent sections
%% 

inputFileList = dir(fullfile(inputDir,'*.png'));
numFiles = length(inputFileList);
slices = struct([]); % row vector of slice-structures
% 'slices' is a structure array with the following fields
%       slices(i).sectionID
%       slices(i).sliceID
%       slices(i).pixelInds
%       slices(i).overlapSlices,[] - contains absolute sliceIDs. filled in
%       later
%       slices(i).minOverlaps,[] - min overlap fraction, filled in later
slicesPerSection = zeros(numFiles,1);
str1 = sprintf('Number of input files found: %d',numFiles);
disp(str1)

for i=1:numFiles
% get slices from input 2D segments
    imageFileName = fullfile(inputDir,inputFileList(i).name);
    sectionID = sprintf('%03d',i);
    slicesNext = getSlicesFromSection(imageFileName,sectionID);
    % returns a structure array containing slices for the given section
    slices = [slices, slicesNext];
    slicesPerSection(i) = length(slicesNext);
end
str1 = sprintf('Number of slices found: %d',numel(slices));
disp(str1)
imageFileName = fullfile(inputDir,inputFileList(1).name);
[sizeR,sizeC] = size(imread(imageFileName));
% get overlapping slices in the next section and add it in a new field of
% the slices structure
% 'overlapSlices',[] - contains absolute sliceIDs
% 'minOverlaps', [] - fractions 
slices = getOverlappingSlices(...
            slices,slicesPerSection,overlapRadius);

% define variables
% We define 3 types of variables for the optimization task. All variables
% are links between slices of adjacent sections
% 1. ends: slice has no continuation to the next section
% 2. continuations: one-to-one link
% 3. branches: this slice has two continuations into the next section
[ends,continuations,branches,var2slices] = getAllLinks(slices,slicesPerSection);
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

% var2slices: matrix. each raw is variableID. col1: startSlice,
% col2:stopslice1, col3: stopslice2
% The following is done in create3Dreconstruction
% [endVarIDs,continuationVarIDs,branchVarIDs] = varIDTypes...
%     (var2slices,length(ends),length(continuations),length(branches));

%% ILP
% stateVector: [ends continuations branches]
ilpObjective =  get3DILPobjective(weights,ends,continuations,branches);
[constraintsA, constraintsB, constraintsSense, slices2var] = get3DILPConstraints...
                        (ends,continuations,branches,length(slices));
solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,constraintsB,...
                constraintsSense);
%             
create3Dreconstruction(solutionVector,outputDir,outputFormat,slices,...
    slicesPerSection,slices2var,ends,continuations,branches,sizeR,sizeC,...
    var2slices);
