function [ends,variableID,endsID,var2slices] = updateEnds...
                (ends,startSliceID,variableID,endsID,numPixels,var2slices)

variableID = variableID + 1;
endsID = endsID + 1;

ends(endsID).variableID = variableID;
ends(endsID).startSliceID = startSliceID;
ends(endsID).numPixels = numPixels;

var2slices(variableID,1) = startSliceID;