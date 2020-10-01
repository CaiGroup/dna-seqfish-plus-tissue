% I in the Workspace.
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'G:\Yodai\DNA+\2019-09-04-brain-rep2-2-RNAFISH';
saveFolderName = '2019-09-04-brain-rep2-2-RNAFISH-preprocessed-tif';
folderArray = 0:36;

for pos = 0
    for hyb = 1:length(folderArray)
        saveDir = fullfile(experimentDir, saveFolderName);
        if exist(saveDir, 'dir') ~= 7
            mkdir(saveDir);
        end
        savePath = fullfile(saveDir,['aligned-Pos' num2str(pos) 'hyb' num2str(hyb) '.tif']);
        savechannelsimagej(I(hyb,:), savePath);
    end
end