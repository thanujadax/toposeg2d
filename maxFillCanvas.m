function canvas = maxFillCanvas(canvas,im_i,rStart,rStop,cStart,cStop)

canvasBlock = canvas(rStart:rStop,cStart:cStop);
% get all points which are already 1 and keep them that way
im_i(canvasBlock==1) = 1;
% paint the canvas with the input block
canvas(rStart:rStop,cStart:cStop) = im_i;
