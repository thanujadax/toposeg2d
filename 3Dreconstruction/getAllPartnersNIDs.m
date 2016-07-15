function [allPartnerSliceIDs,partnerNeuronIDs] = getAllPartnersNIDs...
    (partnerSliceIDs,neuronIDsForSlices,slicesInNeuronID)

% get NIDs for initial partnerIDs
partnerNeuronIDs = neuronIDsForSlices(partnerSliceIDs);
% get all slices for these NIDs
allPartnerSliceIDs = slicesInNeuronID(partnerNeuronIDs,:);
allPartnerSliceIDs = allPartnerSliceIDs(allPartnerSliceIDs>0);

