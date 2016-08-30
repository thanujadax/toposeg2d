function [rStart,rStop,cStart,cStop] = getBlockPositionForCanvas...
    (blockFileName,rStep,cStep,rOverlap,cOverlap,sizeR,sizeC)

blockName = strtok(blockFileName,'.');
cc = strsplit(blockName,'c');
blockColID = str2double(cc{2});
dd = strsplit(cc{1},'r');
blockRowID = str2double(dd{2});

rStart = (blockRowID-1)*rStep + 1 - rOverlap;
rStart = max(1,rStart);
rStop = rStart + rStep- 1;
rStop = min(rStop,sizeR);

cStart = (blockColID-1)*cStep + 1 - cOverlap;
cStart = max(1,cStart);
cStop = cStart + cStep -1;
cStop = min(cStop,sizeC);

