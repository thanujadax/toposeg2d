function [allPartnerSliceIDs,partnerNeuronIDs] = getAllPartnersNIDs...
    (directPartnerSliceIDs,neuronIDsForSlices,slicesInNeuronID)

% get NIDs for initial partnerIDs
partnerNeuronIDs = neuronIDsForSlices(directPartnerSliceIDs);
% get all slices for these NIDs
allPartnerSliceIDs = slicesInNeuronID(partnerNeuronIDs,:);
allPartnerSliceIDs = allPartnerSliceIDs(allPartnerSliceIDs>0);

