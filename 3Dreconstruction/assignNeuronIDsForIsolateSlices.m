function [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
        assignNeuronIDsForIsolateSlices(neuronIDsForSlices,...
        slicesInNeuronID,neuronCounter,isolateSlices)
    
    
% assign a unique neuronID for each isolate slice - so that they can be
% drawn with a unique color

if(~isempty(isolateSlices))
    numIsoSlices = numel(isolateSlices);
    for i=1:numIsoSlices
        neuronCounter = neuronCounter + 1;
        neuronIDsForSlices(isolateSlices(i)) = neuronCounter;
        slicesInNeuronID(neuronCounter,1) = isolateSlices(i);
    end
end