zoffset_RNA = [3 1 0 4 3]; % manually checked.
for pos = 0:4
    
    %% Grab 3D ROI (nuclei only so far)
    path_seg = ['F:\Yodai\DNA+\2019-09-09-brain-rep2-2-DNAFISH\3d segmentation\Pos' num2str(pos)];
    savePathCh_seg = fullfile(path_seg, ['brain-rep2-2-Pos' num2str(pos) '-3dRoiNuc-cellnum-20191031.mat']);
    DAPI = [path_seg '\C2-aligned-Pos' num2str(pos) '_binned_DAPI_Probabilities2.h5'];
    lamin = [path_seg '\C1-aligned-Pos' num2str(pos) '_binned_conA_Probabilities.h5'];
    cellnum = SegmentNucleiBrain(DAPI,lamin,savePathCh_seg);
    
    %% Assigning decoded DNA points to 3D ROI (nuclei)
    path_dna = 'F:\Yodai\DNA+\2019-09-09-brain-rep2-2-DNAFISH\analysis\';
    % make sure only one file per Pos in the path
    listing_ch1 = dir([path_dna '2error-sqrt6-ch1\data-2019-09-09-brain-rep2-2-DNAFISH-Pos*.mat']);
    listing_ch2 = dir([path_dna '2error-sqrt6-ch2\data-2019-09-09-brain-rep2-2-DNAFISH-Pos*.mat']);
    for ch = 1:2
        savePathCh_dna = fullfile([path_dna 'DNA_3dRoiNuc'], ['brain-rep2-2-DNAFISHdecoded-ch' num2str(ch) '-Pos' num2str(pos) '-20191031.mat']);
        if ch == 1
            load([listing_ch1(pos+1).folder '\' listing_ch1(pos+1).name]);
        elseif ch == 2
            load([listing_ch2(pos+1).folder '\' listing_ch2(pos+1).name]);
        end
        [name_gene, cells, Stats] = Assign3dRoi2Points_DNA(cellnum,finalPosList, savePathCh_dna);
    end
    
    %% Assigning decoded RNA points to 3D ROI (nuclei)
    path_rna = 'F:\Yodai\DNA+\2019-09-04-brain-rep2-2-RNAFISH\analysis\';
    % make sure only one file per Pos in the path
    listing_rna = dir([path_rna 'points\points_brain_rep2_Pos*.mat']);
    load([listing_rna(pos+1).folder '\' listing_rna(pos+1).name]);
    savePathCh_rna = fullfile([path_rna '\RNA_3dRoiNuc'], ['brain-rep2-2-RNAFISHdecoded-Pos' num2str(pos) '-20191031.mat']);
    [GeneCounts, cells, Stats] = Assign3dRoi2Points_RNA(cellnum,points,savePathCh_rna,zoffset_RNA(pos+1));
    
end
    
