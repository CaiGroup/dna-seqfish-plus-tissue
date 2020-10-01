function [T, pointsStack, intStack, sigmaStack, zSlice, threshold] = ...
    thresholdbarcodeallpos(experimentDir, position, typedots, threshold, ...
    numRefPoints, varargin)
% wrapper function to manual threshold the first position and apply the
% same threshold to all other positions and output the points
%
% returns cell array of positions
%
% date: 2/28/20


    %% Set up optional Parameters for z-slice index
    numvarargs = length(varargin);
    argsLimit = 3;
    if numvarargs > argsLimit
        error('src:thresholdbarcodeallpos:TooManyInputs', ...
            'requires at most 3 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {'barcode-images-pos', true, false, []};
    optargs(1:numvarargs) = varargin;
    [imStartName, filtersigma, despeckle, saveFigDir] = optargs{:};

    
    %% variables
    zSlice = [];
    if isempty(saveFigDir)
        saveFigDir = fullfile(experimentDir, 'dots-barcode-check');
        mkdir(saveFigDir);
    end
    
 
    %% load image
    imStartPath = fullfile(experimentDir, 'barcode-data');
    %imStartPath = fullfile(experimentDir, 'processedimages', ['pos' num2str(position)]);
    imStartName = [imStartName num2str(position) '.mat'];
    imPath = getfile(imStartPath, imStartName, 'match');
    load(imPath, 'I');


    %% switch channel 2 and 3 (488 and Cy3b)
    if isempty(zSlice)
        zSlice = size(I{1},3);
    end
    Iorg = switch23(I); % only get sequential hybs from 18 to 29
    clearvars I


    %% manually threshold or use the same threshold
    if isempty(threshold)
        [threshold, points, intensity, pointsSuperRes, sigma] = ...
            thresholdmanualbypos(experimentDir, position, typedots, ...
            Iorg, filtersigma, despeckle);
        saveDataName = ['threshold-barcode-data-pos' num2str(position)];
        saveThresholdDataDir = fullfile(experimentDir, 'threshold-data');
        mkdir(saveThresholdDataDir);
        saveDataPath = fullfile(saveThresholdDataDir, saveDataName);
        save(saveDataPath, 'threshold', 'points', 'intensity', 'pointsSuperRes',...
            'sigma', 'position');
        points = pointsSuperRes;
    else 
        % auto threshold based on the number of reference points
        [points, intensity, sigma, adjustedThreshold, numPointError] = ...
            autothresholdallbynumber(Iorg, numRefPoints, threshold, typedots, ...
            filtersigma, saveFigDir);
        % use the same threshold
        %[points, intensity, pointsSuperRes, sigma] = ...
        %    pointsfromthreshold(experimentDir, position, typedots, Iorg, ...
        %    threshold, filtersigma, despeckle, saveFigDir);
    end



    %% stack the points into a single column
    pointsStack = stackrows(points);
    intStack = stackrows(intensity);
    sigmaStack = stackrows(sigma);


    %% assign genes to table and group table
    T = barcodepoints2table(pointsStack, intStack, sigmaStack);


    %% print the table
    saveName = ['barcode-raw-points-pos' num2str(position) '.csv'];
    saveDir = fullfile(experimentDir, 'analysis', 'barcode-data');
    mkdir(saveDir);
    savePath = fullfile(saveDir, saveName);
    writetable(T, savePath);
    
    %% save threshold data
    if position ~= 0
        saveThresholdPath = fullfile(saveDir, ['threshold-data-pos' num2str(position) '.mat']);
        save(saveThresholdPath, 'threshold', 'adjustedThreshold', 'points', 'intensity',...
            'sigma', 'position', 'numPointError');
    end

end