% main script to run DNA seqFISH+ analysis.
% ch1-2 and ch3 analysis are integrated.
% edit by Yodai Takei
% Last updated on 02/21/20.

%% Experiment dependent Variables
addpath('C:\Users\Long Cai - 1\Desktop\Fiji.app\scripts\', '-end');
experimentDir = 'G:\Yodai\DNA+\2020-01-25-E14L22Rik24hr-RNAFISH-IF\organized RNA folder';
experimentName = '2020-01-25-E14L22Rik24hr-RNAFISH';
experimentLabel = '2020-02-22-seqential-analysis-logradial3d';
posArray = 0:7;
folderArray = 0:3;
numCh = 2;
chArray = 1:numCh;
fiducialhybArray = 4:5; %starting from 1, should be last 2 images.
% import chaTform
load(fullfile(experimentDir,'analysis',experimentLabel,'points','variables','refpoints-chromaticaberrations-initial-final-2020-02-22.mat'),'chaTformFinal');

for position = posArray
    
    % import chromatic aberration corrected points
    listing = dir(fullfile(experimentDir,'analysis', experimentLabel,'points','variables',...
        ['data-pos' num2str(position) '-points-chcorr-*.mat']));
    load([listing(1).folder '\' listing(1).name],'pointsch');
    
    % import preprocessed data, and get only for the fiducial hybs.
    listing = dir([experimentDir '\processedimages\pos' num2str(position) '\preProcessedData*.mat']);
    load([listing(1).folder '\' listing(1).name],'I');
    I = I(fiducialhybArray,:);
    
    % analyze channel by channel.
    for ch = 1:numCh
        
        % reformat the points channel by channel.
        points = cell(length(folderArray),1);
        for hyb = 1:length(folderArray)
            points{hyb,1}.channels = pointsch{hyb,1}(ch).channels;
            points{hyb,1}.intensity = pointsch{hyb,1}(ch).intensity;
        end
        
        % reformat I and correct chromatic aberration.
        for f = 1:size(I,1)
            I{f,ch} = imwarp(I{f,ch}, chaTformFinal{ch}, 'OutputView', imref3d(size(I{f,ch})));
        end
        
        points_paints = ChromPaintIntensities_perpoints_flex(experimentDir, experimentName,...
            experimentLabel, points, I(:,ch), position, ch);
        
    end
    
end