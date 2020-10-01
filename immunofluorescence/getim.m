function [I, numCh, numZ] = getim(imDir, varargin)
% get images in the directory
%
% date 2/22/2020


    %% Set up optional Parameters
    argsLimit = 3;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:getim:TooManyInputs', ...
            'requires at most 3 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {'MMStack_Pos*.tif', [], []};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    %channel specifies a specific channel to grab
    [regExp, channel, numCh] = optargs{:};

    %% Initialize Variables
    numZ = [];
    I = {};
    if isempty(regExp)
        regExp = 'MMStack_Pos*.tif';
    end
    
    %% get all the files in the directory
    files = dir(fullfile(imDir, regExp));
    numFiles = length(files);
    
    % assumes postions starts at 0
    for i = 1:numFiles
        % get the correct filename
        filename = [];
        for f = 1:numFiles
            if strcmp(files(f).name, ['MMStack_Pos' num2str(i-1) '.ome.tif'])
                filename = files(f).name;
                break;
            end
        end
        % path of image
        imPath = fullfile(imDir, filename);
        % get image, make sure image package is in path
        [image, sizeC, sizeZ, physicalsizeX, physicalsizeY] = ...
            grabimseries(imPath, i-1, channel, numCh);
        I = cat(1, I, image);
        if isempty(numCh)
            numCh = sizeC;
        end
        if isempty(numZ)
            numZ = sizeZ;
        end
    end

end