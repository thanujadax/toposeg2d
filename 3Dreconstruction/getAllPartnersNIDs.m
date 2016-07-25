function [allPartnerSliceIDs,partnerNeuronIDs] = getAllPartnersNIDs...
    (directPartnerSliceIDs,neuronIDsForSlices,slicesInNeuronID)

allPartnerSliceIDs = [];
% get NIDs for initial partnerIDs
partnerNeuronIDs = neuronIDsForSlices(directPartnerSliceIDs);
% get all slices for these NIDs
partnerNeuronIDs = partnerNeuronIDs(partnerNeuronIDs>0);
if(~isempty(partnerNeuronIDs))
    allPartnerSliceIDs = slicesInNeuronID(partnerNeuronIDs,:);
    allPartnerSliceIDs = allPartnerSliceIDs(allPartnerSliceIDs>0);
end

[r,c] = size(allPartnerSliceIDs);
if(r==1)
    allPartnerSliceIDs = [allPartnerSliceIDs'; directPartnerSliceIDs];
else
    allPartnerSliceIDs = [allPartnerSliceIDs; directPartnerSliceIDs];
end
