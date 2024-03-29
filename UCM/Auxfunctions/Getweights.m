function [similarityVector,allPredictedmasks]=Getweights(ucm2_1,ucm2_2,allregions1,allregions2,flowatframe,th)
%The measured similarities may be compared with Pr{predicted region | new region}
%In this case, when using similarities, one should also define a prior,
%e.g. the persistence of the region over the levels (see note in Getpaths.m)

%preparation of parameters for EvolveRegionFast
sigmax=6.9;
sigmam=3.6;
factorGaussian=2.5;
printonscreen=false;
gsize=max(1,fix(sigmax*factorGaussian)); %defining the Gaussian function
G=fspecial('gaussian',gsize*2+1,sigmax);

% allregions{count}.centroid_xy=uint16;
% allregions{count}.area=uint32;
% allregions{count}.std_xy=uint16;
% allregions{count}.ll=[uint16,uint16];

noregions1=uint16(size(allregions1,2));
noregions2=uint16(size(allregions2,2));
tmp = ucm2_1(2:2:end, 2:2:end);
dimIi=size(tmp,1);
dimIj=size(tmp,2);
% maxarea=uint32(fix(dimi*dimj/2));
clear tmp;

howmany=zeros(1,noregions2);

if ( (~exist('th','var'))||(isempty(th)) )
    % th=0.5;
    th=0.75; %threshold upperbound for similarity, this should only be set if then we only keep regions chosen according to the same threshold
end
thfe=0.7; %threshold for a first exclusion of outliers
    %It is a good upperbound for mask of values equal or greater than 1, it approximates values smaller than 1
    %For this reason is a bit smaller than the one actually used (th)
thcp=0.1; %threshold for distance of centroid from predicted, 0.1 means 64 pixels for 480x640 image, this excludes many macthes to try
thc=max(thcp*dimIi,thcp*dimIj);
thcs=thc^2;
threshold_out_pixels=2000; %0.0065*dimIi*dimIj %*

[X,Y]=meshgrid(1:dimIj,1:dimIi);

similarityVector=cell(1,noregions2);
for i=1:noregions2
    similarityVector{i}{1}.similarity=0;
    similarityVector{i}{1}.origin=uint16(0);
end

%a pre-computation of all mask speeds up the function at the cost of
%increasing the memory requirement
% allMasks1=false(dimIi,dimIj,noregions1);
% for reg1=1:noregions1
%     allMasks1(:,:,reg1)=Getthemask(ucm2_1,allregions1{reg1}.ll(1,1),allregions1{reg1}.ll(1,2));
% end
tic
allMasks2=false(dimIi,dimIj,noregions2);
for reg2=1:noregions2
    allMasks2(:,:,reg2)=Getthemask(ucm2_2,allregions2{reg2}.ll(1,1),allregions2{reg2}.ll(1,2));
end
toc

allPredictedmasks=false(dimIi,dimIj,noregions1);

tic
fprintf('Region being analysed=%6d',0);
for reg1=uint16(1):uint16(noregions1) %uint16(10) %
    if (~mod(reg1,25))
        fprintf('\b\b\b\b\b\b%6d',reg1);
    end
%     if (allregions1{reg1}.area>maxarea)
%         continue;
%     end

    mask1=Getthemask(ucm2_1,allregions1{reg1}.ll(1,1),allregions1{reg1}.ll(1,2));
%     mask1=allMasks1{reg1};
%     figure(10)
%     set(gcf, 'color', 'white');
%     imagesc(mask1);
%     title ('Mask of selected area');

    predictedMask=EvolveRegionFast(mask1,flowatframe,sigmax,sigmam,factorGaussian,printonscreen,G);
%     figure(15)
%     set(gcf, 'color', 'white');
%     imagesc(predictedMask);
%     title ('Predicted area');
    allPredictedmasks(:,:,reg1)= (predictedMask>0.5);

    ll=find(predictedMask);
    predictedcentroid_xy=[mean(X(ll)),mean(Y(ll))];

    for reg2=uint16(1):uint16(noregions2)
%         if (allregions2{reg2}.area>maxarea)
%             continue;
%         end
        if ( double(min(allregions1{reg1}.area,allregions2{reg2}.area)*2)/double(allregions1{reg1}.area+allregions2{reg2}.area) < thfe )
            continue;
        end
        if ( sum((predictedcentroid_xy-double(allregions2{reg2}.centroid_xy)).^2) > thcs )
            continue;
        end

%         mask2=Getthemask(ucm2_2,allregions2{reg2}.ll(1,1),allregions2{reg2}.ll(1,2));
        mask2=allMasks2(:,:,reg2);
    %     figure(12)
    %     set(gcf, 'color', 'white');
    %     imagesc(mask2);
    %     title ('Mask of selected area');

        similarity=Measuresimilaritymex(mask2,predictedMask,false);
%         similarity=Measuresimilarity(mask2,predictedMask,0);
        similarity_out_pixels=Measureoutpixelswithmex(mask2,predictedMask,false); %*
%         similarity_out_pixels=Measureoutpixels(mask2,predictedMask,0); _*
        
%         if (similarity>=th)
        if ( (similarity>=th) &&... %*
              (similarity_out_pixels<threshold_out_pixels) ) %*
            
            howmany(reg2)=howmany(reg2)+1;
    %         if howmany(reg2)>1
    %             fprintf('Occurrences=%d, region in second frame=%d\n',howmany(reg2),reg2);
    %         end

            similarityVector{reg2}{howmany(reg2)}.similarity=similarity;
            similarityVector{reg2}{howmany(reg2)}.origin=reg1;
            
        end

    end

end

fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');

toc

