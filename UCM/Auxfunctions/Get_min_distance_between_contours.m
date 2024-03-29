function [mmin,neighr1,neighr2]=Get_min_distance_between_contours(row1,col1,row2,col2)
%this considers the min distance between the contours
%neighr1 and neighr2 return the x(1,1) and y(2,1) of r1 and r2 regions


%first we find the min, then we extract sqrt
%min is preserved by .^2, sqrt is done only once
dists=(repmat(row1,1,size(row2,1))-repmat(row2',size(row1,1),1)).^2+...
(repmat(col1,1,size(row2,1))-repmat(col2',size(row1,1),1)).^2;

[mmin,index]=min(dists(:));
mmin=sqrt(mmin(1));
[minr,minc]=ind2sub(size(dists),index(1));

neighr1=[col1(minr);row1(minr)];
neighr2=[col2(minc);row2(minc)];



% (neighr1(1)-neighr2(1)).^2+(neighr1(2)-neighr2(2)).^2


%%%alternative method
% minmin=Inf;
% besti=0;
% bestindex=0;
% for i=1:numel(row1)
%     dists=(row1(i)-row2).^2+(col1(i)-col2).^2;
%     [mmin,index]=min(dists(:));
%     if (mmin<minmin)
%         besti=i;
%         bestindex=index(1);
%     end
% end
% mmin=sqrt(minmin);
% neighr1=[col1(besti);row1(besti)];
% neighr2=[col2(bestindex);row2(bestindex)];
