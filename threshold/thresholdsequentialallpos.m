function [] = thresholdsequentialallpos(experimentDir, posArray, typedots, ...
    sequentialkeyDir, varargin)
% wrapper function to manual threshold the first position and apply the
% same threshold to all other positions and output the points
%
% date: 2/28/20


    %% Set up optional Parameters for z-slice index
    numvarargs = length(varargin);
    argsLimit = 3;
    if numvarargs > argsLimit
        error('src:thresholdsequentialallpos:TooManyInputs', ...
            'requires at most 3 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {'sequential-images-pos', true, false};
    optargs(1:numvarargs) = varargin;
    [imStartName, filtersigma, despeckle] = optargs{:};

    
    %% variables
    firstPosition = true;
    threshold = [];
    
    
    %% get the gene key 
    sequentialPath = getfile(sequentialkeyDir, '.', 'match');
    sequentialkey = readsequential(sequentialPath, 'header');
    
    
    for position = posArray
        %% load image
        imStartPath = fullfile(experimentDir, 'processedimages', ['pos' num2str(position)]);
        imPath = getfile(imStartPath, imStartName, 'match');
        load(imPath, 'I');


        %% switch channel 2 and 3 (488 and Cy3b)
        Iorg = switch23(I); % only get sequential hybs from 18 to 29
        clearvars I


        %% manually threshold or use the same threshold
        if firstPosition
            [threshold, points, intensity, pointsSuperRes, sigma] = ...
                thresholdmanualbypos(experimentDir, position, typedots, ...
                Iorg, filtersigma, despeckle);
            saveDataName = ['threshold-data-pos' num2str(position)];
            saveThresholdDataDir = fullfile(experimentDir, 'threshold-data');
            mkdir(saveThresholdDataDir);
            saveDataPath = fullfile(saveThresholdDataDir, saveDataName);
            save(saveDataPath, 'threshold', 'points', 'intensity', 'pointsSuperRes',...
                'sigma', 'position');
            firstPosition = false;
        else % use the same threshold
            [points, intensity, pointsSuperRes, sigma] = ...
                pointsfromthreshold(experimentDir, position, typedots, Iorg, ...
                threshold, filtersigma, despeckle);
        end



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


end