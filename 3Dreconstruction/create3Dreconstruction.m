function create3Dreconstruction(solutionVector,outputDir,slices,...
    var2slices,slices2var,ends,continuations,branches,slicesPerSection,...
sizeR,sizeC)

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

% 'slices' is a structure array with the following fields
%       slices(i).sectionID
%       slices(i).sliceID
%       slices(i).pixelInds
%       slices(i).overlapSlices,[] - contains absolute sliceIDs
%       slices(i).minOverlaps,[] - min overlap fraction

% var2slices: matrix. each raw is variableID. col1: startSlice,
% col2:stopslice1, col3: stopslice2

%% Assign neuron IDs for slices, based on solutionVector
numSections = numel(slicesPerSection);
numSlices = sum(slicesPerSection);
neuronIDsForSlices = zeros(numSlices,1); % rowID: sliceID
slicesInNeuronID = zeros(1,1); % rowID:neuronID

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

activeStates = find(solutionVector);
activeEnds = find(solutionVector(1:numEnds));
activeContinuations = find(solutionVector((numEnds+1):(numEnds+numContinuations)));
activeBranches = find(solutionVector(...
    (numEnds+numContinuations+1):(numStates)));

numSlices = length(slices2var);
neuronCounter = 0;
partnerCollector = [];

for i=1:numSlices
    % look at all the link variables starting from this slice
    % keep track of the slices that are already linked to something in a
    % previous slice so that isolate slices can be painted as well
    
    varIDs_slice = slices2var{i};
    activeVarIDs_slice = intersect(activeStates,varIDs_slice);
    % get continuations
    continuationIDs_slice = intersect...
        (activeVarIDs_slice,((numEnds+1):(numEnds+numContinuations)));
    % find the partner
    stopSlices_continuations = getStopSlicesForContinuations(...
        continuationIDs_slice,continuations);
    partnerCollector = [partnerCollector stopSlices_continuations];
    % assign the same neuron ID
    [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
        (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
        i,stopSlices_continuations);
    
    % get branches
    branchIDs_slice = intersect...
        (activeVarIDs_slice,((numEnds+numContinuations+1):(numEnds+numContinuations+numBranches)));
    % find partners
    stopSlices_branches = getStopSlicesForBranches(...
        branchIDs_slice,branches);
    partnerCollector = [partnerCollector stopSlices_branches];
    % assign the same neuron ID
    [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
        (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
        i,stopSlices_branches);
    
    % what about end slices that are not previously connected to anything?
    % partnerCollector has all the slices that are end partners. We extract
    % isolate slices using this.
end
% extract isolate slices
partnerCollector = unique(partnerCollector);
if(~isempty(partnerCollector))
    % assign neuronIDs for the isolate slices. and report them!
end
%% paint each section with the slices of each neuron having a unique color
% create a unique color for each neuronID
neuronIDs = unique(neuronIDsForSlices);
numNeurons = numel(neuronIDs);
neuronR = random(numNeurons,1);
neuronG = random(numNeurons,1);
neuronB = random(numNeurons,1);
k = 0;
for i=1:numSections
    section_i = zeros(sizeR,sizeC);
    numSlicesInSection = slicesPerSection(i);
    for j=i:numSlicesInSection
        % paint each slice
        k = k+1;
        slicePixels = slices(i)
    end
end
