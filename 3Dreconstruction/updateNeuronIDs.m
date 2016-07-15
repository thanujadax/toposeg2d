function [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
    updateNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
    allPartnerSliceIDs,partnerNeuronIDs,currentSliceID,currentSliceNID)

% current slice and all its partners should be given the same neuronID

if(currentSliceNID>0)
    % assign this to all the connected partner slices
    
elseif(~isempty(partnerNeuronIDs))
    nids = partnerNeuronIDs(partnerNeuronIDs>0);
    if(~isempty(nids))
        newID = nids(1);
        % assign this to everything connected to the current slice
        [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID);
    end
else
    
end
    