function create3Dreconstruction(solutionVector,outputDir,outputFormat,slices,...
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
disp('Creating neuron IDs from link assignments ...')
numSections = numel(slicesPerSection);
numSlices = sum(slicesPerSection);
neuronIDsForSlices = zeros(numSlices,1); % rowID: sliceID
slicesInNeuronID = zeros(numSlices,1); % rowID:neuronID

numEnds = length(ends);
numContinuations = length(continuations);
numBranches = length(branches);
numStates = numEnds + numContinuations + numBranches;

activeStates = find(solutionVector);
str1 = sprintf('Active states: %d',numel(activeStates));
disp(str1)
activeEnds = find(solutionVector(1:numEnds));
activeContinuations = find(solutionVector((numEnds+1):(numEnds+numContinuations)));
activeBranches = find(solutionVector(...
    (numEnds+numContinuations+1):(numStates)));

numSlices = length(slices2var);
neuronCounter = 0;
partnerCollector = [];

for i=1:numSlices
    % str1 = sprintf('Processing link variables of slice %d',i);
    % disp(str1)
    % look at all the link variables starting from this slice
    % keep track of the slices that are already linked to something in a
    % previous slice so that isolate slices can be painted as well
    sliceNotConnected  = 1;
    varIDs_slice = slices2var{i};
    activeVarIDs_slice = intersect(activeStates,varIDs_slice);
    % disp('Active variableIDs for this slice:')
    % disp(activeVarIDs_slice)
    
    % get continuations
    continuationVarIDs_slice = intersect...
        (activeVarIDs_slice,continuationVarIDs);
    continuationStartSliceIDs_i = var2slices(continuationVarIDs_slice,1);
    continuationStopSliceIDs_i = var2slices(continuationVarIDs_slice,2);
    % find the partner
    if(~isempty(continuationVarIDs_slice))
        % disp('.. active continuation found for this slice')
        partnerCollector = [partnerCollector continuationStartSliceIDs_i' continuationStopSliceIDs_i'];
        % assign the same neuron ID
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
            (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
            i,continuationStopSliceIDs_i);
        sliceNotConnected = 0;
    end
    % get branches
    branchVarIDs_slice = intersect...
        (activeVarIDs_slice,branchVarIDs);
    branchStartSliceIDs_i = var2slices(branchVarIDs_slice,1);
    branchStop1SliceIDs_i = var2slices(branchVarIDs_slice,2);
    branchStop2SliceIDs_i = var2slices(branchVarIDs_slice,3);
    if(~isempty(branchVarIDs_slice))
        % disp('.. active branch found for this slice')
        % find partners
        partnerCollector = ...
        [partnerCollector branchStartSliceIDs_i' branchStop1SliceIDs_i' branchStop2SliceIDs_i'];
        % assign the same neuron ID
        [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = assignNeuronIDs...
            (neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
            i,[branchStop1SliceIDs_i; branchStop2SliceIDs_i]);
        sliceNotConnected = 0;
    end
    % TODO: what about end slices that are not previously connected to anything?
    % partnerCollector has all the slices that are end partners. We extract
    % isolate slices using this.
    if(sliceNotConnected)
        % disp('.. active end found for this slice')
        % assign a neuronID if it already doesn't have one
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
str1 = sprintf('Number of active ends: %d',numel(activeEnds));
disp(str1);
str1 = sprintf('Number of active continuations: %d',numel(activeContinuations));
disp(str1);
str1 = sprintf('Number of active branches: %d',numel(activeBranches));
disp(str1);
%% paint each section with the slices of each neuron having a unique color
% create a unique color for each neuronID
disp('Drawing output segmentation ...')
neuronIDs = unique(neuronIDsForSlices);
numNeurons = numel(neuronIDs);
neuronR = rand(numNeurons,1);
neuronG = rand(numNeurons,1);
neuronB = rand(numNeurons,1);
k = 0;
disp('Saving output segmentation as images ...')
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
    outputDir,outputFormat);
end
disp('Done!')
 
