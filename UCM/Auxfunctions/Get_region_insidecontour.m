function [r,c]=Get_region_insidecontour(mask,frameEdge,SE)

% mask = mask-(imerode(mask, SE).*frameEdge);
mask=xor(mask,(imerode(mask, SE)&frameEdge));

[r,c]=find(mask); %r and c contain the pixels of the contour inside the mask
