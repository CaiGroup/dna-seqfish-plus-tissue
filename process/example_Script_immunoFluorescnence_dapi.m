%example script dapi immunofluorescences

addpath('C:\Users\Long Cai - 2\Desktop\Fiji.app\scripts\', '-end');
addpath('C:\github\streamline-seqFISH\src\AlignImages\bfmatlab\', '-end');
addpath('C:\github\streamline-seqFISH\src\preprocessing', '-end');
addpath('C:\github\streamline-seqFISH\src\preprocessing\bfmatlab\', '-end');

%load('imagesHybDapi-pos1-ImmunoFluorescence-2019-07-25-E14-DNA-seqFISH+rep2-2-DNAFISH-plate2-2019-10-29.mat', 'dapiIms')
imDir = 'I:\2019-07-25-E14-DNA-seqFISH+rep2-2-DNAFISH-plate2\processedimages\pos2';
imPath = fullfile(imDir, 'imagesHybDapi-pos2-ImmunoFluorescence-2019-07-25-E14-DNA-seqFISH+rep2-2-DNAFISH-plate2-2019-10-31.mat');
load(imPath, 'dapiIms');


experimentName = 'ImmunoFluorescence-2019-07-25-E14-DNA-seqFISH+rep2-2-DNAFISH-plate2';
experimentDir = 'I:\2019-07-25-E14-DNA-seqFISH+rep2-2-DNAFISH-plate2';
position = 2;
chArray = 1;
folderArray = 0:19; % folder 20 is a repeat of the first hyb
segoption = '2d';
avgintpercelldapi(experimentDir, experimentName, dapiIms, position, folderArray, chArray, segoption);
