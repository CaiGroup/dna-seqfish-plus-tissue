function [pointsSuperRes, points, intensity, threshold, sigma] = ...
    manualthresholdall(images, filtersigma, options, varargin)
% manually thresholds all folders and channels 
%
% - uses radial center to super resolve point and filters by sigma value
%
% date: 2/27/2020

    %% Set up optional Parameters
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:manualthresholdall:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {[]};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [rawImages] = optargs{:};

    %% declare variables
    HIGH_THRESHOLD_VALUE = 999999;
    numHybCycles = size(images, 1);
    folderArray = 1:numHybCycles;
    numCh = size(images, 2);
    points = cell(numHybCycles, numCh);
    sigma = cell(numHybCycles, numCh);
    pointsSuperRes = cell(numHybCycles, numCh);
    intensity = cell(numHybCycles, numCh);
    threshold = ones(numHybCycles, numCh) .* HIGH_THRESHOLD_VALUE;
    if options.savefigs
        savePointDir = options.pathsavedots;
    else
        savePointDir = [];
    end
    
    if ~ischar(options.threshold)
        thresholdRef = options.threshold;
    else
        thresholdRef = [];
    end

    for c = 1:numCh
        fIter = 1;
        for f = folderArray
            fprintf('folder %.0f channel %0.f, ', f, c);
            if ~isfield(options, 'channelLabel') 
                options.channelLabel = c;
            end
            if ~isfield(options, 'folderLabel')
                options.folderLabel = f;
            end
            if ~isempty(thresholdRef)
                options.threshold = thresholdRef(f,c);
                options.pathsavedots = fullfile(savePointDir, ['pos' num2str(options.position) '-hyb' num2str(f) '.fig']);
            end
            
            if ~isempty(rawImages)
                [threshold(fIter, c), points{fIter,c}, intensity{fIter,c}] = getthreshold(images{fIter, c}, options, rawImages{fIter, c});
            else
                [threshold(fIter, c), points{fIter,c}, intensity{fIter,c}] = getthreshold(images{fIter, c}, options);
            end
            if ~isempty(points{fIter,c})
                % filter using sigma
                if filtersigma
                    removeidx = [];
                    [pointsSuperRes{fIter,c}, sigmaTemp] = getradialcenter(points{fIter,c}, images{fIter,c});
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
            end

            fIter = fIter + 1;
        end
        fprintf('\n');
    end