%% variables
% need to create the folder for savePathCh_rna manually. should be automated.

zoffset_RNA = [0 0 0 0 0 0]; % manually added if necessary.
date = 20191207;
path_seg = 'F:\Yodai\DNA+\2019-09-14-brain-rep3-2-DNA-FISH\3d nuclear segmentation';
path_dna = 'F:\Yodai\DNA+\2019-09-14-brain-rep3-2-DNA-FISH\analysis\';
path_rna = 'F:\Yodai\DNA+\2019-09-07-brain-rep3-2-RNAFISH\analysis\';
exp = 'brain-rep3-2';
exp_dna = '2019-09-14-brain-rep3-2-DNA-FISH';
exp_rna = '2019-09-07-brain-rep3-2-RNAFISH';

for pos = 0:5
    
    %% Grab 3D ROI (nuclei only so far)
    
    savePathCh_seg = fullfile([path_seg '\Pos' num2str(pos)], [exp '-Pos' num2str(pos) '-3dRoiNuc-cellnum-' num2str(date) '.mat']);
    DAPI = [path_seg '\Pos' num2str(pos) '\C3-alignedcorrected-Pos' num2str(pos) '_binned_DAPI_Probabilities4.h5'];
    lamin = [path_seg '\Pos' num2str(pos) '\C1-alignedcorrected-Pos' num2str(pos) '_binned_conA_Probabilities3.h5'];
    cellnum = SegmentNucleiBrain(DAPI,lamin,savePathCh_seg);
    
    %% save ROI image with conA and DAPI.
    savesegtif(path_seg, pos, cellnum, date);
    
    %% Filtering the ROIs in the conA empty z slices due to the ambiguity.
    savePathCh_seg2 = fullfile([path_seg '\Pos' num2str(pos)], [exp '-Pos' num2str(pos) '-3dRoiNuc-cellnumfiltered-' num2str(date) '.mat']);
    imagePath = [path_seg '\Pos' num2str(pos) '\alignedcorrected-Pos' num2str(pos) '.tif' ];
    [SegImage, sizeC, sizeZ, physicalsizeX, physicalsizeY] = grabimseries(imagePath, pos);
    
    % find z slices with no image due to z shift with the final alignment conA image.
    conAzmax = max(max(SegImage{1,1})); 
    emptyZ = find(conAzmax == 0);
    if ~isempty(emptyZ)
        for z = 1:length(emptyZ)
            cellnum(:,:,emptyZ(z)) = 0;
        end
    end
    save(savePathCh_seg2, 'cellnum');
    savesegtif(path_seg, pos, cellnum, date, 'filtered');
    
    %% Assigning decoded DNA points to 3D ROI (nuclei)
    
    % make sure only one file per Pos in the path
    %listing_ch1 = dir([path_dna '2error-sqrt6-ch1\data-2019-09-09-brain-rep2-2-DNAFISH-Pos*.mat']);
    %listing_ch2 = dir([path_dna '2error-sqrt6-ch2\data-2019-09-09-brain-rep2-2-DNAFISH-Pos*.mat']);
    %for ch = 1:2
    %    savePathCh_dna = fullfile([path_dna 'DNA_3dRoiNuc-' num2str(date)], ['brain-rep2-2-DNAFISHdecoded-ch' num2str(ch) '-Pos' num2str(pos) '-' num2str(date) '.mat']);
    %    if ch == 1
    %        load([listing_ch1(pos+1).folder '\' listing_ch1(pos+1).name]);
    %    elseif ch == 2
    %        load([listing_ch2(pos+1).folder '\' listing_ch2(pos+1).name]);
    %    end
    %    [name_gene, cells, Stats] = Assign3dRoi2Points_DNA(cellnum,finalPosList, savePathCh_dna);
    %end
    
    %% Assigning decoded RNA points to 3D ROI (nuclei)
    
    % make sure only one file per Pos in the path
    listing_rna = dir([path_rna 'sqrt6\pointsData-' exp_rna '-Pos*.mat']);
    load([listing_rna(pos+1).folder '\' listing_rna(pos+1).name]);
    savePathCh_rna = fullfile([path_rna '\RNA_3dRoiNuc-' num2str(date)], [exp '-RNAFISHdecoded-Pos' num2str(pos) '-' num2str(date) '.mat']);
    [GeneCounts, cells, Stats] = Assign3dRoi2Points_RNA(cellnum,points,savePathCh_rna,zoffset_RNA(pos+1));
    
end
    
