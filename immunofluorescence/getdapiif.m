function [T, T_avg] = getdapiif(imDir, segDir, binSize, chaTform, varargin)
% gets the if for one specified folder directory and returns cell of
% channels, and cell array of cells for each channel
%
% outputs cell array of if data in positions x 1
%
% date: 2/22/2020


    %% Set up optional Parameters
    argsLimit = 4;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:getdapiif:TooManyInputs', ...
            'requires at most 4 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {true, false, false, []};
    % assign default
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
<<<<<<< HEAD
    [saveImages, imagejbacksub, edges, uniqueString] = optargs{:};
=======
    [saveImages, imagejbacksubtract, edges] = optargs{:};
>>>>>>> 4b93f1680eb757f344264f89dfa1b8d60e22a4dc
    

    % get the ref dapi images
    [dapiRef, numChAll, numZ] = getim(imDir, [], 'dapi');
    
<<<<<<< HEAD
    
    %% imagej background subtraction
    if imagejbacksub
        numHybs = size(dapiRef, 1);
        if isempty(uniqueString)
            uniqueString = 'imageTempProcess-3535fsfsg';
        end
        for h = 1:numHybs
            dapiRef{h} = imagejbackgroundsubtraction(dapiRef{h}, uniqueString,...
                imDir);
            if edges
                dapiRef{h} = imagejfindedges(dapiRef{h}, uniqueString, imDir);
=======
    % apply imageJbackgrond subtraction
     %imagej background subtraction
    if imagejbacksubtract
        uniqueString = 'imageTempProcess-71322020';
        for h = 1:size(dapiRef,1)
            for ch = 1:size(dapiRef,2)
                dapiRef{h,ch} = imagejbackgroundsubtraction(dapiRef{h,ch}, uniqueString,...
                    imDir);
                if edges
                    dapiRef{h,ch} = imagejfindedges(dapiRef{h,ch}, uniqueString, imDir);
                end
>>>>>>> 4b93f1680eb757f344264f89dfa1b8d60e22a4dc
            end
        end
    end
    

    
    % get and apply cha tform
    I = applyallchatform(dapiRef, chaTform(end));
    
    
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
        S = getif(I{i}, L{i}, binSize);
        % put in channel 4
        [T{i,numChAll}, T_avg{i,numChAll}] = if2table(S, binSize);
    end


end