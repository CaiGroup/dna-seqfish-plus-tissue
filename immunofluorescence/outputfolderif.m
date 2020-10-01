function [T, T_avg] = outputfolderif(folderName, saveDir, experimentDir, binSize)
% output a folder of if
%
% assumes the folderName is in the experimentDir
%
% date: 2/27/2020

    segDir = fullfile(experimentDir, 'segmentation');
    imDir = fullfile(experimentDir, folderName);
    [T, T_avg] = getoneif(imDir, segDir, binSize, chaTform);
    % print the results for each position and channel
    printifbyfov(saveDir, T, T_avg, folderName);

end