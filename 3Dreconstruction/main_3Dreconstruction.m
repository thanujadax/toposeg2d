% Given a set of 2D neuron segments corresponding to serial sections, this
% method reconstructs the dense 3D circuits using an integer linear program

% version 0.1 
% 2016.07.11

%% Inputs
% inputDir = '/home/thanuja/projects/RESULTS/contours/20160721/000/png';
% inputDir = '/home/thanuja/projects/data/toyData/set8/groundtruth';
% inputDir = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/em_2013january/groundTruth/neurons';
inputDir = '/home/thanuja/projects/data/synthetic/set01/png';
outputDir = '/home/thanuja/projects/RESULTS/3Dreconstructions/20160808sbmrm';
inputFormat = 'png';
outputFormat = 'png';
maxInputFiles = 6;

produceSbmrmFiles = 1; 
if(produceSbmrmFiles)
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('SBMRM file generation mode .....')
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end

%% Params

% Linear weights for the objective function
% ends:
% eSizeW = weights(1);
% continuations:
% cMinOverlapW = weights(2);
% cMaxOverlapW = weights(3);
% cSizeDiffW = weights(4);
% branches:
% bMinOverlapW = weights(5);
% bMaxOverlapW = weights(6);
% bSizeDiffW = weights(7);

weights = [100000; 
    0; -10000; 0;
    0; -100; 0];

endSizeCostOffset = 1000000;
% endCosts(i) = eSizeW * (ends(i).numPixels + endSizeCostOffset);

overlapRadius = 100; % radius (px) to search for overlapping slices on adjacent sections
%% 

inputFileList = dir(fullfile(inputDir,strcat('*.',inputFormat)));
numFiles = length(inputFileList);
slices = struct([]); % row vector of slice-structures
% 'slices' is a structure array with the following fields
%       slices(i).sectionID
%       slices(i).sliceID
%       slices(i).pixelInds
%       slices(i).overlapSlices,[] - contains absolute sliceIDs. filled in
%       later
%       slices(i).overlapSliceLabels - original segmentIDs for sbmrm with
%       GT
%       slices(i).minOverlaps,[] - min overlap fraction, filled in later
%       slices(i).originalLabel - assigned by the inifoundtial 2D input
%       segmentation. Useful for groundtruth datasets for sbmrm

str1 = sprintf('Number of input files found: %d',numFiles);
disp(str1)

numFilesToUse = min(maxInputFiles,numFiles);
str1 = sprintf('Number of input files to be used: %d',numFilesToUse);
disp(str1)

slicesPerSection = zeros(numFilesToUse,1);

for i=1:numFilesToUse
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
[sizeR,sizeC,sizeZ] = size(imread(imageFileName));
% get overlapping slices in the next section and add it in a new field of
% the slices structure
% 'overlapSlices',[] - contains absolute sliceIDs
% 'minOverlaps', [] - fractions 
% 'maxOverlaps', [] - fractions 
% 'sizeDifferences', [] - fractions
disp('Detecting overlapping slices ...')
slices = getOverlappingSlices(...
            slices,slicesPerSection,overlapRadius);

% define variables
% We define 3 types of variables for the optimization task. All variables
% are links between slices of adjacent sections
% 1. ends: slice has no continuation to the next section
% 2. continuations: one-to-one link
% 3. branches: this slice has two continuations into the next section
disp('Extracting link variables ...')
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
disp('Defining ILP constraints ...')
[constraintsA, constraintsB, constraintsSense, slices2var] = get3DILPConstraints...
                        (ends,continuations,branches,length(slices));
                    
if(produceSbmrmFiles)
    disp('Generating ILP linear objective for gold standard calculation ...')
    sbmrmObjective = ...
        get3DILPobjectiveSBMRM(ends,continuations,branches,endSizeCostOffset);
    disp('************************************************')
    disp('Solving ILP to get gold standard solution vector')
    disp('************************************************')
    solutionVector = solve3DILPGurobi(sbmrmObjective,constraintsA,constraintsB,...
                constraintsSense);
    weights = [1 1 1 1 1 1 1]; 
    % also writes the features.txt file for sbmrm
    disp('Generating ILP feature vector (objective) with weights = 1 ...')
     ilpObjective = ...
        get3DILPobjective(weights,ends,continuations,branches,...
        endSizeCostOffset,produceSbmrmFiles,outputDir);
    
    % write the sbmrm input files to the output directory
    disp('Writing labels.txt for SBMRM ...')
    labels = writeLabelsFile(solutionVector,outputDir);
    disp('Writing constraints.txt for SBMRM ...')
    constraints = writeConstraintsFile...
        (constraintsA,constraintsB,constraintsSense,outputDir);
    
else
    ilpObjective = ...
        get3DILPobjective(weights,ends,continuations,branches,...
        endSizeCostOffset,produceSbmrmFiles,outputDir);
    solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,constraintsB,...
                constraintsSense);
end

% Draw the 3D reconstruction    
disp('Painting 3D reconstruction ...')
create3Dreconstruction(solutionVector,outputDir,outputFormat,slices,...
    slicesPerSection,slices2var,ends,continuations,branches,sizeR,sizeC,...
    var2slices);
