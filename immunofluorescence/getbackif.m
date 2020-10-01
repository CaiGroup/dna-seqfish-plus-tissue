function [T, T_avg] = getbackif(backDir, refDir, segDir, binSize, chArray, ...
    chaTform, varargin)
% gets the if for one specified folder directory and returns cell of
% channels, and cell array of cells for each channel
%
% Assumes positions start from 0
%
% outputs cell array of if data in positions x 1
%
% date: 2/22/2020


    %% Set up optional Parameters
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:getbackif:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {true};
    % assign default
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [saveImages] = optargs{:};
    

    % get the ref dapi and back images
    saveImages = false;
    [backI, numChAll, numZ] = getim(backDir, []);
    
    % get tform and apply for back images
    partialTform = true;
    posEnd = 0 + size(backI,1)-1;
    posArray = 0:posEnd;
    [tform, imageCheck] = tformallpos(backDir, refDir, posArray, partialTform);
    backAligned = applyalltform(backI, tform);
    
    % get and apply cha tform
    I = applyallchatform(backAligned(:,chArray), chaTform);
    
    
    % get the amount of images in the directory
    numIm = size(I,1);
    
    if saveImages
        % print the images for each position using 5 of the middle zslices
        s = split(segDir, filesep);
        s1 = join(s(1:end-1), filesep);
        saveDir = fullfile(s1{1}, 'if-image-check');
        mkdir(saveDir);
        startString = 'dapi-check'; 
        endingString = '';
        printallimagespos(I, saveDir, startString, endingString);
    end
    
    
    % get the segmentation
    L = cell(numIm, 1);
    for i = 1:numIm
        segPath = getfile(fullfile(segDir, ['pos' num2str(i-1)]), '.');
        L{i} = getlabel(segPath, numZ);
    end
    
    
    % get the if data from dapi
    T = cell(numIm, numChAll);
    T_avg = cell(numIm, numChAll);
    for i = 1:numIm
        for c = chArray
            S = getif(I{i,c}, L{i}, binSize);
            % put in channel 4
            [T{i,c}, T_avg{i,c}] = if2table(S, binSize);
        end
    end


end