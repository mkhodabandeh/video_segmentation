function group=Selectwritegroups(track,dist_track_mask,filenames,frame,trackLength,image)


selected_groups_filename=[filenames.groups_filename_base,'f',num2str(frame,'%03d'),'tl',num2str(trackLength,'%03d'),'.mat'];
if (exist(selected_groups_filename,'file'))
    use_existing_groups=input('(1[default]) use existing groups or (2) define new groups: ');
    if (isempty(use_existing_groups)||(use_existing_groups==1))
        use_existing_groups=1;
    elseif (use_existing_groups~=2) %option not recognised
        fprintf('Option not recognised\n');
    end
else
    use_existing_groups=2;
end
if (use_existing_groups==1)
    load(selected_groups_filename);
    prevgroup=group;
    group=Selectgroupsfast(image,track,dist_track_mask,prevgroup);
elseif (use_existing_groups==2)
    group=Selectgroupsfast(image,track,dist_track_mask);
end

if (   ( (~(exist('prevgroup','var'))) || (~isequal(group,prevgroup)) )   &&   (~isempty(group))   )
    save_existing_groups=input('(1[default]) save defined groups or (2) not: ');
    if (isempty(save_existing_groups)||(save_existing_groups==1))
        save(selected_groups_filename, 'group','-v7.3');
    elseif (save_existing_groups~=2) %option not recognised
        fprintf('Option not recognised\n');
    end
end

%track = [ which frame , x or y , which trajectory ]
% dist_track_mask{which frame,which trajectory}=mask
%group{which group}=[tracks/dist_track_mask belonging to it]


