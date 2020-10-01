function dotlocationscsv = dotlocations_csvformatting(dotlocations,fov,cellID,chID)

% loaded this before running the function
%load('E:\Yodai\DNAFISH+\2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH - Swapped\analysis\2020-01-26-pipeline-full-decoding-param-change\2error-sqrt3-ch1\data-2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH-Pos2-2error-sqrt3-ch1-2020-01-26.mat')


dotlocationscsv = [];
num_cell = size(dotlocations,1);
num_barcode = size(dotlocations{1,1},1);

for cell = cellID
    for bar = 1:num_barcode
        if dotlocations{cell,1}{bar,1} ~= 0
            for dot = 1:size(dotlocations{cell,1}{bar,1},1)
                %[fov,cellID,chID,barcoding
                %round,pseudo-color,x,y,z,barcodeID];
                dotlocationscsv = [dotlocationscsv;fov,cell,chID,...
                    dotlocations{cell,1}{bar,3}(dot),dotlocations{cell,1}{bar,2}(dot),...
                    dotlocations{cell,1}{bar,1}(dot,1),dotlocations{cell,1}{bar,1}(dot,2),...
                    dotlocations{cell,1}{bar,1}(dot,3),bar];
            end
        end
    end

end