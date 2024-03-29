function mergesteps=Definemergesteps(numberofdistances,numberofclusterings,setclustermethod,alldistances,noallsuperpixels)

%merge proceeds from mergesteps(i)+1 to mergesteps(i+1) (extrema included) with 1<=i<=(numberofclusterings)

switch (setclustermethod)
    
    case 'linear'
        %The mergesteps are defined on the base of the number of available
        %merges in a linear fashion
        
        mergesteps=0:numberofdistances/numberofclusterings:numberofdistances;
        mergesteps=unique(round(mergesteps));

    case 'log'
        %The mergesteps are defined on the base of the number of available
        %merges in a log fashion
        
        lognumdist=log(numberofdistances);
        
        mergesteps=0:lognumdist/numberofclusterings:lognumdist;
        mergesteps=numberofdistances-unique(round(exp(mergesteps)));
        mergesteps=mergesteps(end:-1:1);
        
    case 'distlinear'
        %The mergesteps are defined on the base of the distances to merge
        %in a linear fashion
        
        mindist=alldistances(1);
        maxdist=alldistances(end);
        distrange=(maxdist-mindist);
        diststeps=mindist+(0:distrange/numberofclusterings:distrange);
        mergesteps=zeros(1,(numberofclusterings+1));
        for i=2:(numberofclusterings+1)
            mergesteps(i)=find(alldistances<=diststeps(i),1,'last')-1; %<= to leave 1 label just to merge
        end
        mergesteps=unique(mergesteps);
        
    case 'distlog'
        %The mergesteps are defined on the base of the distances to merge
        %in a log fashion
        
        mindist=alldistances(1);
        maxdist=alldistances(end);
        minlogdist=log(mindist);
        maxlogdist=log(maxdist);
        logdistrange=(maxlogdist-minlogdist);
        diststeps=minlogdist+(0:logdistrange/numberofclusterings:logdistrange);
        diststeps=maxdist-unique(exp(diststeps));
        diststeps=diststeps(end:-1:1);
        mergesteps=zeros(1,(numberofclusterings+1));
        for i=2:(numberofclusterings+1)
            mergesteps(i)=find(alldistances<=diststeps(i),1,'last'); %<= and a margin to leave 1 label just to merge
        end
        mergesteps=unique(mergesteps);
        
    case 'numberofclusters'
        %The merge steps are the number of clusters to specify for k-means
        
        mergesteps=2:noallsuperpixels/numberofclusterings:noallsuperpixels;
        mergesteps=unique(round(mergesteps));

    case 'logclusternumber'
        %The merge steps are the number of clusters to specify for k-means
        %These merge steps use logaritmic growth of number of clusters
        
        lognumpoints=log(noallsuperpixels);
        
        mergesteps=log(2):lognumpoints/numberofclusterings:lognumpoints;
        mergesteps=unique(round(exp(mergesteps)));
        
     case 'adhoc'
        
        %These are the number of clusters specified for k-means, not merging steps
          mergesteps=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,40,50,60,70,80,100,150,200,250,300,350,400,500,600];
%         mergesteps=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,40,50,60,70,80,100,150,200,250,300,350,400,500,600];
%         mergesteps=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,40,50,60,70,80,100,125,150,175,200,233,266,300,333,366,450,400,500,550,600,700,800];
%         mergesteps=[1,2];
        
    otherwise
        
        mergesteps=[];
end


fprintf('setclustermethod %s:',setclustermethod); fprintf(' %g',mergesteps); fprintf('\n');

