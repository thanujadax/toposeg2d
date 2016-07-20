function [neuronIDsForSlices,slicesInNeuronID]= setNIDtoGivenSlices...
            (neuronIDsForSlices,slicesInNeuronID,newID,...
            allPartnerSliceIDs)
        
% set the given neuronID for all the given slices and update all the
% relevant pointers and counters

neuronIDsForSlices(allPartnerSliceIDs) = newID;

slicesInNeuronID(newID,:) = allPartnerSliceIDs;