function [histLog, histRaw, medianLog, medianRaw] = thresholdinfo(rawImage, segMask)
% get the threshold info to predict the threshold for the images

    % get the log image
    %h = fspecial3('log',7,1);
    %logImage = imfilter(rawImage, -20*h, 'replicate');
    dir = 'G:\HuBMAP\120619 Spleen 105 antcentpost 45 genes';
    uniqueString = 'despeckle-2304';
    logImage = despeckleall(rawImage, dir, uniqueString);
    
    % get all pixels from the raw and log image using seg mask
    %rawPixels = rawImage(segMask);
    logPixels = logImage(segMask);
    medianLog = median(logPixels, 'all');
    %medianRaw = median(rawPixels, 'all');
    
end