function [neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
        assignNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
        currentSliceID,directPartnerSliceIDs)
    
currentSliceNID = neuronIDsForSlices(currentSliceID);
% str1 = sprintf('Current slice neuronID: %d',currentSliceNID);
% disp(str1)
% do any of its partners have a neuronID?
% If yes, we should make sure this slice and its partners have the same
% neuronID
% should fix partners of partners etc as well
if(~isempty(directPartnerSliceIDs))
    [allPartnerSliceIDs,partnerNeuronIDs] = getAllPartnersNIDs...
        (directPartnerSliceIDs,neuronIDsForSlices,slicesInNeuronID);
%     str1 = sprintf('Number of direct partners found for this slice: %d',numel(directPartnerSliceIDs));
%     disp(str1)
%     str1 = sprintf('Number of all partners found so far with the same nID: %d',numel(allPartnerSliceIDs));
%     disp(str1)
else
    allPartnerSliceIDs = [];
    partnerNeuronIDs = [];
end
[neuronIDsForSlices,slicesInNeuronID,neuronCounter] = ...
    updateNeuronIDs(neuronIDsForSlices,slicesInNeuronID,neuronCounter,...
    allPartnerSliceIDs,partnerNeuronIDs,currentSliceID,currentSliceNID);