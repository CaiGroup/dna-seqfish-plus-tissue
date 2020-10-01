function [threshold, points, intensity, sigma] = thresholdmanwrapper(hybcycleArray, ...
    chArray, numChannels, numTotalChannels, imageDir, position, typedots, ...
    superres, filtersigma, despeckle, lowmemory, tophatfilter, varargin)
% wrapper to manual threshold based on options
%
% outputs points, intensity, and threshold from hybcycle x channel to a
% single column
%
% Option Variables
% I: a cell array of images (hybcycle x channel, ex. 16 x 3 cell array)
%
% date: June 19, 2020

    %% Set up optional Parameters
    argsLimit = 2;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:processcyclewrapper:TooManyInputs', ...
            'requires at most 2 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {[], []};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [I, rawImages] = optargs{:};

    
    %% variables
    % boolean to check images
    emptyImage = false;
    if isempty(I)
        emptyImage = true;
    end
    thresholdTemp = ones(length(hybcycleArray), numChannels) * 1000000;
    pointsTemp = cell(length(hybcycleArray), numChannels);
    intensityTemp = cell(length(hybcycleArray), numChannels);
    if superres
        pointsSuperRes = cell(length(hybcycleArray), numChannels);
        sigmaTemp = cell(length(hybcycleArray), numChannels);
    end
    
    % individually process each image, and manually threshold
    if lowmemory || emptyImage
        % manual threshold each channel
        for h = hybcycleArray
            imagePath = fullfile(imageDir, ['HybCycle_' num2str(h)], ['MMStack_Pos' num2str(position) '.ome.tif']);
            [I, sizeC, sizeZ, pxSizeX, pxSizeY] = grabimseries(imagePath, position, chArray, numTotalChannels);
            if superres
                [thresholdTemp(h+1,:), pointsTemp(h+1,:), intensityTemp(h+1,:), ...
                    pointsSuperRes(h+1,:), sigmaTemp(h+1,:)] = thresholdmanualbypos(imageDir, ...
                    position, typedots, I, filtersigma, despeckle, tophatfilter, h);
            else
                [thresholdTemp(h+1,:), pointsTemp(h+1,:), intensityTemp(h+1,:), ...
                    pointsSuperRes, ~] = thresholdmanualbypos(imageDir, position, ...
                    typedots, I, filtersigma, despeckle, tophatfilter, h);
            end
        end
    else
        % get images if empty
        if emptyImage
            
            % grab all images and process
            I = cell(length(hybcycleArray), numChannels);
            
            for h = hybcycleArray
                imagePath = fullfile(imageDir, ['HybCycle_' num2str(h)], ['MMStack_Pos' num2str(position) '.ome.tif']);
                [I(h+1,:), sizeC, sizeZ, pxSizeX, pxSizeY] = grabimseries(imagePath, position, chArray, numTotalChannels);
            end
        end
        
        
        % manual threshold
        if superres
            [thresholdTemp, pointsTemp, intensityTemp, pointsSuperRes, sigmaTemp] = ...
                thresholdmanualbypos(imageDir, position, typedots, I, filtersigma, despeckle, tophatfilter, [], rawImages);
        else
            [thresholdTemp, pointsTemp, intensityTemp, pointsSuperRes, ~] = ...
                thresholdmanualbypos(imageDir, position, typedots, I, filtersigma, despeckle, tophatfilter, [], rawImages);
        end
        
    end
    
    % sigma is null for no super resolution
    intensity = stackrows(intensityTemp);
    threshold = thresholdTemp;
    if superres
        points = stackrows(pointsSuperRes);
        sigma = stackrows(sigmaTemp);
    else
        points = stackrows(pointsTemp);
        sigma = [];
    end

end