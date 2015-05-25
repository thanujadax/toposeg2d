% visualize edges 411 and 455

e1LID = 411;
e2LID = 455;

e0LID = 410;

imt = zeros(sizeR,sizeC);
edgepixels = edges2pixels;
edgepixels(:,1) = [];

e1p = edgepixels(e1LID,:);
e1p = e1p(e1p>0);

e2p = edgepixels(e2LID,:);
e2p = e2p(e2p>0);

e0p = edgepixels(e0LID,:);
e0p = e0p(e0p>0);

imt(e1p) = 0.5;
imt(e2p) = 0.8;
imt(e0p) = 0.1;

figure;imagesc(imt)
figure;imagesc(ws);colormap('jet')