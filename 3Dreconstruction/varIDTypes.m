function [endVarIDs,continuationVarIDs,branchVarIDs] = varIDTypes...
    (var2slices,numEnds,numContinuations,numBranches)
% var2slices: matrix. each raw is variableID. col1: startSlice,
% col2:stopslice1, col3: stopslice2

% check if any of the rows of var2slices has zero as the first element
emptyVars = find(var2slices(:,1)==0);
col2zero = find(var2slices(:,2)==0);
col3zero = find(var2slices(:,3)==0);

% end vars have zero for col2 and col3
col23zero = intersect(col2zero,col3zero);
endVarIDs = setdiff(col23zero,emptyVars);

% continuations have zero only for col3
col3onlyzero = setdiff(col3zero,col2zero);
continuationVarIDs = setdiff(col3onlyzero,emptyVars);

% branches have nonzero for both col2 and col3
col2nz = find(var2slices(:,2)>0);
col3nz = find(var2slices(:,3)>0);
branchVarIDs = intersect(col2nz,col3nz);

% error check
if(numel(endVarIDs)~=numEnds)
    error('number of ends and endVarIDs do not match!')
end
if(numel(continuationVarIDs)~=numContinuations)
    error('number of continuations and continuationVarIDs do not match!')
end
if(numel(branchVarIDs)~=numBranches)
    error('number of branches and endVarIDs do not match!')
end
