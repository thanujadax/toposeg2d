function [rStart,rStop,cStart,cStop] = getBlockPositionForCanvas...
    (blockFileName,blockSizeR,blockSizeC,sizeR,sizeC)

blockName = strtok(blockFileName,'.');
cc = strsplit(blockName,'c');
blockColID = cc{2};
dd = strsplit(cc{1},'r');
blockRowID = dd{2};

rStart = (blockRowID-1)*blockSizeR + 1;
rStop = rStart + blockSizeR - 1;
rStop = min(rStop,sizeR);

cStart = (blockColID-1)*blockSizeC + 1;
cStop = cStart + blockSizeC -1;
cStop = min(cStop,sizeC);

