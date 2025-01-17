% I in the Workspace.
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'F:\Yodai\DNA+\2019-11-01-E14-L22Rik-48hr-DNAFISHIF-plate2';
saveFolderName = 'E14-L22Rik-48hr-IF-aligned-images-without-preprocessing';
folderArray = 23;

for pos = 6
    for hyb = 24%1:length(folderArray)
        saveDir = fullfile(experimentDir, saveFolderName);
        if exist(saveDir, 'dir') ~= 7
            mkdir(saveDir);
        end
        savePath = fullfile(saveDir,['aligned-Pos' num2str(pos) 'hyb' num2str(hyb) '.tif']);
        savechannelsimagej(I(hyb,:), savePath);
    end
end