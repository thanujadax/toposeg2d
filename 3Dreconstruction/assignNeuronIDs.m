function [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
        assignNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
        currentSliceID,directPartnerSliceIDs)
    
currentSliceNID = neuronIDsForSlices(currentSliceID);
% do any of its partners have a neuronID?
% If yes, we should make sure this slice and its partners have the same
% neuronID
% should fix partners of partners etc as well
if(~isempty(directPartnerSliceIDs))
    [allPartnerSliceIDs,partnerNeuronIDs] = getAllPartnersNIDs...
        (directPartnerSliceIDs,neuronIDsForSlices,slicesInNeuronID);
else
    allPartnerSliceIDs = [];
    partnerNeuronIDs = [];
end
[neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
    updateNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
    allPartnerSliceIDs,partnerNeuronIDs,currentSliceID,currentSliceNID);