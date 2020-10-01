function finalpointscsv = finalpoints_csvformatting(experimentDir,finalpoints,position,cellID,chID)

% import this before running this function.
%load('E:\Yodai\DNAFISH+\2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH - Swapped\analysis\2020-01-26-pipeline-full-decoding-param-change\decoding_variables\decoding-variables-pos2-2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH.mat')

% add other path (folder) too, to use segmentpoints2cells.m

finalpointscsv = [];
barcode_round = 5;
pseudo_color = 16;
fov = position; % should be passed from the imported .mat file.
segment = 'roi';
segmentPath = fullfile(experimentDir,'segmentation', ['Pos' num2str(fov)],'RoiSet.zip');

[pointsxcell, numCells, pointsPerCell] = segmentpoints2cells(segmentPath, finalpoints{chID}, segment);

for ch = chID
    for bar = 1:barcode_round
        for pc = 1:pseudo_color
            for dot = 1:size(pointsxcell{cellID,1}{1,bar}(pc).channels,1)
                finalpointscsv = [finalpointscsv;fov,cellID,ch,bar,pc,pointsxcell{cellID,1}{1,bar}(pc).channels(dot,1),...
                    pointsxcell{cellID,1}{1,bar}(pc).channels(dot,2),pointsxcell{cellID,1}{1,bar}(pc).channels(dot,3)];
            end
        end
    end
end