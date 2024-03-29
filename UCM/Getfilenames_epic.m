function filenames=Getfilenames(directory,casedir,options)

if (~exist('casedir','var'))
    casedir=[];
end
if (~exist('options','var'))
    options=[];
end

if (~exist('directory','var'))
    
    if (ispc)
        directory=['D:',filesep];
    else
        directory=[filesep,'media',filesep,'Data',filesep];
    end
    if (~isempty(casedir))
        filenames.filename_directory=[directory,casedir,filesep];
    else
        filenames.filename_directory=directory;
    end
    
else
    
    if (isempty(casedir))
        wherefs=strfind(directory,filesep);
        if (numel(wherefs)<=1)
            filenames.filename_directory=directory;
            casedir=[];
        else
            casedir=directory(wherefs(end-1)+1:wherefs(end)-1); %excludes filesep
            directory=directory(1:wherefs(end-1)); %includes filesep
            filenames.filename_directory=[directory,casedir,filesep];
        end
    else
        filenames.filename_directory=[directory,casedir,filesep];
    end
    
end

if (~isempty(casedir))
    casedirname=lower(casedir);
    wherefs=strfind(casedirname,filesep);
    casedirname(wherefs)='_';
else
    casedirname=[];
end

filenames.casedirname=casedirname; %lower case name of the chosen case with filesep's replaced with underscores
filenames.filename_colour_images=[filenames.filename_directory,'cim.mat'];
if ( (isfield(options,'usebflow')) && (options.usebflow) )
    filenames.filename_flows=[filenames.filename_directory,'bflows.mat'];
    filenames.filename_filtered_flows=[filenames.filename_directory,'bfilteredflows.mat'];
else
    filenames.filename_flows=[filenames.filename_directory,'flows_epic.mat'];
    filenames.filename_filtered_flows=[filenames.filename_directory,'filteredflows_epic.mat'];
end
filenames.filename_allregionsframes=[filenames.filename_directory,'regframe.mat'];
filenames.filename_allregionsframes_all=[filenames.filename_directory,'regframe_1to70.mat'];
filenames.filename_similarities=[filenames.filename_directory,'similars.mat'];
filenames.filename_similarities_all=[filenames.filename_directory,'similars_1to70.mat'];
filenames.filename_trajectories=[filenames.filename_directory,'trajec.mat'];
filenames.filename_trajectories_all=[filenames.filename_directory,'trajec_all.mat'];
filenames.filename_forward_backward_with_scrambled_map=[filenames.filename_directory,'bimcpath.mat'];
filenames.filename_forward_backward_with_length_map=[filenames.filename_directory,'bilcpath.mat'];
filenames.filename_backward_with_scrambled_map=[filenames.filename_directory,'momcpath.mat'];
filenames.filename_backward_with_length_map=[filenames.filename_directory,'molcpath.mat'];
filenames.filename_map=[filenames.filename_directory,'map.mat'];
filenames.filename_map_backup=[filenames.filename_directory,'mapgoodone.mat'];
filenames.bin_count_histograms=[filenames.filename_directory,'bin_count_hist.mat'];
filenames.bin_count_histograms=[filenames.filename_directory,'bin_count_histbackup.mat'];
filenames.filename_normalisedsimilarities=[filenames.filename_directory,'normsims.mat'];
filenames.filename_normalisedsimilarities_notnormalisedfirst=[filenames.filename_directory,'normsimsnnf.mat'];
filenames.filename_normalisedsimilarities_all=[filenames.filename_directory,'normsims1_70.mat'];
filenames.filename_normalisedsimilarities_prior=[filenames.filename_directory,'normalisedsimilaritiesprior.mat'];
filenames.filename_normalisedsimilarities_priornotnormalisedfirst=[filenames.filename_directory,'normalisedsimilaritiespriornnf.mat'];
filenames.filename_forward_backward_with_scrambled_map_log=[filenames.filename_directory,'bimcpath_log.mat'];
filenames.filename_forward_backward_with_length_map_log=[filenames.filename_directory,'bilcpath_log.mat'];
filenames.filename_backward_with_scrambled_map_log=[filenames.filename_directory,'momcpath_log.mat'];
filenames.filename_backward_with_length_map_log=[filenames.filename_directory,'molcpath_log.mat'];
filenames.filename_trajectories_log=[filenames.filename_directory,'trajec_log.mat'];
filenames.filename_trajectories_alllog=[filenames.filename_directory,'trajec_all_log.mat'];
filenames.filename_vijay_regiontrajectories=[filenames.filename_directory,'region_trajectories.mat'];
filenames.filename_vijay_regiontrajectoriespurged=[filenames.filename_directory,'region_trajectories_purged.mat'];
filenames.filename_distancematricesbase=[filenames.filename_directory,'track_regions_matrices',filesep,'distance_matrices_'];
filenames.filename_trackregiontrackbase=[filenames.filename_directory,'track_regions_matrices',filesep,'track_region_'];
filenames.filename_vijay_regionpixellocations=[filenames.filename_directory,'region_pixel_locations.mat'];
filenames.sigma_filename_base=[filenames.filename_directory,'sigmas',filesep,'sigmas_'];
filenames.predictedmasks_filename_base=[filenames.filename_directory,'predictedmasks',filesep,'predictedmasks_'];
filenames.groups_filename_base=[filenames.filename_directory,'track_regions_matrices',filesep,'groups_'];
filenames.toboujou_filename_base=[filenames.filename_directory,'boujou',filesep,'toboujou_'];
filenames.fromboujou_filename_base=[filenames.filename_directory,'boujou',filesep,'fromboujou_'];
filenames.the_clustering_solution=[filenames.filename_directory,'solution.mat'];

filenames.tree_of_trajectories=[filenames.filename_directory,'treeoftrajectories.mat'];
filenames.tree_of_trajectories_base_updated=[filenames.filename_directory,'Treeselectedtrajectories',filesep,'treeoftrajectoriesupdated_'];
filenames.base_selected_trajectories=[filenames.filename_directory,'Treeselectedtrajectories',filesep,'selectedtreetrajectories_'];
filenames.selected_tree_trajectories=[filenames.filename_directory,'selectedtreetrajectories.mat'];

filenames.filename_bmerged_regions=[filenames.filename_directory,'bmergedvariables.mat'];

filenames.spectral_partioning_boundaries=[filenames.filename_directory,'spboundaries.mat'];

filenames.the_gif_file=[filenames.filename_directory,'gif.mat'];

filenames.idxpicsandvideobasedir=[filenames.filename_directory,'Videopicsidx',filesep];
filenames.the_isomap_yre=[filenames.idxpicsandvideobasedir,'yre.mat'];
filenames.videopicsidx_idx=[filenames.idxpicsandvideobasedir,'Idx',filesep];
filenames.videopicsidx_pics=[filenames.idxpicsandvideobasedir,'Pics',filesep];
filenames.videopicsidx_videos=[filenames.idxpicsandvideobasedir,'Videos',filesep];
filenames.the_tree_structure=[filenames.idxpicsandvideobasedir,'treestructure.mat'];

filenames.shareddir=[directory,'Shared',filesep]; %includes filesep
filenames.shared_for_likelihood=[filenames.shareddir,'shared_for_likelihood.mat'];

filenames.newucmtwo=[filenames.filename_directory,'newucmtwo.mat'];
filenames.benchmark=[filenames.shareddir,'Benchmark',filesep];


all_names={... %list of the recognised cases (for d to p transformation)
'EWCmov06', 'EWCstc05', 'EWCmov', ...
'EWCstc', ['Toyota',filesep,'seq3n'],'DSCF4045n',...
'EWCmovwrpitp','EWCmovwrp','EWCmov06mmp',...
'EWCmov06wrp','EWCmov06mmpwrp','EWCstc05wrp'};

id=0; %0 means unrecognised case
if (~isempty(casedir))
    for j=1:numel(all_names)
        if (strcmp(all_names{j},casedir))
            id=j;
            break;
        end
    end
end
filenames.id=id;

filenames.shared_best_transformations=[filenames.shareddir,'shared_best_transformations.mat'];
filenames.shared_best_combinations=[filenames.shareddir,'shared_best_combinations.mat'];

%%%new set of shared best combination and transformation vectors%%%
%The vectors are learnt on the G graph:
%useg=true; usemindistance=true; completesptree=false; usefcsptree=false; _completing is done with allDs.D_mindist_mindistregions (same as mindistance)
filenames.shared_best_transformations_movand06mov_ev2=[filenames.shareddir,'shared_best_transformations_movand06mov_ev2.mat'];
filenames.shared_best_combinations_movand06mov_ev2=[filenames.shareddir,'shared_best_combinations_movand06mov_ev2.mat'];
filenames.shared_best_transformations_movand06movlonger35_ev2=[filenames.shareddir,'shared_best_transformations_movand06movlonger35_ev2.mat'];
filenames.shared_best_combinations_movand06movlonger35_ev2=[filenames.shareddir,'shared_best_combinations_movand06movlonger35_ev2.mat'];
filenames.shared_best_transformations_movand06movlonger51_ev1=[filenames.shareddir,'shared_best_transformations_movand06movlonger51_ev1.mat'];
filenames.shared_best_combinations_movand06movlonger51_ev1=[filenames.shareddir,'shared_best_combinations_movand06movlonger51_ev1.mat'];
%%%%%%


%%%Previously defined shared best combination and transformation vectors%%%
filenames.shared_best_transformations_case_13=[filenames.shareddir,'shared_best_transformationsc13.mat'];
filenames.shared_best_combinations_case_13=[filenames.shareddir,'shared_best_combinationsc13.mat']; %best_combination_vector learnt on the G forest of trees
filenames.shared_best_transformations_fully_connected=[filenames.shareddir,'shared_best_transformationsfc.mat'];
filenames.shared_best_combinations_fully_connected=[filenames.shareddir,'shared_best_combinationsfc.mat']; %best_combination_vector learnt on the fully connected graph
filenames.shared_best_transformations_fc_sptree=[filenames.shareddir,'shared_best_transformationsfcsptree.mat'];
filenames.shared_best_combinations_fc_sptree=[filenames.shareddir,'shared_best_combinationsfcsptree.mat']; %best_combination_vector learnt on the spanning tree
filenames.shared_best_combinations_ad_hoc=[filenames.shareddir,'shared_best_combinations_ad_hoc.mat']; %P=1-0.001*allDs.D_mindist_mindistregions
%other sets of best features learnt of on the G graph (usefullyconnected=false using Addtosflfromthismaxframe)
filenames.shared_best_transformations_c13_ewc06movwrp_ev2=[filenames.shareddir,'shared_best_transformations_06mov_ev2.mat'];
filenames.shared_best_combinations_c13_ewc06movwrp_ev2=[filenames.shareddir,'shared_best_combinations_06mov_ev2.mat'];
filenames.shared_best_transformations_c13_ewc06movwrpmovmmpwrp_ev4=[filenames.shareddir,'shared_best_transformations_06movandmmp_ev4.mat'];
filenames.shared_best_combinations_c13_ewc06movwrpmovmmpwrp_ev4=[filenames.shareddir,'shared_best_combinations_06movandmmp_ev4.mat'];
filenames.shared_best_transformations_c13_ewc06movwrpmovmmpwrp_ev24=[filenames.shareddir,'shared_best_transformations_06movandmmp_ev2and4.mat'];
filenames.shared_best_combinations_c13_ewc06movwrpmovmmpwrp_ev24=[filenames.shareddir,'shared_best_combinations_06movandmmp_ev2and4.mat'];
filenames.shared_best_transformations_c13_ewc06movwrp_ev2renorm=[filenames.shareddir,'shared_best_transformations_06mov_ev2_renorm.mat'];
filenames.shared_best_combinations_c13_ewc06movwrp_ev2renorm=[filenames.shareddir,'shared_best_combinations_06mov_ev2_renorm.mat'];
filenames.shared_best_transformations_c13_ewcmovand06movwrp_ev2renorm=[filenames.shareddir,'shared_best_transformations_movand06mov_ev2.mat'];
filenames.shared_best_combinations_c13_ewcmovand06movwrp_ev2renorm=[filenames.shareddir,'shared_best_combinations_movand06mov_ev2.mat'];
%%%%%%



