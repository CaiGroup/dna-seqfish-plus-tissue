
function [T, T_avg] = getoneifbacksub(imDir, segDir, binSize, chaTform)
% applies back subtract to images and gets the if for one specified folder directory and returns cell of
% channels, and cell array of cells for each channel
%
% date: 2/22/2020

    % get the ref dapi images
    s = split(imDir, '\');
    s1 = join(s(1:end-1), '\');
    refDir = fullfile(s1{1}, 'HybCycle_0'); % assume HybCycle_0 is the reference
    [Iref, numChAll, numZ] = getim(refDir);
    dapiRef = Iref(:, numChAll);

    % get the images
    [I, numChAll, numZ] = getim(imDir);
    numCh = numChAll - 1; % exclude DAPI
    dapiI = I(:, numChAll);
    
    
    % back subtract
    uniqueString = 'imageTempProcess-3535fsfsg';
    for f = 1:size(I,1)
        for ch = 1:numCh
            I{f,ch} = imagejbackgroundsubtraction(I{f,ch}, uniqueString,...
                s1{1});
        end
    end
    
    % get and apply tform
    tform = grabcelltform(dapiI, dapiRef); 
    I2 = applyalltform(I, tform);
    I2 = applyallchatform(I2(:,1:2), chaTform);
    
    % get the amount of images in the directory
    numIm = size(I,1);
    
    % get the segmentation
    L = cell(numIm, 1);
    for i = 1:numIm
        segPath = getfile(fullfile(segDir, ['pos' num2str(i-1)]), '.');
        L{i} = getlabel(segPath, numZ);
    end
    
    
    % get the if data
    T = cell(1, numCh);
    T_avg = cell(1, numCh);
    for c = 1:numCh
        for i = 1:numIm
            S = getif(I2{i,c}, L{i}, binSize);
            [T{i,c}, T_avg{i,c}] = if2table(S, binSize);
        end
    end
    
    % to print
    % expName = 'final_fiducial_markers';
    %printifbyfov(saveDir, T, T_avg, expName);

end

