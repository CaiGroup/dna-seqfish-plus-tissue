function [] = getallimmunoI(experimentDir, immunoHybArray, posArray, varargin)
% retrieves all the sequential images from previously saved processed
% images I and saves as sequential-images for each position

    %% Set up optional Parameters for z-slice index
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:getallsequentialI:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    optargs = {'imagesHybDapi'}; % options 'select' or 'match'
    optargs(1:numvarargs) = varargin;
    [imStartName] = optargs{:};

    % save images
    saveImDir = fullfile(experimentDir,'immuno-images');
    mkdir(saveImDir);

    for position = posArray
        % load raw images - change to ption
        saveDir = fullfile(experimentDir, 'processedimages', ['pos' num2str(position)]);
        imPath = getfile(saveDir, imStartName, 'match');
        
        load(imPath, 'hybIms');
        
        % only get the images
        I = hybIms(immunoHybArray,:);
        clearvars hybIms

        

        saveName = ['immuno-images-pos' num2str(position)];
        savePath = fullfile(saveImDir, saveName);
        save(savePath, 'I', '-v7.3');
    end
end