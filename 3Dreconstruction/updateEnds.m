function [ends,variableID,endsID] = updateEnds...
                (ends,startSliceID,variableID,endsID)

variableID = variableID + 1;
endsID = endsID + 1;

ends(endsID).variableID = variableID;
ends(endsID).startSliceID = startSliceID;