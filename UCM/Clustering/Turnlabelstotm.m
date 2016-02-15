function Tmi=Turnlabelstotm(labels,T,allowchanget)
%The function is compatible with labels with gaps

if ( (~exist('allowchanget','var')) || (isempty(allowchanget)) )
    allowchanget=false;
end
if ( (~exist('T','var')) || (isempty(T)) )
    T=true(numel(labels)); %if T is not passed, a fully connected graph is used
end

labels=reshape(labels,1,[]);

nolabels=numel(unique(labels)); %this method skips gaps _ to check
% nolabels=max(labels);

Tmi=Turnlabelstotmcore(labels,T);

if (allowchanget)
    addedlinks=0;
    newlabels=Turntmtolabels(Tmi);
    
    count=0;
    while (max(newlabels)>nolabels) %max(newlabels) is used for nonewlabels as Turntmtolabels does not produce gaps
        
        for i=1:max(labels)
            whichnewlabelsfori=unique(newlabels(i==labels));
            
            if (numel(whichnewlabelsfori)>1)
                one=find(newlabels==whichnewlabelsfori(1),1);
                for k=2:numel(whichnewlabelsfori)
                    two=find(newlabels==whichnewlabelsfori(k),1);
                    T(one,two)=true;
                    T(two,one)=T(one,two);
                    addedlinks=addedlinks+1;
                end
            end
        end

        Tmi=Turnlabelstotmcore(labels,T);
        newlabels=Turntmtolabels(Tmi);
        
        count=count+1;
    end
    
end

if (addedlinks>0)
    fprintf('Added %d links, %d iterations\n', addedlinks, count);
end

%to check
% whichlabelsa=unique(newlabelsa);
% for k=whichlabelsa
%     one=find(newlabelsa==k,1);
%     labelsonb=newlabelsb(one);
%     if (~  all( (newlabelsa==k)==(newlabelsb==labelsonb) )  )
%         fprintf('Difference encountered\n');
%     end
% end








function Tmi=Turnlabelstotmcore(labels,T)
%Cuts the edges linking different labels
%order of labels and gaps in numbering do no matter

noregions=size(T,1);

Tmi=T&(~logical(eye(noregions))); %removes ones on the diagonal

[r,c]=find(Tmi);

for i=1:numel(r)
    if (r(i)>c(i))
        continue;
    end

    if (labels(r(i))~=labels(c(i)))
        Tmi(r(i),c(i))=false;
        Tmi(c(i),r(i))=false;
    end

end

Tmi=Tmi|(logical(eye(noregions))); %reintroduces ones on the diagonal










function Tmi=Turnlabelstotm_prev(labels,T,allowchanget)

if ( (~exist('allowchanget','var')) || (isempty(allowchanget)) )
    allowchanget=false;
end

labels=reshape(labels,1,[]);

Tmi=Turnlabelstotmcore(labels,T);

if (allowchanget)
    addedlinks=0;
    newlabels=Turntmtolabels(Tmi);
    
    count=0;
    while (max(newlabels)>max(labels))
        
        for i=1:numel(labels)
            thoseasi=(labels(i)==labels);
            newthoseasi=(newlabels(i)==newlabels);
            
            adifferent=find(xor( thoseasi,newthoseasi ),1);
            
            if (~isempty(adifferent))
                aequal=find(newthoseasi,1);
                
                T(aequal,adifferent)=true;
                T(adifferent,aequal)=T(aequal,adifferent);
                addedlinks=addedlinks+1;
                
                break;
            end
        end

        Tmi=Turnlabelstotmcore(labels,T);
        newlabels=Turntmtolabels(Tmi);
        
        count=count+1;
    end
    
    %check
%     all(newlabels==labels)
%     i=find(newlabels~=labels,1);
%     
%     nl=find(newlabels==newlabels(i))
%     l=find(labels==labels(i))
end

if (addedlinks>0)
    fprintf('Added %d links, %d iterations\n', addedlinks, count);
end
