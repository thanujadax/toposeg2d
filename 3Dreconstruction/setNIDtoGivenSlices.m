function [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID,...
            allPartnerSliceIDs)
        
% set the given neuronID for all the given slices and update all the
% relevant pointers and counters

% this is already done in updateNeuronID
% allPartnerSliceIDs(end+1) = currentSliceID;

neuronIDsForSlices(allPartnerSliceIDs) = newID;
numPartners = numel(allPartnerSliceIDs);
if(numPartners==1)
    slicesInNeuronID(newID,1) = allPartnerSliceIDs;
elseif(numPartners>1)
    slicesInNeuronID(newID,1:numPartners) = allPartnerSliceIDs;
end
