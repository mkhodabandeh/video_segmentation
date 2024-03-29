function STM=Computespatiotemporalvelocitylargerfast(labelledlevelvideo,numberofsuperpixelsperframe,concc,conrr,flows,mapped,thedepth,stsimilarities,temporaldepth,printonscreen, options, theoptiondata, filenames)

%paper options:
% options.stmrefv=0.5; options.stmavf=false;

%optimized options (default):
% options.stmrefv=1.0; options.stmavf=true; options.stmlmbd=true;

if ( (~exist('temporaldepth','var')) || (isempty(temporaldepth)) )
    temporaldepth=1;
    %graphdepth used for stsimilarities is anyway the maximum temporal depth used
end
if ( (~exist('thedepth','var')) || (isempty(thedepth)) )
    thedepth=2;
end
if ( (~exist('printonscreen','var')) || (isempty(printonscreen)) )
    printonscreen=false;
end
printonscreeninsidefunction=false;
usecomplement=true;

noFrames=size(labelledlevelvideo,3);



%connectivity of stsimilarities is used to determine matches over-time,
%where to start building spatial neighbors from
[constrr,constcc]=Getconnectivityof(stsimilarities);



%Computation of all median flows and storage in array of the same size as mapped
allmedianu=zeros(size(mapped));
allmedianv=zeros(size(mapped));
for f=1:noFrames
    [velUm,velVm,velUp,velVp]=GetUandV(flows.flows{f});

    %compute median flows at the frame (or any other descriptor)
    for alabel=1:numberofsuperpixelsperframe(f)
        themask=(labelledlevelvideo(:,:,f)==alabel);
%         themask=(labelledlevelcell{f}==alabel);
        
        if ( (f<noFrames) && (f>1) )
            
            allmedianu(f,alabel)=median([velUp(themask);-velUm(themask)]);
            allmedianv(f,alabel)=median([velVp(themask);-velVm(themask)]);
        elseif (f<noFrames) %f==1
            allmedianu(f,alabel)=median(velUp(themask));
            allmedianv(f,alabel)=median(velVp(themask));
        else %f==noFrames
            allmedianu(f,alabel)=median(-velUm(themask));
            allmedianv(f,alabel)=median(-velVm(themask));
        end
    end
end
% Init_figure_no(6), imagesc(allmedianv)



[framebelong,labelsatframe,noallsuperpixels]=Getmappedframes(mapped);
maxnumberofsuperpixelsperframe=max(numberofsuperpixelsperframe);



% tic
% sxf=[];
% syf=[];
% svf=[];
% sxo=[];
% syo=[];
% svo=[];
averageconnectionthrough=4.5; averageconnectionsintra=5;
estimateintraterms=floor(noallsuperpixels+noallsuperpixels*(averageconnectionsintra^thedepth));
estimateinterterms=floor(estimateintraterms*(averageconnectionthrough^temporaldepth)/2);
sxf=zeros(estimateintraterms,1);
syf=zeros(estimateintraterms,1);
svf=zeros(estimateintraterms,1);
sxo=zeros(estimateinterterms,1);
syo=zeros(estimateinterterms,1);
svo=zeros(estimateinterterms,1);
noinsertedintra=0; noinsertedinter=0;
for f=1:noFrames
    spatf=find(framebelong==f);
    
    %the matrices accumulate the determined coefficient between the labels
    %at frame f and those at frames f:f+temporaldepth
    similarityatf=zeros(maxnumberofsuperpixelsperframe,maxnumberofsuperpixelsperframe); %symmetric matrix of sp at frame f
    similaritydonef=false(maxnumberofsuperpixelsperframe,maxnumberofsuperpixelsperframe); %at f neighbors may be considered multiple times
    similarityatothers=zeros(maxnumberofsuperpixelsperframe,maxnumberofsuperpixelsperframe,temporaldepth); %similarity between sp and those at other frames
    similaritydoneothers=false(maxnumberofsuperpixelsperframe,maxnumberofsuperpixelsperframe,temporaldepth); %used to extract data

    for asp=spatf %scan all superpixels at frame f
        %asp is in global labelling, localsp is in local labelling
        localsp=labelsatframe(asp);

        %the temporal connection are determined according to
        %stsimilarities, additionally only connecttions above a certain
        %threshold (minimum 1) can be considered
        tempneighlabels=constcc(constrr==asp); %global label
        tempneighlabels=[tempneighlabels;constrr(constcc==asp)]; %#ok<AGROW>

        %determine which frames these global labels correspond to
        tempneighframes=framebelong(tempneighlabels)';
        tempneighall=unique(tempneighframes);
        
        %include current frame
        tempneighall=[f;tempneighall]; %#ok<AGROW>
        %exclude frames out of bounds [f:f+temporaldepth]
        tempneighall( (tempneighall>(f+temporaldepth)) | (tempneighall<f) )=[];

        %process labels at each frame in the range
        for neighframe=tempneighall'
            if (neighframe==f)
                touchedlabels=asp;
            else
                touchedlabels=tempneighlabels(tempneighframes==neighframe);
            end

            neighlabels=Getneighborlabels(touchedlabels,concc,conrr,thedepth,printonscreeninsidefunction,labelledlevelvideo(:,:,neighframe),mapped);
%             neighlabels=Getneighborlabels(touchedlabels,concc,conrr,thedepth,printonscreeninsidefunction,labelledlevelcell{neighframe},mapped);
            neighlabels=unique([touchedlabels;neighlabels]); %include touchedlabels in neighlabels (included already for thedepth>1)

            for nl=1:numel(neighlabels)
                neighlabel=neighlabels(nl);
                neighlocallabel=labelsatframe(neighlabel);

                if (neighframe==f) %symmetric case
                    if (similaritydonef(localsp,neighlocallabel))
                        continue;
                    end
                    
                    similarityatf(localsp,neighlocallabel)=...
                        ( (allmedianu(f,localsp)-allmedianu(f,neighlocallabel))^2 + (allmedianv(f,localsp)-allmedianv(f,neighlocallabel))^2 );
                    similarityatf(neighlocallabel,localsp)= similarityatf(localsp,neighlocallabel);

                    similaritydonef(localsp,neighlocallabel)=true;
                    similaritydonef(neighlocallabel,localsp)=true;
                else %between sp at f and all others at other frames
                    
                    similarityatothers(localsp,neighlocallabel,neighframe-f)=...
                        ( (allmedianu(f,localsp)-allmedianu(neighframe,neighlocallabel))^2 + (allmedianv(f,localsp)-allmedianv(neighframe,neighlocallabel))^2 );
                    
                    similaritydoneothers(localsp,neighlocallabel,neighframe-f)=true;
                end
            end

        end
    end

    
    
    %complement the symmetry (neighbors are computed on f)
    if (usecomplement)
        for cf=1:min(noFrames-f,temporaldepth)
            spatf=find(framebelong==(cf+f));

            for asp=spatf %scan all superpixels at frame cf
                %asp is in global labelling, localsp is in local labelling
                localsp=labelsatframe(asp);

                %the temporal connection are determined according to
                %stsimilarities, additionally only connecttions above a certain
                %threshold (minimum 1) can be considered
                tempneighlabels=constcc(constrr==asp); %global label
                tempneighlabels=[tempneighlabels;constrr(constcc==asp)]; %#ok<AGROW>

                %determine which frames these global labels correspond to
                tempneighframes=framebelong(tempneighlabels)';

                %process labels at frame f
                touchedlabels=tempneighlabels(tempneighframes==f);

                neighlabels=Getneighborlabels(touchedlabels,concc,conrr,thedepth,printonscreeninsidefunction,labelledlevelvideo(:,:,f),mapped);
%                 neighlabels=Getneighborlabels(touchedlabels,concc,conrr,thedepth,printonscreeninsidefunction,labelledlevelcell{f},mapped);
                neighlabels=unique([touchedlabels;neighlabels]); %include touchedlabels in neighlabels (included already for thedepth>1)

                for nl=1:numel(neighlabels)
                    neighlabel=neighlabels(nl);
                    neighlocallabel=labelsatframe(neighlabel);

                    %between sp at cf+f and sp at f
                    if (similaritydoneothers(neighlocallabel,localsp,cf))
                        continue;
                    end

                    similarityatothers(neighlocallabel,localsp,cf)=...
                        ( (allmedianu(cf+f,localsp)-allmedianu(f,neighlocallabel))^2 + (allmedianv(cf+f,localsp)-allmedianv(f,neighlocallabel))^2 );

                    similaritydoneothers(neighlocallabel,localsp,cf)=true;
                end

            end
        end
    end
    
    
    
    [r,c]=find(similaritydonef);
    toinserthere=numel(r);
    if (toinserthere>0)
        sxf(noinsertedintra+1:noinsertedintra+toinserthere)=mapped(f,r)';
        syf(noinsertedintra+1:noinsertedintra+toinserthere)=mapped(f,c)';
        svf(noinsertedintra+1:noinsertedintra+toinserthere)=similarityatf(sub2ind(size(similarityatf),r,c));
    end
    noinsertedintra=noinsertedintra+toinserthere;
    
    for ff=1:temporaldepth
        velocitysimilarityframesff=similarityatothers(:,:,ff);
        velocitysimilaritydoneframesff=similaritydoneothers(:,:,ff);
        [r,c]=find(velocitysimilaritydoneframesff);
        toinserthere=numel(r);
        if (toinserthere>0)
            sxo(noinsertedinter+1:noinsertedinter+toinserthere)=mapped(f,r)';
            syo(noinsertedinter+1:noinsertedinter+toinserthere)=mapped(ff+f,c)';
            svo(noinsertedinter+1:noinsertedinter+toinserthere)=velocitysimilarityframesff(sub2ind(size(velocitysimilarityframesff),r,c));
        end
        noinsertedinter=noinsertedinter+toinserthere;
    end
    
end
% num_els =comp_stm_innerloops(labelsatframe,constcc,constrr,framebelong,noallsuperpixels,noFrames,temporaldepth,concc,conrr,thedepth,allmedianu,allmedianv,maxnumberofsuperpixelsperframe,usecomplement,mapped,sxf,svf,syf,sxo,svo,syo); 
% noinsertedinter = num_els(1);
% noinsertedintra = num_els(2);
% toc
sxf(noinsertedintra+1:end)=[];
syf(noinsertedintra+1:end)=[];
svf(noinsertedintra+1:end)=[];
sxo(noinsertedinter+1:end)=[];
syo(noinsertedinter+1:end)=[];
svo(noinsertedinter+1:end)=[];
fprintf('STM ratio estimate of terms to inserted intra %f (%d,%d), inter %f (%d,%d)\n',...
    estimateintraterms/noinsertedintra,estimateintraterms,noinsertedintra,...
    estimateinterterms/noinsertedinter,estimateinterterms,noinsertedinter);


% themean=mean(svf);
% thestd=std(svf);
% themin=min(svf);
% themax=max(svf);
% themedian=median(svf);
% fprintf('At frame: min %.10f, max %.10f, mean %.10f, median %.10f, std %0.10f\n',themin,themax,themean,themedian,thestd)
% themean=mean(svo);
% thestd=std(svo);
% themin=min(svo);
% themax=max(svo);
% themedian=median(svo);
% fprintf('At other frames: min %.10f, max %.10f, mean %.10f, median %.10f, std %0.10f\n',themin,themax,themean,themedian,thestd)



% sx=[sxf;sxo;syo]; sy=[syf;syo;sxo]; sv=[svf;svo;svo];
% afullmatrix=false(noallsuperpixels);
% count=0;
% for i=1:numel(sx)
%     if (afullmatrix(sx(i),sy(i)))
%         count=count+1;
%         fprintf('Element %d (frame %d, local label %d) - element %d (frame %d, local label %d)\n',...
%             sx(i),framebelong(sx(i)),labelsatframe(sx(i)),sy(i),framebelong(sy(i)),labelsatframe(sy(i)) );
%     end
%     afullmatrix(sx(i),sy(i))=true;
% end
% fprintf('Double elememts %d\n',count);



STM=Getstmfromindexedrawvalues([sxf;sxo;syo], [syf;syo;sxo], [svf;svo;svo], noallsuperpixels, options);

if (printonscreen)
    Init_figure_no(6); spy(STM(1:1000,1:1000));
    Init_figure_no(6); spy(STM);
end



%Add data to paramter calibration directory
if ( (isfield(options,'calibratetheparameters')) && (~isempty(options.calibratetheparameters)) && (options.calibratetheparameters) )
    thiscase='stm';
    printonscreenincalibration=false;
    Addthisdataforparametercalibration([sxf;sxo;syo],[syf;syo;sxo],[svf;svo;svo],thiscase,theoptiondata,filenames,noallsuperpixels,printonscreenincalibration);
end





function Compare_with_velocitylargersimilarities(velocitylargersimilarities,STM) %#ok<DEFNU>

isequal(velocitylargersimilarities,STM)

isequal(full(velocitylargersimilarities)>0,full(STM)>0)

max(max(abs(full(velocitylargersimilarities)-full(STM))))







