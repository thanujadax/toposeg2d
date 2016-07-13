function [ends,variableID,endsID] = updateEnds...
                (ends,startSliceID,variableID,endsID,numPixels)

variableID = variableID + 1;
endsID = endsID + 1;

ends(endsID).variableID = variableID;
ends(endsID).startSliceID = startSliceID;
ends(endsID).numPixels = numPixels;