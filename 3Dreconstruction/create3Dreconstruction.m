function create3Dreconstruction(solutionVector,outputDir,slices,...
    var2slices,slices2var,ends,continuations,branches,sizeR,sizeC)

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
for i=1:numSlices
    varIDs_slice = slices2var{i};
    activeVarIDs_slice = intersect(activeStates,varIDs_slice);
    % get continuation
    continuations_slice = intersect(activeVarIDs_slice,((numEnds+1):(numEnds+numContinuations)));
    % find the partner
    stopSlices_continuations = getStopSlicesForContinuations(continuationIDs,continuations);
    % assign the same neuron ID
    [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs();
    
    % get branch
    % find partners
    % assign the same neuron ID
    
end

