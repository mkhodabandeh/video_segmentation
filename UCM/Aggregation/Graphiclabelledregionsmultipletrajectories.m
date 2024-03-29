function Graphiclabelledregionsmultipletrajectories(ktraj,labelledvideo,trajectories,cim,flows)


if (isempty(ktraj))
    return;
end

noTrajectories=numel(ktraj);
allstartframes=zeros(1,noTrajectories);
allendframes=zeros(1,noTrajectories);
for k=1:noTrajectories
    allstartframes(k)=trajectories{ktraj(k)}.startFrame;
    allendframes(k)=trajectories{ktraj(k)}.endFrame;
end

startFrame=max(allstartframes);
endFrame=min(allendframes);
fprintf('Common start frame %d, end frame %d\n',startFrame,endFrame);

frame=startFrame;
trackLength=endFrame-startFrame+1;
if (trackLength<1)
    fprintf('No common frame\n');
    return;
end
range=1:trackLength;

noTracks=numel(ktraj);
track=zeros(trackLength,2,noTracks);
mapTracToTrajectories=zeros(1,noTracks);
for k=1:noTracks
    for i=1:trackLength
        posInarray=frame-trajectories{ktraj(k)}.startFrame+i;
        track(i,1,k)=trajectories{ktraj(k)}.Xs(posInarray);
        track(i,2,k)=trajectories{ktraj(k)}.Ys(posInarray);
    end
    mapTracToTrajectories(k)=ktraj(k);
end
%track = [ which frame , x or y , which trajectory ]

dist_track_mask=cell(trackLength,noTracks);
for k=1:noTracks
    label=trajectories{ktraj(k)}.label;
    for f=1:trackLength %trajectories{k}.totalLength(nopath)
        ff=frame+f-1;
        dist_track_mask{f,k}= (labelledvideo(:,:,ff)==label);
    end
end
%dist_track_mask{which frame,which trajectory}=mask

dim=size(dist_track_mask{1,1});
dimIi=dim(1);
dimIj=dim(2);

SE=Getstrel();
frameEdge=Getframeedge(dimIi,dimIj);

allcontours=cell(trackLength,noTracks);
for j=1:noTracks
    for i=1:trackLength
        [row,col]=Get_region_insidecontour(dist_track_mask{i,j},frameEdge,SE);
        allcontours{i,j}.row=row;
        allcontours{i,j}.col=col;
    end
end

if (trackLength>1)
    [X,Y]=meshgrid(1:dimIj,1:dimIi);
    velU=cell(1,(trackLength-1));
    velV=cell(1,(trackLength-1));
    for i=1:(trackLength-1)
        framepos=frame+i-1; %position in trajectory of the present frame
        velU{i}=flows.flows{framepos}.Up-X;
        velV{i}=flows.flows{framepos}.Vp-Y;
    end
    vexcludePartInnerThan=0; %+excludePartInnerThan is in (1 for eliminating just the average, 0 component)
    vexcludePartOuterThan=20; %+excludePartOuterThan is in
    lengthvel=(trackLength-1);
    rangevel=1:lengthvel;
    medianvelocity_uv_r=zeros(2,lengthvel,noTracks);
    medianvelocity_uv_rmeansubonstd=zeros(2,lengthvel,noTracks);
    tmpFT=GetFourierAnalysis(track(1:(end-1),2,1)',vexcludePartInnerThan,vexcludePartOuterThan,0);
    medtransformr=zeros(noTracks,numel(tmpFT));
    medtransformr_en=zeros(noTracks,numel(tmpFT)); clear tmpFT;
    for r1=1:noTracks
            [medianvelocity_uv_r(:,:,r1)]=Getmedianvelocity(rangevel,velU,velV,dist_track_mask,r1);
            medianvelocity_uv_rmeansubonstd(:,:,r1)=Mean_subtract_divide_by_std(medianvelocity_uv_r(:,:,r1));
            medtransformr(r1,:)=GetFourierAnalysis(medianvelocity_uv_r(2,:,r1),vexcludePartInnerThan,vexcludePartOuterThan,0);
            medtransformr_en(r1,:)=GetFourierAnalysis(medianvelocity_uv_r(2,:,r1),vexcludePartInnerThan,vexcludePartOuterThan,1);
    end
end

radius=10;
[XM,YM]=meshgrid(-radius:radius,-radius:radius);
M=( (XM.^2+YM.^2) <= (radius^2) );


%settings for the prints
printneariftwotrajs=false;
printtheedges=false;
printnearmasks=false;

printneariftwotrajs=( printneariftwotrajs && (noTracks==2) );
if (noTracks==2)
    r1=1;
    r2=2;
    printfunc=false;
    [mindist,neighxyr1,neighxyr2]=Getneighboursfast(track,dist_track_mask,range,r1,r2,allcontours,printfunc);

    nearMask=cell(trackLength,noTracks);
    for k=range
        nearMask{k,1}=Get_region_area_near_point_mask(dist_track_mask{k,r1},neighxyr1(:,k),radius,printfunc,M);
        nearMask{k,2}=Get_region_area_near_point_mask(dist_track_mask{k,r2},neighxyr2(:,k),radius,printfunc,M);
    end
end


% image=cim{frame};
% SE=Getstrel();
% frameEdge=Getframeedge(size(image,1),size(image,2));
nofigure=20;
colourratio=2/3;

colourforimage=cell(1,noTracks);
colourfornearmask=cell(1,noTracks);
if (noTracks==2)
    colourforimage{1}=[0,0,1];
    colourforimage{2}=[0,1,0];
elseif (noTracks==1)
    colourforimage{1}=[0,0,1];
else
    for k=1:noTracks
        colourforimage{k}=GiveDifferentColours(k,2*(noTracks+1)/noTracks);
    end
end
for k=1:noTracks
    colourfornearmask{k}=colourforimage{k}/3; %two thirds darker
end
colourforedges=[1,0,0];

%transformation of values into uint8
colourforedges=uint8(round(colourforedges*255));
for k=1:noTracks
    colourforimage{k}=uint8(round(colourforimage{k}*255*colourratio));
    colourfornearmask{k}=uint8(round(colourfornearmask{k}*255*colourratio));
end

for i=range
    f=i+frame-1;
    image=cim{f};
    
    for k=1:noTracks
        
        %colours the main mask
        image=Colourapart(dist_track_mask{i,k},image,colourforimage{k},colourratio);
        if (printneariftwotrajs&&printnearmasks) %colours the nearMask
            image=Colourapart(nearMask{i,k},image,colourfornearmask{k},colourratio);
        end
        if (printtheedges) %colours the edges
            edgetocolour=xor( dist_track_mask{i,k} , (imerode(dist_track_mask{i,k}, SE) & frameEdge) );
            image=Colourapart(edgetocolour,image,colourforedges,1);
        end
    end

    figure(nofigure), imshow(image)
    set(gcf, 'color', 'white');
    title(['Frame ',num2str(f)]);

    hold on
    for k=1:noTracks
        %centroids
        plot(track(i,1,k),track(i,2,k),'+r','MarkerSize',10,'LineWidth',1);
    end
    if (printneariftwotrajs)
        %closest points to other mask
        plot(neighxyr1(1,i),neighxyr1(2,i),'+m');
        plot(neighxyr2(1,i),neighxyr2(2,i),'+y');
    end
    hold off
    pause(0.05)
    
%     if (f>27)
%         continue;
%     end
    
%     if any(f==[1,16,31,46,60])
        %for writing the images (no centroids)
%         imwrite(image,['D:\regionatframe',num2str(f),'.png'],'png');
        %for writing the image with the centroids (print of whole figure)
%         print('-depsc',['D:\regionwithcentroidatframe',num2str(f),'.eps']);
%     end
    %for acquiring the video of the region trajectory
%     regiontrajectory(i)=getframe;
end
%for acquiring the video of the region trajectory
% movie2avi(regiontrajectory,'D:\Regiontrajectoryexamples.avi','compression','None','fps',7);
