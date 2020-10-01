function [points, intensity] = thresholdgetspots(image, threshold, savedir)


    % variables
    numCols = size(image, 2);
    numRows = size(image, 1);
    pointsTemp = cell(numRows, numCols);
    intensityTemp = cell(numRows, numCols);
    debug = false;
    
    % get points
    typedots = 'log';
    for c = 1:numCols
        for r = 1:numRows
            if ~isempty(savedir)
                savefig = fullfile(savedir, ['spots_c' num2str(c) '-r' num2str(r) '.fig']);
                debug = true;
            end
            [pointsTemp{r,c}, intensityTemp{r,c}, ~, ~] = detectdotsv2(image{r,c}, ...
                threshold(r,c), typedots, debug, savefig);
        end
    end
    

    % sigma is null for no super resolution
    intensity = stackrows(intensityTemp);
    points = stackrows(pointsTemp);
    
end

    
    