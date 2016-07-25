function [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
    updateNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
    allPartnerSliceIDs,partnerNeuronIDs,currentSliceID,currentSliceNID)

% current slice and all its partners should be given the same neuronID
if(currentSliceNID>0)
    % assign this to all the connected partner slices
    newID = currentSliceNID;
    if(~isempty(allPartnerSliceIDs))
    [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID,...
            allPartnerSliceIDs);
    end
elseif(~isempty(partnerNeuronIDs))
    nids = partnerNeuronIDs(partnerNeuronIDs>0);
    if(~isempty(nids))
        newID = nids(1);
        % assign this to everything connected to the current slice
        [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID,...
            [allPartnerSliceIDs; currentSliceID]);
    end
else
    % current slice has no neuronID. it's partners also have no neuronID.
    % So assign the current slice and all it's partners a new neuronID
    neuronCounter = neuronCounter + 1; % newID
    newID = neuronCounter;
    [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID,...
            [allPartnerSliceIDs; currentSliceID]);
end

    