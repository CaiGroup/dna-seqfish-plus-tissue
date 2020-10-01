function [] = thresholdsequential(experimentDir, position, typedots, ...
    sequentialkeyDir, varargin)
% wrapper function to manual threshold only one position
%
% date: 2/27/20

    %% Set up optional Parameters for z-slice index
    numvarargs = length(varargin);
    argsLimit = 1;
    if numvarargs > argsLimit
        error('src:thresholdsequential:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {'sequential-images-pos'};
    optargs(1:numvarargs) = varargin;
    [imStartName] = optargs{:};

    %% variables
    filtersigma = false;
    

    %% load image
    imStartPath = fullfile(experimentDir, 'processedimages', ['pos' num2str(position)]);
    imPath = getfile(imStartPath, imStartName, 'match');
    load(imPath, 'I');

    
    %% switch channel 2 and 3 (488 and Cy3b)
    Iorg = switch23(I); % only get sequential hybs from 18 to 29
    clearvars I
    
    
    %% manually threshold
    [threshold, points, intensity, pointsSuperRes, sigma] = ...
        thresholdmanualbypos(experimentDir, position, typedots, Iorg, filtersigma);
    saveDataName = ['threshold-data-pos' num2str(position)];
    saveThresholdDataDir = fullfile(experimentDir, 'threshold-data');
    mkdir(saveThresholdDataDir);
    saveDataPath = fullfile(saveThresholdDataDir, saveDataName);
    save(saveDataPath, 'threshold', 'points', 'intensity', 'pointsSuperRes',...
        'sigma', 'position');

    
    %% get the gene key 
    sequentialPath = getfile(sequentialkeyDir, '.', 'match');
    sequentialkey = readsequential(sequentialPath, 'header');

    
    %% stack the points into a single column
    pointsStack = stackrows(pointsSuperRes);
    intStack = stackrows(intensity);
    sigmaStack = stackrows(sigma);

    
    %% assign genes to table and group table
    T = seqpoints2table(pointsStack, sequentialkey, intStack, sigmaStack);

    
    %% print the table
    saveName = ['sequential-data-pos' num2str(position) '.csv'];
    saveDir = fullfile(experimentDir, 'sequential-data');
    mkdir(saveDir);
    savePath = fullfile(saveDir, saveName);
    writetable(T, savePath);


end