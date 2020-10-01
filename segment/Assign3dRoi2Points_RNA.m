function [GeneCounts, cells, Stats] = Assign3dRoi2Points_RNA(cellnum,points,savePathCh,zoffset)

hyb_num = size(points,1);
ch_num = 2; %fixed value
GeneCounts = [];
cells = [];
Stats = [];
stats = regionprops3(cellnum);
Stats(:,4) = stats.Volume;
Stats(:,1) = stats.Centroid(:,1);
Stats(:,2) = stats.Centroid(:,2);
Stats(:,3) = stats.Centroid(:,3);
Stats(1,:) = [];% 1 is outside cell ROI, Column 1,2,3,4 represent x,y,z centroid and volume (voxel)

for hyb = 1:hyb_num
    for ch = 1:ch_num
        points_hybch = points{hyb,1}(ch).channels(:,:);
        %points_hybch(:,3) = points_hybch(:,3)*3 - 11; % this is to correct the z misalignment with undersampling, Pos0 manual offset
        points_hybch(:,3) = points_hybch(:,3)*3 - 2 -3*zoffset; % this is to correct the z misalignment with undersampling
        indices = find(points_hybch(:,1)>size(cellnum,1)|points_hybch(:,1)<1|points_hybch(:,2)>size(cellnum,2)|points_hybch(:,2)<1|points_hybch(:,3)>size(cellnum,3)|points_hybch(:,3)<1);  
        points_hybch(indices,:) = [];
        linInd = sub2ind(size(cellnum),points_hybch(:,2),points_hybch(:,1),points_hybch(:,3));
        cells_hybch = cellnum(linInd); %returned the cell ID, starting from 2
        [N,~] = histcounts(cells_hybch,[0:max(max(max(cellnum)))+1]);
        GeneCounts_hybch = N(3:end);
        cells{hyb,ch}(:,1:3) = points_hybch;
        cells{hyb,ch}(:,4) = cells_hybch;
        GeneCounts{hyb,ch}(:,1) = GeneCounts_hybch;
    end
end

%savePathCh = fullfile('F:\Yodai\DNA+\2019-09-04-brain-rep2-2-RNAFISH', 'brain-rep2-2-RNAFISHdecoded-Pos0-fixed-20191026.mat');
save(savePathCh, 'GeneCounts', 'cells', 'Stats');

