function [Tm,labelsfc_output,valid]=Gettheclustering(allGis,Gif,noGroups,dimtouse,n_size,noreplicates,tryonlinefirst,filenames,...
    saveyre,saveidxcs,maintaintleveloneconnections,tlevelone,picsorvideo,...
    frame,...%necessary for creating pics
    fframe,howmanyframes,... %necessary for videos
    minLength,trackLength,trajectories,allregionpaths,ucm2,allregionsframes,...
    selectedtreetrajectories,manifoldmethod,clusteringmethod,cim,printonscreen,...
    options,filename_sequence_basename_frames_or_video,videocorrectionparameters)
% allGis_or_D, Gif_or_T


%Dumb variables returned in case of non convergence
Tm=[];
labelsfc_output=[];
valid=false;


if ( (~exist('cim','var')) || (isempty(cim)) )
    picsorvideo=0;
end
if ( (~exist('manifoldmethod','var')) || (isempty(manifoldmethod)) )
    manifoldmethod='isoii'; %'iso','isoii','laplacian'
end
if ( (~exist('clusteringmethod','var')) || (isempty(clusteringmethod)) )
    clusteringmethod='km3'; %'km','km2','km3'
end
if ( (~exist('n_size','var')) || (isempty(n_size)) )
    n_size=0; %default is 7, 0 when neighbours have already been selected
end
if ( (~exist('picsorvideo','var')) || (isempty(picsorvideo)) )
    picsorvideo=0;
    %picsorvideo == 0 stands for no pics nor video
    %picsorvideo == 1 stands for pics
    %picsorvideo == 2 stands for interactive
    %picsorvideo == 3 stands for video
    %picsorvideo == 4 stands for pics for output (same as 1 but with active contours and sequence images)
end
if ( (~exist('maintaintleveloneconnections','var')) || (isempty(maintaintleveloneconnections)) )
    maintaintleveloneconnections=false;
end
if (  ((~exist('tlevelone','var')) || (isempty(tlevelone)))  &&  (maintaintleveloneconnections)  )
    fprintf('To maintain connections at level one a tlevelone must be passed\n');
    maintaintleveloneconnections=false;
end
if ( (~exist('frame','var')) || (isempty(frame)) )
    frame=1; %frame is only required for the cases (picsorvideo == [1,4])
end
if ( (~exist('noreplicates','var')) || (isempty(noreplicates)) )
    noreplicates=30;
end
if ( (~exist('tryonlinefirst','var')) || (isempty(tryonlinefirst)) )
    tryonlinefirst=true;
end
if ( (~exist('saveidxcs','var')) || (isempty(saveidxcs)) )
    saveidxcs=false;
end
if ( (~exist('saveyre','var')) || (isempty(saveyre)) )
    saveyre=false;
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=false;
end
if ( (~exist('noGroups','var')) || (isempty(noGroups)) )
    noGroups=70; %70,160
end
if ( (~exist('dimtouse','var')) || (isempty(dimtouse)) )
    dimtouse=6;
end

if ( strcmp(manifoldmethod,'isoii') || strcmp(manifoldmethod,'laplacian') )
    usesparse=true;
else
    usesparse=false;
end


if ( (~exist('allGis','var')) || (isempty(allGis)) )
    fprintf('An argument must be passed for D\n');
    return;
end
if (isstruct(allGis)) %allGis_or_D
    D=1-allGis.P;
else
    D=allGis;
    picsorvideo=0;
end
if ( (~exist('Gif','var')) || (isempty(Gif)) )
    picsorvideo=0;
    if (isstruct(allGis)) %allGis_or_D
        T=allGis.T;
    else
        T=true(size(D));
        T(isinf(D))=false;
    end
else
    if (isstruct(Gif)) %Gif_or_T
        T=allGis.T;
    else
        T=Gif;
        picsorvideo=0;
    end
end
%From allGis: D=1-allGis.P; T=allGis.T;
%From allGis_or_D and Gif_or_T: D=allGis; T=Gif;
D(~T)=Inf; %IMPORTANT: Isomap only takes D and interrupted links are indicated with Inf value


%%%part related to visualization%%%
noFrames=numel(allregionsframes);
endf=(noFrames-trackLength+1);

if ( (~exist('selectedtreetrajectories','var')) || (isempty(selectedtreetrajectories)) )
    selectedtreetrajectories=true(1,numel(trajectories));
end
if ( (~exist('trackLength','var')) || (isempty(trackLength)) )
    trackLength=17;
end
if ( (~exist('minLength','var')) || (isempty(minLength)) )
    minLength=5;
end
if ( (~exist('howmanyframes','var')) || (isempty(howmanyframes)) )
%     howmanyframes=1:54;
    howmanyframes=1:endf;
end
if (numel(howmanyframes)==1) %This means that at least two frames must be requested if fframe is not empty
    if ( (exist('fframe','var')) && (~isempty(fframe)) )
        howmanyframes=fframe:fframe+howmanyframes-1;
    end
end
if (any(howmanyframes>endf))
    howmanyframes=howmanyframes(howmanyframes<=endf);
end

if (~(mod(trackLength,2))) %if trackLength is not a odd number
    trackLength=trackLength-1;
end
if (~(mod(minLength,2))) %if trackLength is not a odd number
    minLength=minLength-1;
end
sizeL=round( (trackLength-1)/2 );
minsizeL=round( (minLength-1)/2 );

saveworkfiles=false;
%%%%%%



if (numel(noGroups)>1)
    if (~saveidxcs)
        fprintf('Multiple group numbers requires to save idxs\n');
        return;
    end
end



zerosparsevalue=0.0000001;
if (usesparse)
    D(D==0)=zerosparsevalue;
    D(isinf(D))=0;
    D=sparse(D);
end



forcezerodiagonal=true;
D=Forcezerodiagonal(D,usesparse,forcezerodiagonal);



readyre=true;
[Y, R, E] = Mapontomanifold(D,manifoldmethod,dimtouse,n_size,saveyre,readyre,filenames);



readidxcs=true;
[IDX,kmeansdone,offext]=Clusterthepoints(Y,clusteringmethod,noGroups,dimtouse,noreplicates,...
    tryonlinefirst,readidxcs,saveidxcs,filenames); %,C



if ( (numel(noGroups)==1) && (~kmeansdone) )
    fprintf('No converged case to process\n');
    return;
end


%%% graphical presentation of Kmeans clustering, case of single noGroups
if ( (exist('IDX','var')) && (~isempty(IDX)) && (numel(noGroups)==1) && (printonscreen) )
    distributecolours=true;
    Visualiseclusteredpoints(Y,IDX,2,20,distributecolours);
    Visualiseclusteredpoints(Y,IDX,3,21,distributecolours);
end



%picsorvideo == 0 stands for no pics nor video
%picsorvideo == 1 stands for pics
%picsorvideo == 2 stands for interactive
%picsorvideo == 3 stands for video
%picsorvideo == 4 stands for pics for output

%%%Preparation for pics%%%
if ( (picsorvideo==1) || (picsorvideo==2) || (picsorvideo==4) ) %pics or interactive
    % computation of track, mapTracToTrajectories, dist_track_mask, all_the_lengths
    fc=frame+sizeL; %position of central frame in the sequence
%     fcin=sizeL+1;
        %position of the central frame in the longest vector (trackLength long)
    %for the computation of the lowest level spanning tree (reference for region selection)
    ntrackLength=minLength;
    nframe=fc-minsizeL; %analysed frames are [nframe:nframe+ntrackLength-1]
    image=cim{nframe}; %should only be necessary if printonscreen == true
    imagefc=cim{fc}; %should only be necessary if printonscreen == true
    
    %The following is to be used, then allDs are computed on request
    [track,mapTracToTrajectories,dist_track_mask]=... %,all_the_lengths
        Prepareregiontracksonrequest(trajectories,nframe,ntrackLength,allregionpaths,ucm2,allregionsframes,...
        filenames,selectedtreetrajectories,saveworkfiles,printonscreen,image);
    noTracks=size(track,3); %=size(dist_track_mask,2)
end
%%%%%%



if ( (exist('options','var')) && (~isempty(options)) && (isfield(options,'bmetric')) && (options.bmetric) )
    %Prepare a labelledvideo according to the trajectories
    gisselectedtrajectories=false(1,numel(trajectories));
    gisselectedtrajectories(allGis.mapTracToTrajectories)=true;
    [gislabelledvideo,ltrajectories,map]=Getlabelledvideofromtrajectories(ucm2,allregionpaths,allregionsframes,trajectories,gisselectedtrajectories,printonscreen);
    Printthevideoonscreen(gislabelledvideo, printonscreen, 1);

    %Prepare backmaps
    backmapscramble=Mapitback(map);
    backtractrajs=Mapitback(allGis.mapTracToTrajectories);

    %Prepare gtimages
    framestoconsider=1:noFrames;
    printonscreeninsidefunction=false;
    noFrames=numel(cim);
    %Read the ground truth video sequence or the frames
    allgtimages=Readpictureseries(filename_sequence_basename_frames_or_video.gtbasename,...
        filename_sequence_basename_frames_or_video.gtnumber_format,filename_sequence_basename_frames_or_video.gtclosure,...
        filename_sequence_basename_frames_or_video.gtstartNumber,noFrames,printonscreeninsidefunction);
    allgtimages=Adjustimagesize(allgtimages,videocorrectionparameters,printonscreeninsidefunction,true);
    if (printonscreeninsidefunction)
        close all;
    end
    gtimages=allgtimages(framestoconsider);

    %Prepare filenames
    %bdeffileframes is considered because of the clustering algorithm not considering edge frames
    deffilename=filename_sequence_basename_frames_or_video.bdeffileframes;
    bfileexe=['UCM',filesep,'Aggregation',filesep,'Quantitative',filesep,'Broxcode',filesep,'MoSegEval'];
    mergebtext='notmg';

    %Prepare btrajectories and blabelledvideo
    [btrajectories,noblabels]=Readbroxtrajectories(filename_sequence_basename_frames_or_video.btracksfile); %some labels may be empty
    videosize=[size(cim{1},1),size(cim{1},2),noFrames];
    blabelledvideo=Labelbvideo(btrajectories,videosize,printonscreen);
    
    %Merge labels in the background
    if ( (isfield(options,'bmergeb')) && (options.bmergeb) )
        [blabelledvideo,labelsmerged]=Mergeallbackground(gtimages,filename_sequence_basename_frames_or_video,...
            blabelledvideo,printonscreen,framestoconsider,fframe);
        Printthevideoonscreen(blabelledvideo, printonscreen, 1);
        btrajectories=Mergetrajectorylabels(btrajectories,labelsmerged);
        mergebtext='mg';
    end

    %Compute metrics on btrajectories
    bforegtmp=[filenames.idxpicsandvideobasedir,'btraj',mergebtext,'.dat'];
    Writebtrajectories(btrajectories,videosize,bforegtmp);
    if (isdir('UCM'))
        system( ['chmod u+x ',bfileexe] );
        system( [bfileexe,sprintf(' %s %s', deffilename, bforegtmp)] );
    end
    delete(bforegtmp);
end



for agroupnumber=noGroups
    
    if (numel(noGroups)~=1)
        readidxcs=true;
        [IDX,kmeansdone,offext]=Clusterthepoints([],[],agroupnumber,[],[],...
            [],readidxcs,[],filenames); %,C
        if (~kmeansdone)
            continue;
        end
    end
    

    
    if ( (picsorvideo==1) || (picsorvideo==4) ) %pics
        filenamepicorvideobasename=[filenames.idxpicsandvideobasedir,'Pics',filesep];
    elseif (picsorvideo==3) %video
        filenamepicorvideobasename=[filenames.idxpicsandvideobasedir,'Videos',filesep];
    end

    
    
    [labelsfc_output,Tm,valid]=Gettmandlabelsfcfromidx(IDX,Y,T,maintaintleveloneconnections,tlevelone);
    
    
    
    %The function allows to specify a framesforevaluation to only compute
    %results on some of the howmanyframes input (same format)
    if ( (exist('options','var')) && (~isempty(options)) && (isfield(options,'statistics')) && (options.statistics) )
        printonscreeninsidefunction=false; %deeper level of comments printed
        framesforevaluation=howmanyframes;
        Getquantitativestatistics(filename_sequence_basename_frames_or_video, videocorrectionparameters, noFrames, filenames, ...
            trajectories, allregionpaths, allregionsframes, ucm2, selectedtreetrajectories,...
            allGis, Gif, Tm, agroupnumber, cim, howmanyframes, sizeL, minLength, minsizeL, ...
            framesforevaluation, printonscreen, printonscreeninsidefunction);
    end
    
    
    
    if ( (exist('options','var')) && (~isempty(options)) && (isfield(options,'bmetric')) && (options.bmetric) )
        
        %Re-label video according to ISOMAP+Kmeans clustering
        gisthenewlabelledvideo=gislabelledvideo;
        for thelabel=unique(gislabelledvideo)'
            if (thelabel==0) %0 label is not scrambled, it represents no label
                continue;
            end
            truelabel=backmapscramble(thelabel); %truelabel=find(map==thelabel,1,'first');
            mappedlabel=backtractrajs(truelabel); %mappedlabel=find(allGis.mapTracToTrajectories==truelabel,1,'first');
            if (~isempty(mappedlabel))
                gisthenewlabelledvideo(gislabelledvideo==thelabel)=labelsfc_output(mappedlabel);
            else
                fprintf('Empty label detected\n');
            end
        end
        Printthevideoonscreen(gisthenewlabelledvideo, printonscreen, 1);
        
        %Further clustering based on Brox trajectories
        if ( (isfield(options,'bvote')) && (options.bvote) )
            numberofsegments=max(gisthenewlabelledvideo(:));
            gisthenewlabelledvideo=Votewithtrajectories(numberofsegments,noblabels,btrajectories,gisthenewlabelledvideo,printonscreen);
        end
        
        %Merge labels in the background
        if ( (isfield(options,'bmergeb')) && (options.bmergeb) )
            [gisthenewlabelledvideo]=Mergeallbackground(gtimages,filename_sequence_basename_frames_or_video,...
                gisthenewlabelledvideo,printonscreen,framestoconsider,fframe); %,labelsmerged
            Printthevideoonscreen(gisthenewlabelledvideo, printonscreen, 1);
        end
        
        %Compute metrics on re-labelled clustered video
        btrackstmp=[filenames.idxpicsandvideobasedir,'clustered',mergebtext,sprintf('%d',agroupnumber),'.dat'];
        Writeblabelledvideo(gisthenewlabelledvideo,btrackstmp);
        if (~isdir('UCM'))
            fprintf('Please set your directory to the main folder\n');
        else
            system( [bfileexe,sprintf(' %s %s', deffilename, btrackstmp)] );
        end
        delete(btrackstmp);
        
    end
    
    
    %Prepare the outputs to pics or video
    if ( (picsorvideo==1) || (picsorvideo==4) ) %pics
        %Represent computed clustering at frame
        labelsfc=Turntmtolabels(Tm); %labels according to the spanning tree allGis.T (as if fully connected)
        [labels,labelsv]=Getlabelsatframei(allGis,labelsfc,Gif,frame);
        Representcomputedlabelsatcentre(imagefc,track,labelsv);
%         Representcomputedlabels(image,track,dist_track_mask,labelsv);
        th=1; Representlabeledregionsatcentre(imagefc,dist_track_mask,labelsv,th,labelsfc); %TODO: threshold no regions
%         th=6; Representlabeledregions(image,track,dist_track_mask,labelsv,th,labelsfc);
        indexframe=find(Gif.frame==frame,1); allowchanget=1;
        Tmi=Turnlabelstotm(labels,Gif.Gis{indexframe}.T{1},allowchanget);
        Representspanningtreeatcentre(Tmi,track,dist_track_mask,imagefc);
%         Representspanningtree(Tmi,track,dist_track_mask,image);

        %Active contours
        if (picsorvideo==4)
            Getactivecontours(allGis,track,dist_track_mask,mapTracToTrajectories,labelsfc,labelsv,imagefc);
        end
        
        figure(13), title(['Frame ',num2str(fc)]); %nframe
        print('-depsc',[filenamepicorvideobasename,'l_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'_f_',num2str(frame),'.eps']);
%         print('-depsc',[filenamepicorvideobasename,'l_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.eps']);
        figure(16), title(['Frame ',num2str(fc)]); %nframe
        print('-depsc',[filenamepicorvideobasename,'t_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'_f_',num2str(frame),'.eps']);
%         print('-depsc',[filenamepicorvideobasename,'t_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.eps']);
        figure(17), title(['Frame ',num2str(fc)]); %nframe
        print('-depsc',[filenamepicorvideobasename,'r_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'_f_',num2str(frame),'.eps']);
%         print('-depsc',[filenamepicorvideobasename,'r_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.eps']);
        
        if (picsorvideo==4)
            figure(10), Init_figure_no(10);
            imshow(cim{fc});
            print('-depsc',[filenamepicorvideobasename,'orig_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'_f_',num2str(frame),'.eps']);
%             print('-depsc',[filenamepicorvideobasename,'orig_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.eps']);
        end

        fprintf('No groups = %d, computed and saved\n',agroupnumber);
    elseif (picsorvideo==3) %video
    
    
        count=0;
        clear lab; clear sp; clear lr;
        for frame=howmanyframes
            count=count+1;

            % computation of track, mapTracToTrajectories, dist_track_mask, all_the_lengths
            fc=frame+sizeL; %position of central frame in the sequence
        %     fcin=sizeL+1;
                %position of the central frame in the longest vector (trackLength long)
            %for the computation of the lowest level spanning tree (reference for region selection)
            ntrackLength=minLength;
            nframe=fc-minsizeL; %analysed frames are [nframe:nframe+ntrackLength-1]
            image=cim{nframe}; %should only be necessary if printonscreen == true
            imagefc=cim{fc}; %should only be necessary if printonscreen == true

            %The following is to be used, then allDs are computed on request
            [track,mapTracToTrajectories,dist_track_mask,all_the_lengths]=...
                Prepareregiontracksonrequest(trajectories,nframe,ntrackLength,allregionpaths,ucm2,allregionsframes,...
                filenames,selectedtreetrajectories,saveworkfiles,printonscreen,image);
            noTracks=size(track,3); %=size(dist_track_mask,2)


            %Represent computed clustering at frame
            labelsfc=Turntmtolabels(Tm); %labels according to the spanning tree allGis.T (as if fully connected)
            [labels,labelsv]=Getlabelsatframei(allGis,labelsfc,Gif,frame);
            Representcomputedlabelsatcentre(imagefc,track,labelsv);
%             Representcomputedlabels(image,track,dist_track_mask,labelsv);
            th=1; Representlabeledregionsatcentre(imagefc,dist_track_mask,labelsv,th,labelsfc); %TODO: threshold no regions
%             th=1; Representlabeledregions(image,track,dist_track_mask,labelsv,th,labelsfc);
            indexframe=find(Gif.frame==frame,1); allowchanget=1;
            Tmi=Turnlabelstotm(labels,Gif.Gis{indexframe}.T{1},allowchanget);
            Representspanningtreeatcentre(Tmi,track,dist_track_mask,imagefc);
%             Representspanningtree(Tmi,track,dist_track_mask,image);
            %This part is correct but the labels are not consistent and the Ts are fully connected
            % labelsfc=Turntmtolabels(Tm); %labels according to the spanning tree allGis.T (as if fully connected)
            % Tmfc=Turnlabelstotm(labelsfc,true(size(allGis.T))); %
            % Tmi=Gettatframei(allGis,Tmfc,Gif,frame);
            % % Tmi=Gettatframei(allGis,Tm,Gif,frame); %this line splits the labels
            % Representspanningtree(Tmi,track,dist_track_mask,image);
            % labels=Turntmtolabels(Tmi);
            % Representcomputedlabels(image,track,dist_track_mask,labels);
            % for i=1:max(labels)
            %     tlabels=labels;
            %     tlabels(labels~=i)=max(labels)+1;
            %     Representcomputedlabels(image,track,dist_track_mask,tlabels);
            %     pause;
            % end  

            figure(13), title(['Frame ',num2str(fc)]);
%             figure(13), title(['Frame ',num2str(nframe)]);
            lab(count)=getframe;
            % print('-depsc',['C:\Epsimages\labels',num2str(nframe),'.eps']);
            figure(16), title(['Frame ',num2str(fc)]);
%             figure(16), title(['Frame ',num2str(nframe)]);
            sp(count)=getframe;
            % print('-depsc',['C:\Epsimages\sp',num2str(nframe),'.eps']);
            figure(17), title(['Frame ',num2str(fc)]);
%             figure(17), title(['Frame ',num2str(nframe)]);
            lr(count)=getframe;
            % print('-depsc',['C:\Epsimages\lregions',num2str(nframe),'.eps']);
        end
        movie2avi(sp,[filenamepicorvideobasename,'t_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.avi'],'compression','None','fps',7);
        movie2avi(lab,[filenamepicorvideobasename,'l_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.avi'],'compression','None','fps',7);
        movie2avi(lr,[filenamepicorvideobasename,'r_',num2str(agroupnumber),'_',num2str(dimtouse),offext,'.avi'],'compression','None','fps',7);
    end
end


%part for interactive representation of the image with tracks
if ( (picsorvideo==2) && (numel(noGroups)==1) ) %interactive


    labelsfc=Turntmtolabels(Tm); %labels according to the spanning tree allGis.T (as if fully connected)
    [labels,labelsv]=Getlabelsatframei(allGis,labelsfc,Gif,frame);
%     [labels,labelsv]=Getlabelsatframei(allGis,IDX,Gif,frame);


%Represent regions and the spanning tree
        th=1; Representlabeledregionsatcentre(imagefc,dist_track_mask,labelsv,th,labelsfc); %TODO: threshold no regions
%         th=6; Representlabeledregions(image,track,dist_track_mask,labelsv,th,labelsfc);
        indexframe=find(Gif.frame==frame,1); allowchanget=1;
        Tmi=Turnlabelstotm(labels,Gif.Gis{indexframe}.T{1},allowchanget);
        Representspanningtreeatcentre(Tmi,track,dist_track_mask,imagefc);
        
        
        
    %%% graphical representation on the image with tracks
    figure(13)
    set(gcf, 'color', 'black');
    imshow(image);
    hold on;
    for i=unique(labelsv) %so as to illustrate all labels
            %unique(IDX(Y.index))' this only illustrates the embedded ones
        col=GiveDifferentColours(i);
        whichBelonging=find(labelsv==i);
        %whichBelonging=find(labelsfc==i); %alternative calculation of whichBelonging
        for whichtrack=whichBelonging
%             trackpos=find(mapTracToTrajectories==whichBelonging(j));
%             if (isempty(trackpos))
%                 continue;
%             end
            line(track(:,1,whichtrack),track(:,2,whichtrack),'Color',col);
            plot(track(:,1,whichtrack),track(:,2,whichtrack),'+','Color',col);
        end
    end
    hold off;


    %%% interactive graphical presentation
    % noTracks=size(track,3);
    
    twod=Getchosend(Y,2);
%     twod = find(options.dims==2,1,'first');
    figure(12), set(gcf, 'color', 'white');
    plot(Y.coords{twod}(1,:), Y.coords{twod}(2,:), 'ro');
    hold on
    gplot(E(Y.index, Y.index), [Y.coords{twod}(1,:); Y.coords{twod}(2,:)]');
    hold off
    figure(17)
    % imshow(uint8(ones(480,640)*255));
    % set(gcf, 'color', 'white');
    set(gcf, 'color', 'black');
    imshow(image);
    hold on
    for i=1:noTracks
        line(track(:,1,i),track(:,2,i),'Color','k');
        plot(track(:,1,i),track(:,2,i),'+k');
    end
    hold off


    j=0;
    while (1)

        j=j+1;
        figure(12);
        fprintf('Please adjust the zoom and press return\n');
        pause;

        fprintf('Please select area %d (empty for return)\n',j)

        figure(12);
        p = ginput();
        if (isempty(p))
            break;
        end

        patch =  inpolygon(Y.coords{twod}(1,:), Y.coords{twod}(2,:), p(:,1), p(:,2));

        col=GiveDifferentColours(j);

        pointsIn = Y.coords{twod}(:,patch);
        figure(12);
        hold on;
    %     plot(pointsIn(1,:),pointsIn(2,:),['.',GiveAColour(j)]);
        plot(pointsIn(1,:),pointsIn(2,:), '.','Color',col,'LineWidth',3);
        hold off;

        figure(17);
        gofframe=find(Gif.frame==frame);
        thelevel=1;
        whichBelonging=Y.index(patch);
        disp(whichBelonging);
        for i=1:numel(whichBelonging)
            whichOne=whichBelonging(i);

            whichonecorr=Translatefromfirsttosecond(allGis.mapTracToTrajectories,whichOne,Gif.Gis{gofframe}.mapTracToTrajectories{thelevel});
            
            if (whichonecorr>0)
                hold on;
                line(track(:,1,whichonecorr),track(:,2,whichonecorr),'Color',col);
                plot(track(:,1,whichonecorr),track(:,2,whichonecorr),'+','Color',col);
                hold off;
            end
        end
    end
    fprintf('\n');
end















function Produceoriginalvideo(filenames,cim,noFrames,noGroups,dimtouse,trackLength,offext,sizeL,howmanyframes,endf)

if ( (~exist('noFrames','var')) || (isempty(noFrames)) )
    noFrames=100;
end
if ( (~exist('trackLength','var')) || (isempty(trackLength)) )
    trackLength=17;
end
if (~(mod(trackLength,2))) %if trackLength is not a odd number
    trackLength=trackLength-1;
end
if ( (~exist('endf','var')) || (isempty(endf)) )
    endf=(noFrames-trackLength+1);
end
if ( (~exist('offext','var')) || (isempty(offext)) )
    offext='';
end
if ( (~exist('howmanyframes','var')) || (isempty(howmanyframes)) )
    howmanyframes=1:endf;
end
if (any(howmanyframes>endf))
    howmanyframes=howmanyframes(howmanyframes<=endf);
end
if ( (~exist('sizeL','var')) || (isempty(sizeL)) )
    sizeL=round( (trackLength-1)/2 );
end
if ( (~exist('noGroups','var')) || (isempty(noGroups)) )
    noGroups=10;
end
if ( (~exist('dimtouse','var')) || (isempty(dimtouse)) )
    dimtouse=6;
end
if ( (~exist('cim','var')) || (~iscell(cim)) )
    if (exist(filenames.filename_colour_images,'file'))
        load(filenames.filename_colour_images);
        fprintf('Loaded colour images\n');
    else
        fprintf('cim needs to be loaded\n');
    end
end



filenamepicorvideobasename=[filenames.idxpicsandvideobasedir,'Videos',filesep];

count=0;
for frame=howmanyframes
    count=count+1;

    fc=frame+sizeL; %position of central frame in the sequence
    
    Init_figure_no(10);
    title(['Frame ',num2str(fc)]);
    imshow(cim{fc})
    orig(count)=getframe;
end
movie2avi(orig,[filenamepicorvideobasename,'orig_',num2str(noGroups),'_',num2str(dimtouse),offext,'.avi'],'compression','None','fps',7);


function Printimageandgroundtruth()


fc=69;

filenamepicorvideobasename=[filenames.filename_directory,'Videopicsidx_mns_ten',filesep,'Pics',filesep];

Init_figure_no(10);
imshow(cim{fc});
print('-depsc',[filenamepicorvideobasename,'orig_f_',num2str(fc),'.eps']);

Init_figure_no(13);
imshow(gtimages{fc});
print('-depsc',[filenamepicorvideobasename,'gt_f_',num2str(fc),'.eps']);



