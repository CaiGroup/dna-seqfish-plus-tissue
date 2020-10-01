% matching the hyb0 (hyb80 repeat) and hyb80, using the same matching
% algorithm as the actual decoding anlysis.
% make sure to use matchpoints.m in the process_with_beads folder.
% Last updated on 02/22/20.

%% Experiment dependent Variables
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'E:\Yodai\DNAFISH+\2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH - Swapped';
experimentName = '2019-07-21-E14-DNA-seqFISH+rep2-2-DNAFISH';
experimentLabel = '2020-02-14-seq-control';
posArray = 0:4;
folderNames = ["HybCycle_0","HybCycle_initial_hyb80readouts","HybCycle_79","HybCycle_80","HybCycle_81","HybCycle_82",...
               "HybCycle_83","initial_fiducial_markers","final_fiducial_markers"];
folderArray = 0:length(folderNames)-1;
numCh = 2;
chArray = 1:numCh;
fiducialhybArray = length(folderArray)-1:length(folderArray); %starting from 1, should be last 2 images.
saveDir= fullfile(experimentDir, 'analysis',  experimentLabel, 'variables');
radius = 3;

for position = posArray
    
    savePath = fullfile(saveDir, ['outputVariables-pos' num2str(position) '-' experimentLabel '.mat']);
    load(savePath, 'pointsch');
    
    % analyze channel by channel.
    for ch = 1:numCh
        
        pointsRef = pointsch{ch,1}{1,1}(2).channels; % hyb2 is initial_hyb80readouts
        pointsMatch = pointsch{ch,1}{1,1}(3).channels; % hyb3 is HybCycle_79
        intref = pointsch{ch,1}{1,1}(2).intensity; 
        intch = pointsch{ch,1}{1,1}(3).intensity; 
        
        [matchRef, mismatchRef, matchPoints, mismatchPoints] = matchpoints(pointsRef, pointsMatch,...
            radius, intref, intch,[],[]);
        
        saveDirPath = fullfile(experimentDir, 'analysis', experimentLabel, 'hyb0 hyb80 analysis');
        if exist(saveDirPath, 'dir') ~= 7
            mkdir(saveDirPath);
        end

        savePath = fullfile(saveDirPath, ['matchRef-ch' num2str(ch) '-pos' num2str(position) '-' experimentName '.mat']);
        save(savePath, 'matchRef', 'mismatchRef', 'matchPoints', 'mismatchPoints');
        
    end
    
end