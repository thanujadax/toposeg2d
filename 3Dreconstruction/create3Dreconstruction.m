function create3Dreconstruction(solutionVector,outputDir,slices,...
    slicesPerSection,slices2var,ends,continuations,branches,...
sizeR,sizeC,var2slices)

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
[endVarIDs,continuationVarIDs,branchVarIDs] = varIDTypes...
    (var2slices,length(ends),length(continuations),length(branches));
%% Assign neuron IDs for slices, based on solutionVector
numSections = numel(slicesPerSection);
numSlices = sum(slicesPerSection);
neuronIDsForSlices = zeros(numSlices,1); % rowID: sliceID
slicesInNeuronID = zeros(numSlices,1); % rowID:neuronID

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
    sliceNotConnected  = 1;
    varIDs_slice = slices2var{i};
    activeVarIDs_slice = intersect(activeStates,varIDs_slice);
    % get continuations
    continuationIDs_slice = intersect...
        (activeVarIDs_slice,continuationVarIDs);
    % find the partner
    if(~isempty(continuationIDs_slice))
        continuationIDs_slice = continuationIDs_slice - numEnds;
        stopSlices_continuations = getStopSlicesForContinuations(...
            continuationIDs_slice,continuations);
        partnerCollector = [partnerCollector continuationIDs_slice stopSlices_continuations];
        % assign the same neuron ID
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
            (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
            i,stopSlices_continuations);
        sliceNotConnected = 0;
    end
    % get branches
    branchIDs_slice = intersect...
        (activeVarIDs_slice,branchVarIDs);
    if(~isempty(branchIDs_slice))
        % find partners
        branchIDs_slice = branchIDs_slice - numEnds - numContinuations;
        stopSlices_branches = getStopSlicesForBranches(...
            branchIDs_slice,branches);
        partnerCollector = [partnerCollector branchIDs_slice stopSlices_branches'];
        % assign the same neuron ID
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
            (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
            i,stopSlices_branches);
        sliceNotConnected = 0;
    end
    % TODO: what about end slices that are not previously connected to anything?
    % partnerCollector has all the slices that are end partners. We extract
    % isolate slices using this.
    if(sliceNotConnected)
        % assign a neuronID if it already doesn't have one
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = a
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
            (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
            i,[]);
    end
end
% extract isolate slices
partnerCollector = unique(partnerCollector);
isolateSlices = setdiff((1:numSlices),partnerCollector);
if(~isempty(isolateSlices))
    % assign neuronIDs for the isolate slices. and report them!
    disp('******************************************')
    str1 = sprintf('%d ISOLATE SLICES FOUND!!!',numel(isolateSlices));
    disp(str1)
    disp('******************************************')
    [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
        assignNeuronIDsForIsolateSlices(neuronIDsForSlices,...
        slicesInNeuronID,neuronCounter,isolateSlices);
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
    section_i = zeros(sizeR,sizeC,3);
    imR = zeros(sizeR,sizeC);
    imG = zeros(sizeR,sizeC);
    imB = zeros(sizeR,sizeC);
    
    numSlicesInSection = slicesPerSection(i);
    for j=i:numSlicesInSection
        % paint each slice
        k = k+1;
        slicePixels = slices(k).pixelInds;
        neuronID_slice = neuronIDsForSlices(k);
        R = neuronR(neuronIDs==neuronID_slice);
        G = neuronG(neuronIDs==neuronID_slice);
        B = neuronB(neuronIDs==neuronID_slice);
        imR(slicePixels) = R;
        imG(slicePixels) = G;
        imB(slicePixels) = B;
    end
    section_i(:,:,1) = imR;
    section_i(:,:,2) = imG;
    section_i(:,:,3) = imB;
    % save
    saveIntermediateImage(section_i,sprintf('%03d',i),'3Dseg',...
    outputDir);
end

 
