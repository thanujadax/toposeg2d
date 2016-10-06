function im = adjustBorderLine(im)
% there is a 1-pixel wide black border line around the image. The inner
% pixel value (directly adjacent to border) should be propagated into these
% border pixels
[sizeR,sizeC,~] = size(im);

% top line
im(1,:,:) = im(2,:,:);
% left
im(:,1,:) = im(:,2,:);
% right
im(:,sizeC,:) = im(:,(sizeC-1),:);
% bottom
im(sizeR,:,:) = im((sizeR-1),:,:);