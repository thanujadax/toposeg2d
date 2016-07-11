% Given a set of 2D neuron segments corresponding to serial sections, this
% method reconstructs the dense 3D circuits using an integer linear program

%% Inputs
inputDir = '/home/thanuja/projects/data/toyData/set8.2';
outputDir = '/home/thanuja/projects/RESULTS/3Dreconstructions/20160711';

%% Params

%%

% get slices from input 2D segments
imageFileName = '/home/thanuja/projects/data/toyData/set8.2/groundtruth/00.tif';
sectionID = '00';

c_s_slices = getSlicesFromSection(imageFileName,sectionID);
% returns a structure array containing slices for the given section

% ilpObjective =  get3DILPobjective();
% [constraintsA, constraintsB, constraintsSense] = get3DILPConstraints();
% solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,constraintsB,...
%                 constraintSense);
%             
% create3Dreconstruction(solutionVector,outputDir);