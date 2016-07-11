% Given a set of 2D neuron segments corresponding to serial sections, this
% method reconstructs the dense 3D circuits using an integer linear program

%% Inputs
inputDir = '/home/thanuja/projects/data/toyData/set8.2';
outputDir = '/home/thanuja/projects/RESULTS/3Dreconstructions/20160711';

%% Params
overlapRadius = 100; % radius (px) to search for overlapping slices on adjacent sections
%%
inputFileList = dir(fullfile(inputDir,'*.tif'));
numFiles = length(inputfileList);
slices = struct([]);
% 'slices' is a structure array with the following fields
%       slices(i).sectionID
%       slices(i).sliceID
%       slices(i).pixelInds
for i=1:numFiles
% get slices from input 2D segments
    imageFileName = fullfile(inputDir,inputFileList(i).name);
    sectionID = sprintf('%03d',i);
    slicesNext = getSlicesFromSection(imageFileName,sectionID);
    % returns a structure array containing slices for the given section
    slices = [slices, slicesNext];
end

% define variables

%% ILP
% ilpObjective =  get3DILPobjective();
% [constraintsA, constraintsB, constraintsSense] = get3DILPConstraints();
% solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,constraintsB,...
%                 constraintSense);
%             
% create3Dreconstruction(solutionVector,outputDir);