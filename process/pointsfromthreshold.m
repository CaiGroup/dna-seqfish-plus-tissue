function [points, intensity, pointsSuperRes, sigma] = ...
    pointsfromthreshold(experimentDir, position, typedots, images, threshold, varargin)
% gets the points using the provided images and threshold - 
%
%
% date: 2/25/2020

    %% Set up optional Parameters
    numvarargs = length(varargin);
    argsLimit = 3;

    if numvarargs > argsLimit
        error('myfuns:getpoints:TooManyInputs', ...
            'requires at most 3 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {true, false, []}; 
    optargs(1:numvarargs) = varargin;
    % Place optional args in memorable variable names
    [filtersigma, despeckleFlag, saveFigDir]  = optargs{:};

    
    %% start function
    debug = 1;
    if isempty(saveFigDir)
        saveFigDir = fullfile(experimentDir, 'dotcheck');
    end
    mkdir(saveFigDir);
    
    %% variables
    numHybCycles = size(images, 1);
    folderArray = 1:numHybCycles;
    numCh = size(images, 2);
    points = cell(numHybCycles, numCh);
    sigma = cell(numHybCycles, numCh);
    pointsSuperRes = cell(numHybCycles, numCh);
    intensity = cell(numHybCycles, numCh);

    %% despeckle
    if despeckleFlag
        idx = 1;
        for f = folderArray
            fprintf('Despeckle HybCycle %.0f...\n', f);
            uniqueString = 'imageTemp-2903754despeckle';
            for c = 1:numCh
                images{idx, c} = despeckle(images{idx,c}, uniqueString, experimentDir);
            end
            idx = idx + 1;
        end
    end

    fprintf('Choose Threshold:\n');

    for c = 1:numCh
        fIter = 1;
        for f = folderArray
            fprintf('folder %.0f channel %0.f, ', f, c);
            saveFigPath = fullfile(saveFigDir, ['dot-check-pos' num2str(position) 'f' num2str(f) '-ch' num2str(c) '.fig']);
            [points{fIter,c}, intensity{fIter,c}, ~, ~] = detectdotsv2(images{fIter,c}, threshold(fIter,c), typedots, debug, saveFigPath);
            %[threshold(fIter, c), points{fIter,c}, intensity{fIter,c}] = getthreshold(images{fIter, c}, options);
                    % filter using sigma
            if filtersigma && ~isempty(points{fIter,c})
                removeidx = [];
                [pointsSuperRes{fIter,c}, sigmaTemp] = getradialcenter(points{fIter,c},images{fIter,c});
                sigma{fIter,c} = sigmaTemp';
                intThreshold = 100;
                for i = 1:size(pointsSuperRes{fIter,c},1)
                    sigcheck = sigma{fIter,c}(i);
                    if sigcheck < 0.5 || sigcheck > 1.2 || intensity{fIter,c}(i) < intThreshold 
                        removeidx = cat(1, removeidx, i);
                    end
                end
                pointsSuperRes{fIter,c}(removeidx, :) = [];
                intensity{fIter,c}(removeidx, :) = [];
                sigma{fIter,c}(removeidx, :) = [];
            else
                sigma = [];
                pointsSuperRes = [];
            end

            fIter = fIter + 1;
        end
        fprintf('\n');
    end