function [cim,ucm2,flows,allregionsframes,allregionpaths,correspondentPath,trajectories,mapPathToTrajectory,thetrajectorytree,selectedtreetrajectories]=...
    Doallprocessing(filenames,filename_sequence_basename_frames_or_video,ucm2filename,noFrames,options,videocorrectionparameters)

% Rewritesegmforbenchmark(filenames,filename_sequence_basename_frames_or_video,videocorrectionparameters);
% Rewriteimages(filenames,filename_sequence_basename_frames_or_video,noFrames);
% for i=1:numel(options.requestedaffinities)
%     disp(options.requestedaffinities{i});
% end
%allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0; flows=0; ucm2=0; cim=0; fprintf('Debug program return\n'); return;

options.noFramesMehran = noFrames;
%Create needed directories
Createalldirs(filenames);
Createalldirs(ucm2filename);
Createalldirs(filename_sequence_basename_frames_or_video);

global experimentmode

if (~exist('options','var'))
    options=[];
end
if (~exist('videocorrectionparameters','var'))
    videocorrectionparameters=0;
end
if (isfield(options,'useallobjects'))
    if (options.useallobjects==0)
        %the original mbcode is preserved
    elseif (options.useallobjects==1) %1 all (for recallprecision)
        if (isfield(filename_sequence_basename_frames_or_video,'mbcodeall'))
            %when not defined mbcodeall is the same as mbcode
            filename_sequence_basename_frames_or_video.mbcode=filename_sequence_basename_frames_or_video.mbcodeall;
        end
    elseif (options.useallobjects==2) %2 allin (for statistics and bmetric)
        if (isfield(filename_sequence_basename_frames_or_video,'mbcodeallin'))
            %when not defined mbcodeallin is the same as mbcode
            filename_sequence_basename_frames_or_video.mbcode=filename_sequence_basename_frames_or_video.mbcodeallin;
        end
    else
        fprintf('Option for useallobjects not recognised, using mbcode\n');
    end
end
if ( (~isfield(options,'cleanifexisting')) || (isempty(options.cleanifexisting)) )
    cleanifexisting=Inf;
else
    cleanifexisting=options.cleanifexisting;
end
%cleanifexisting == n implies deleting and recomputing variables starting from n (also replaced)
% 0 all(bfiles), 1 cim, 2 flows, 3 ucm2, 4 filtered flows, 5 newucm2-allsegs, 6 higher-order, 7 merge-higher-order, 8 propagate labels
%For other segmentations: 2 overwrite the other segmentations, 4 overwrite dob,dobho
temporalmedianfilter=true; %NOTE: inserted with the median in-superpixel filtering
temporalmediandepth=2; %1(4 flows in the median for +-1 frames), 2(8 flows in the median for +-2 frames)
twolessedges=false; %option to exclude one flow from the edge frames, unless already excluded at the first and last frames

printonscreen=false;


if (cleanifexisting==0) %This requests recomputation of all variables
    %This option is usually adopted for computing differently resized images
    %The Brox flow and long term trajectories are deleted
    if ( (isfield(filename_sequence_basename_frames_or_video,'btracksfile')) && (~isempty(filename_sequence_basename_frames_or_video.btracksfile)) &&...
            (exist(filename_sequence_basename_frames_or_video.btracksfile,'file')) )
        delete(filename_sequence_basename_frames_or_video.btracksfile)
        fprintf('btracksfile (%s) removed\n', filename_sequence_basename_frames_or_video.btracksfile);
        filename_sequence_basename_frames_or_video.btracksfile=[];
    end
    if ( (isfield(filename_sequence_basename_frames_or_video,'bflowdir')) && (~isempty(filename_sequence_basename_frames_or_video.bflowdir)) &&...
            (exist(filename_sequence_basename_frames_or_video.bflowdir,'dir')) )
        rmdir(filename_sequence_basename_frames_or_video.bflowdir,'s');
        fprintf('bflowdir (%s) removed\n', filename_sequence_basename_frames_or_video.bflowdir);
        filename_sequence_basename_frames_or_video.bflowdir=[];
    end
end
% if ( (isfield(filename_sequence_basename_frames_or_video,'btracksfile')) && (~isempty(filename_sequence_basename_frames_or_video.btracksfile)) &&...
%         (exist(filename_sequence_basename_frames_or_video.btracksfile,'file')) )
%     system(['cp ',filename_sequence_basename_frames_or_video.btracksfile,' ',filenames.benchmark,filenames.casedirname,'_tracks.dat'])
% end
% allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0; flows=0; ucm2=0; return;

if ( (exist(filenames.filename_colour_images,'file')) && (cleanifexisting>1) )
    load(filenames.filename_colour_images);
    fprintf('Loaded colour images\n');
else
    %reads the video sequence or the frames
    if isstruct(filename_sequence_basename_frames_or_video)
        cim=Readpictureseries(filename_sequence_basename_frames_or_video.basename,...
            filename_sequence_basename_frames_or_video.number_format,filename_sequence_basename_frames_or_video.closure,...
            filename_sequence_basename_frames_or_video.startNumber,noFrames,printonscreen);
    else
        cim=cell(1,noFrames);
        for i=1:noFrames
            [outImages,filename]=Gettwoframes(filename_sequence_basename_frames_or_video,i);
            if (size(outImages{1},1)==1)&&(size(outImages{1},2)==1)&&(outImages{1}==0) %if the matrix is a point
                fprintf('Could not load images\n');
                return;
            end
    %         fprintf('%s\n',filename{1});
            cim{i}=outImages{1};
        end
        clear outImages;
        clear filename;
    end
    if (printonscreen)
        close all;
    end
    
    cim=Adjustimagesize(cim,videocorrectionparameters,printonscreen);
    %Adjustimagesize(cim,videocorrectionparameters,true);
    
    %saves the images
    save(filenames.filename_colour_images, 'cim','-v7.3');
    fprintf('Loaded colour images and saved\n');
end



if ( (isfield(options,'vsmethod')) && (~isempty(options.vsmethod)) && (~strcmp(options.vsmethod,'affinities')) && (~strcmp(options.vsmethod,'dobho')) && (~strcmp(options.vsmethod,'dob')) && (~strcmp(options.vsmethod,'bln')) ) %Run a different video segmentation algorithm
    printonscreen=false;
    
    %The Brox flow and tracks need to be deleted outside the processing function
    if (  (cleanifexisting<3)  &&  ( (strcmp(options.vsmethod,'spb')) || (strcmp(options.vsmethod,'spbnz')) )  )
        if ( (isfield(filename_sequence_basename_frames_or_video,'btracksfile')) && (~isempty(filename_sequence_basename_frames_or_video.btracksfile)) &&...
                (exist(filename_sequence_basename_frames_or_video.btracksfile,'file')) )
            delete(filename_sequence_basename_frames_or_video.btracksfile)
            fprintf('btracksfile (%s) removed\n', filename_sequence_basename_frames_or_video.btracksfile);
            filename_sequence_basename_frames_or_video.btracksfile=[];
        end
        if ( (isfield(filename_sequence_basename_frames_or_video,'bflowdir')) && (~isempty(filename_sequence_basename_frames_or_video.bflowdir)) &&...
                (exist(filename_sequence_basename_frames_or_video.bflowdir,'dir')) )
            rmdir(filename_sequence_basename_frames_or_video.bflowdir,'s');
            fprintf('bflowdir (%s) removed\n', filename_sequence_basename_frames_or_video.bflowdir);
            filename_sequence_basename_frames_or_video.bflowdir=[];
        end
    end
    if (  (cleanifexisting<3)  &&  ( (strcmp(options.vsmethod,'spo')) || (strcmp(options.vsmethod,'sponz')) )  )
        otracksfile='Tracksnoframesochsbrox.dat'; %This is the file with the higher-order tracks

        %The computed file is kept
        [btracksbase,valid]=Locatefiledir(otracksfile,filenames.filename_directory);
        if (valid)
            delete([btracksbase,otracksfile])
            fprintf('otracksfile (%s) removed\n', [btracksbase,otracksfile]);
        end
    end
    
    if ( (cleanifexisting<3) || (~Isallsegsalreadycomputed(filenames,options)) ) %allthesegmentations=Loadallsegs(filenames,options);
        %Process with other segmentation code and benchmark (the function integrates faffinityv)
        Processwithotherandbenchmark(cim,filenames,options,... %[allthesegmentations,newucm2]=
            filename_sequence_basename_frames_or_video,videocorrectionparameters,printonscreen);
    end
    
    allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
    flows=0; ucm2=0;
    return;
end

%% Experimentmode == 0
if experimentmode == 0
%Computes the flows
if ( (exist(filenames.filename_flows,'file')) && (cleanifexisting>2) )
    load(filenames.filename_flows);
    fprintf('Loaded flows\n');
else
    %gets the flows
    fprintf('Computing all flows\n');
    tic
    flows.whichDone=zeros(1,noFrames); %Addflow does not change the flows which appear to be already done
    flows.flows=cell(1,noFrames);
    
    if ( (isfield(options,'usebflow')) && (options.usebflow) )
        [flows,filename_sequence_basename_frames_or_video]=Computebflow(filename_sequence_basename_frames_or_video,flows,noFrames,cim,filenames);
        %The function also modifies the fields btracksfile and bflowdir of filename_sequence_basename_frames_or_video
    else
        for i=1:noFrames
          flows=Addflow(flows,cim,i,noFrames,printonscreen);
        end
    end
    
    if (any(flows.whichDone==0))
        fprintf('Flow computation\n');
        allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
        flows=0; ucm2=0;
        return;
    end
    
    if (printonscreen)
        close all;
    end

    %saves the flows
    save(filenames.filename_flows, 'flows','-v7.3');
    toc
    fprintf('Flows computed and saved\n');
%     error('done');
end


%Filter the flow temporally and compute statistcs
% if (temporalmedianfilter) %NOTE: inserted with the median in-superpixel filtering
%     [flows]=Mediantimefilter(flows,temporalmediandepth,twolessedges); %,flowwasmodified
%     fprintf('Flows temporally median filtered\n');
% end


processsomeframes=[];
if ( (isfield(options,'testthesegmentation')) && (options.testthesegmentation) )
    printonscreeninsidefunction=false;
    
    %Read the single of mutliple gt annotations
    ntoreadmgt=Inf; %1, 2, .. Inf number of gts to read
    maxgtframes=Inf; %Limit max frame for gt (impose same test set)
    [multgts,gtfound,nonemptygt]=Loadmultgtimagevideo(noFrames,filename_sequence_basename_frames_or_video,ntoreadmgt,maxgtframes,printonscreeninsidefunction); %#ok<ASGLU> %,numbernonempty

    %verify that at least a gt image is present
    if (~gtfound)
        error('Segmentation test requested, but no gt found\n');
    end
    
    processsomeframes=find(any(nonemptygt,1));
end


if ( (~isfield(options,'origucm2')) || (isempty(options.origucm2)) || (options.origucm2) )
    replacetheucm=(cleanifexisting<=3);
    
    %%%Ucmorig
    
    %reads the segmented video frames
    [ucm2,valid]=Readpictureseries(ucm2filename.basename,...
        ucm2filename.number_format,ucm2filename.closure,...
        ucm2filename.startNumber,noFrames,printonscreen);

    if ( (~valid) || (replacetheucm) )

        if 2 == 2 %EDITED BY MEHRAN
        additionalucmname=[]; %[]
        allowwarping=[]; %[] Boolean is for default: warping is used for wrpbasename cases
        [basenameforucm2,numberforucm2,closureforucm2,startNumberforucm2]=...
            Nameucmfiles(filename_sequence_basename_frames_or_video,cim,additionalucmname,allowwarping,flows,replacetheucm,printonscreen);

        %launch the segmentation algorithm in linux with basenameforucm2,
        %numberforucm2, closureforucm2, startNumberforucm2 to compute ucm2
        %and save them into ucm2filename
        clear flows; clear cim; %to free memory for the computation
        startNumberforucm2=startNumberforucm2+ucm2filename.startNumber;
        ucm2procvalid=Getchosensegmentation(basenameforucm2,numberforucm2,closureforucm2,startNumberforucm2,...
            noFrames,ucm2filename,options,printonscreen,replacetheucm,processsomeframes);
        if (~ucm2procvalid)
            fprintf('Could not compute the hierarchical segmentation (not a linux session?)\n');
            allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
            flows=0; cim=0;
            return;
        end
        end % EDITED BY MEHRAN
        %read the cim and flows and ucm2 files again, this part does not
        %check but assumes that the files all exist
        fprintf('Computation of hierarchical segments completed\n');
        load(filenames.filename_colour_images);
        load(filenames.filename_flows);
%         if (temporalmedianfilter) %NOTE: inserted with the median in-superpixel filtering
%             [flows]=Mediantimefilter(flows,temporalmediandepth); %,flowwasmodified
%         end
        [ucm2,valid]=Readpictureseries(ucm2filename.basename,...
            ucm2filename.number_format,ucm2filename.closure,...
            ucm2filename.startNumber,noFrames,printonscreen);
        fprintf('Re-loaded the colour images and flows and loaded the ucm2s (valid %d)\n',valid);
    end
else %This section skips deleting and reloading cim and flows
    replacetheucm=(cleanifexisting<=3);
    
    %Recipient for generated UCM2 segmentation with flow
    ucm2flow=ucm2filename;
    if ( (isfield(options,'usebflow')) && (options.usebflow) )
        ucm2flow.basename=[ucm2filename.basename,'bnew'];
    else
        ucm2flow.basename=[ucm2filename.basename,'new'];
    end
    
    %%%Ucmminmax
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=false; %true(tanh), false(linear remapping)
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,[],printonscreen);
    
    %%%Ucmexp3
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=2; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     minmax=[0,3];
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);
    
    %%%Ucmexp1notmed
    usepureflow=true; %true(just flow in ab), false(color ab with flow)
    usetanh=2; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
    usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
    minmax=[0,1];
    Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);
    
    %%%Ucmexp1tmeddepth1
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=2; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     minmax=[0,1];
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);
    
    %%%Ucmtanh3
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=true; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     minmax=[0,3];
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);
    
    %%%Ucmexp1tmeddepth1d5
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=2; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     minmax=[0,1];
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);

    %%%Ucmexp1
%     usepureflow=true; %true(just flow in ab), false(color ab with flow)
%     usetanh=2; %true(tanh), false(linear remapping), 2((1-e^-x)/(1+e^-x))
%     usemeanstd=false; %true(mean, std), false([min,max] or [0,1])
%     minmax=[0,1];
%     Rgb=Getnewimages(cim,flows,usepureflow,usetanh,usemeanstd,minmax,printonscreen);

    
    
    %Images from flow
    if ( (isfield(options,'usebflow')) && (options.usebflow) )
        colorflowname='bcfn'; %'colorflow'(color ab with flow), 'cfp'(just flow in ab), 'cfn'(just flow in ab normalized with min/max flows)
    else
        colorflowname='cfn'; %'colorflow'(color ab with flow), 'cfp'(just flow in ab), 'cfn'(just flow in ab normalized with min/max flows)
    end
    allowwarping=false;
    [basenameforcolor,numberforcolor,closureforcolor,startNumberforcolor]=...
        Nameucmfiles(filename_sequence_basename_frames_or_video,Rgb,colorflowname,allowwarping,flows,replacetheucm,printonscreen);
    
    %Images from original images
    if ( (isfield(options,'usebflow')) && (options.usebflow) )
        additionalucmname='bucm'; %TODO: this basename should be emtpy
    else
        additionalucmname='ucm'; %TODO: this basename should be emtpy
    end
    allowwarping=false;
    [basenameforucm2,numberforucm2,closureforucm2,startNumberforucm2]=...
        Nameucmfiles(filename_sequence_basename_frames_or_video,cim,additionalucmname,allowwarping,flows,replacetheucm,printonscreen);
    setenv('LD_LIBRARY_PATH', '/home/khoreva/Copy_of_VSG/:$LD_LIBRARY_PATH');
    
    if 1 == 2 %added by MEHRAN
    ucm2procvalid=Getchosensegmentationwithcolor(basenameforucm2,numberforucm2,closureforucm2,startNumberforucm2,...
        noFrames,ucm2flow,options,printonscreen,basenameforcolor,numberforcolor,closureforcolor,startNumberforcolor,replacetheucm,processsomeframes);
    if (~ucm2procvalid)
        fprintf('Could not compute the hierarchical segmentation (not a linux session?)\n');
        allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
        flows=0; cim=0;
        return;
    
    end
    else
        fprintf('MEHRAN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5\n')
    end
    %Adopt the new colored segmentation
    fprintf('Computation of colored hierarchical segments completed\n');
    [ucm2,valid]=Readpictureseries(ucm2flow.basename,...
        ucm2flow.number_format,ucm2flow.closure,...
        ucm2flow.startNumber,noFrames,printonscreen);
    fprintf('Loaded the ucm2s (valid %d)\n',valid);
end

end
% end of experiment == 0 section
%%
%For interrupting calculation after segmentation
% allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
% flows=0; cim=0;
% return;
%  cim=Adjustimagesize(cim,videocorrectionparameters,printonscreen);


%Run benchmark code from Berkeley: add images to the directory
if ( (isfield(options,'testthesegmentation')) && (~isempty(options.testthesegmentation)) && (options.testthesegmentation) )
    if ( (isfield(options,'segaddname')) && (~isempty(options.segaddname)) )
        additionalmasname=options.segaddname;
    else
        additionalmasname='Ucm'; fprintf('Using standard additional name %s, please confirm\n',additionalmasname); pause;
    end
    Addcurrentimageforrpmultgt(cim,ucm2,filename_sequence_basename_frames_or_video,videocorrectionparameters,filenames,additionalmasname,printonscreen);
    
    allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
    return;
end


if ( (isfield(options,'vsmethod')) && (~isempty(options.vsmethod)) && ((strcmp(options.vsmethod,'dobho'))||(strcmp(options.vsmethod,'dob'))) ) %Run dob,dobho algorithms (this requires ucm2)
    printonscreen=false;
    
    if ( (cleanifexisting<5) || (~Isallsegsalreadycomputed(filenames,options)) ) %allthesegmentations=Loadallsegs(filenames,options);
        %Process with other segmentation code and benchmark (the function integrates faffinityv)
        Processwithotherandbenchmark(cim,filenames,options,... %[allthesegmentations,newucm2]=
            filename_sequence_basename_frames_or_video,videocorrectionparameters,printonscreen,ucm2); %This additionally includes ucm2
    end
    
    allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
    return;
end


if ( (isfield(options,'vsmethod')) && (~isempty(options.vsmethod)) && (strcmp(options.vsmethod,'bln')) ) %Run bln algorithms (this requires ucm2 and flows)
    printonscreen=false;
    
    if ( (cleanifexisting<5) || (~Isallsegsalreadycomputed(filenames,options)) ) %allthesegmentations=Loadallsegs(filenames,options);
        %Process with other segmentation code and benchmark (the function integrates faffinityv)
        Processwithotherandbenchmark(cim,filenames,options,... %[allthesegmentations,newucm2]=
            filename_sequence_basename_frames_or_video,videocorrectionparameters,printonscreen,ucm2,flows); %This additionally includes ucm2 and flows
    end
    
    allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
    return;
end



if experimentmode == 0
%Filter the flow temporally and compute statistcs
if (temporalmedianfilter)
    [flows]=Mediantimefilter(flows,temporalmediandepth,twolessedges); %,flowwasmodified
    fprintf('Flows temporally median filtered\n');
end


%Filter the flows


if ( (isfield(options,'filter_flow')) && (options.filter_flow) )
    if ( (isfield(options,'pre_filter_flow')) && (options.pre_filter_flow) )
        %for compatibility, if not indicated in options the flow is not pre-filtered
        if ( (exist(filenames.filename_filtered_flows,'file')) && (cleanifexisting>4) )
            load(filenames.filename_filtered_flows);
            fprintf('Loaded filtered flows\n');
        else %Filter the flow
            filtertic=tic;
            
            %Level at which to threshold the UCM2 to get the superpixels:
            %for compatibility and comparison, this is chosen to be 1, notwithstanding ucm2level
             if ( (isfield(options,'ucm2level')) && (~isempty(options.ucm2level)) )
                 Level=options.ucm2level;
             else
                Level=1;
             end
            %Get the labels at all frames at Level
            %Added by MEHRAN
            if 1 == 2
                allthelabels=Getalllabels(ucm2,Level);
            else
                global labelledlevelvideo_path;
                path = sprintf(labelledlevelvideo_path, Level);
                load(path);
                %load('/cs/vml2/mkhodaba/cvpr16/VSB100/VideoProcessingTemp/vw_commercial/labelledlevelvideo.mat');
                allthelabels = cell(1, noFrames);
                for fr = 1:noFrames
                    allthelabels{fr} = labelledlevelvideo(:,:,fr);
                end
            end
            %Filter the flows, not applied if flows.whichDone(f)==3
            flowfilter='median'; %median, bilateral
            if (strcmp(flowfilter,'median'))
                [flows,flowwasmodified]=Medianfilterflows(flows,allthelabels);
            else
                [flows,flowwasmodified]=Filtertheflows(flows,allthelabels);
            end
            if ( (flowwasmodified) || (~(exist(filenames.filename_filtered_flows,'file'))) ) %saves the flows if modified
                fprintf('Flows filtered\n');
                try
                    save(filenames.filename_filtered_flows, 'flows','-v7.3');
                    fprintf('Filtered flows saved\n');
                catch ME %#ok<NASGU>
                    fprintf('Filtered flows not saved (try..catch)\n');
                end
                toc(filtertic)
            else
                fprintf('Flows already filtered\n');
            end
        end
    end
    %To restore unfiltered flows
    % load(filenames.filename_flows);
end
%    error('done');
else %experimentmode == 1
    flows = 0;
    ucm2 = 0;
end


%Compute video segmentation
if ( (isfield(options,'newucmtwo')) && (options.newucmtwo) )%Test on options.testnewsegmentation, replaced here by options.newucmtwo

%     if ( (cleanifexisting<6) || (~Isallsegsalreadycomputed(filenames,options)) ) 
%             allthesegmentations=Loadallsegs(filenames,options);

        printonscreen=false;

        %Process video segmentation
        if ( (~isfield(options,'faffinityv')) || (isempty(options.faffinityv)) )
            Processvideosegandbenchmark(cim,flows,ucm2,filenames,options,...
                    filename_sequence_basename_frames_or_video,videocorrectionparameters,printonscreen); %[allthesegmentations,newucm2]=
        else % Subsets of ucm2 and flows allow to consider only some frames
            partlength=min(options.faffinityv,numel(ucm2));
            partucm2=ucm2(1:partlength);
            partcim=cim(1:partlength);
            partflows.whichDone=flows.whichDone(1:partlength);
            partflows.flows=flows.flows(1:partlength);
            Processvideosegandbenchmark(partcim,partflows,partucm2,filenames,options,...
                    filename_sequence_basename_frames_or_video,videocorrectionparameters,printonscreen); %[allthesegmentations,newucm2]=
        end
    
%     end
end



%Clustering statistics benchmark
if (  ( (isfield(options,'testmanifoldclustering')) && (~isempty(options.testmanifoldclustering)) && (options.testmanifoldclustering) )  ||...
        ( (isfield(options,'testbmetric')) && (~isempty(options.testbmetric)) && (options.testbmetric) )  ||...
        ( (isfield(options,'testnewsegmentation')) && (~isempty(options.testnewsegmentation)) && (options.testnewsegmentation) )  )
    allregionsframes=0; allregionpaths=0; correspondentPath=0; trajectories=0; mapPathToTrajectory=0; thetrajectorytree=0; selectedtreetrajectories=0;
    return;
end










