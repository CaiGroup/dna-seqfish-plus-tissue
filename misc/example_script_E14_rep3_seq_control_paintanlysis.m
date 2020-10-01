% main script to run DNA seqFISH+ analysis.
% ch1-2 and ch3 analysis are integrated.
% edit by Yodai Takei
% Last updated on 02/21/20.

%% Experiment dependent Variables
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'F:\Yodai\DNA+\2019-07-29-E14-DNA-seqFISH+rep3-1-DNAFISH';
experimentName = '2019-07-29-E14-DNA-seqFISH+rep3-1-DNAFISH';
experimentLabel = '2020-02-17-seq-control';
posArray = 0:5;
folderNames = ["HybCycle_0","initial_hyb80readouts","HybCycle_79","HybCycle_80","HybCycle_81","HybCycle_82",...
               "HybCycle_83","initial_fiducial_markers","final_fiducial_markers"];
folderArray = 0:length(folderNames)-1;
numCh = 3;
chArray = 1:numCh;
fiducialhybArray = length(folderArray)-1:length(folderArray); %starting from 1, should be last 2 images.
saveDir= fullfile(experimentDir, 'analysis',  experimentLabel, 'variables');
saveDirPath = fullfile(experimentDir, 'analysis', experimentLabel, 'processedImages');

for position = posArray
    
    savePath = fullfile(saveDir, ['outputVariables-pos' num2str(position) '-' experimentLabel '.mat']);
    load(savePath, 'pointsch');
    
    saveImName = ['alignedcorr-processed-I-pos' num2str(position) '-' experimentName '.mat'];
    saveImPath = fullfile(saveDirPath, saveImName);
    load(saveImPath, 'I');
    I = I(fiducialhybArray,:);
    
    % analyze channel by channel.
    for ch = 1:numCh
        
        % reformat the points channel by channel. also remove fiducial hyb
        points = cell(length(folderArray)-2,1);
        for hyb = 1:length(folderArray)-2
            points{hyb,1}.channels = pointsch{ch,1}{1,1}(hyb).channels;
            points{hyb,1}.intensity = pointsch{ch,1}{1,1}(hyb).intensity;
        end
        
        points_paints = ChromPaintIntensities_perpoints_flex(experimentDir, experimentName,...
            experimentLabel, points, I(:,ch), position, ch);
        
    end
    
end