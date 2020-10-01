function [name_gene, cells, Stats] = Assign3dRoi2Points_DNA(cellnum,finalPosList, savePathCh)

gene_num = size(finalPosList,1);
name_gene = [];
cells = [];
Stats = [];
stats = regionprops3(cellnum);
Stats(:,4) = stats.Volume;
Stats(:,1) = stats.Centroid(:,1);
Stats(:,2) = stats.Centroid(:,2);
Stats(:,3) = stats.Centroid(:,3);
Stats(1,:) = [];% 1 is outside cell ROI, Column 1,2,3,4 represent x,y,z centroid and volume (voxel)

for gene = 1:gene_num
    name_gene{gene,1} = finalPosList{gene,1};
    points_gene_original = finalPosList{gene,2};
    if ~isempty(points_gene_original)
        points_gene = round(finalPosList{gene,2});
        indices = find(points_gene(:,1)>size(cellnum,1)|points_gene(:,1)<1|points_gene(:,2)>size(cellnum,2)|points_gene(:,2)<1|points_gene(:,3)>size(cellnum,3)|points_gene(:,3)<1);
        points_gene_original(indices,:) = [];
        points_gene(indices,:) = [];
        %disp(gene)
        linInd = sub2ind(size(cellnum),points_gene(:,2),points_gene(:,1),points_gene(:,3));
        cells_gene = cellnum(linInd); %returned the cell ID, starting from 2
        cells{gene,1}(:,1:3) = points_gene_original;
    end
    cells{gene,1}(:,4) = cells_gene;
end

%savePathCh = fullfile('F:\Yodai\DNA+\2019-09-09-brain-rep2-2-DNAFISH', 'brain-rep2-2-DNAFISHdecoded-ch2-Pos1-20191026.mat');
save(savePathCh, 'name_gene', 'cells', 'Stats');

