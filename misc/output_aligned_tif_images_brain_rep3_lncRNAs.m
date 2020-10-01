% I in the Workspace.
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'G:\Yodai\DNA+\2019-09-07-brain-rep3-2-RNAFISH\lncRNA_images\processedimages';
folderArray = 0:1;

for pos = 0:5
    saveDir = fullfile(experimentDir, ['pos' num2str(pos)]);
    listing = dir([saveDir '\imagesHybDapi*.mat']);
    load(fullfile(listing(1).folder,listing(1).name));
    for hyb = 1:length(folderArray)
        savePath = fullfile(saveDir,['aligned-Pos' num2str(pos) 'hyb' num2str(hyb) '.tif']);
        savechannelsimagej(hybIms(hyb,:), savePath);
    end
end