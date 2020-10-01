function I = grabim(imagePath, strCompare, varargin)
% grabim returns the image within a specific tiff stack.
%
% Inputs: image path and part of the unique string of image
%
% Optional inputs: index of channel (starting at 1; can use vector [1
% 3] to grab channels 1 and 3) or leave blank to get all channels, zslice
% index can be a vector [3:8] to grab zslices from 3 to 8 or [4 6 9] to
% grab only 4, 6, and 9 zslices.
%
% Update: 2/10/2019
% - Changed position as the last optional parameter
% - zSliceIndices is the range of zSlices to choose, default is 1:zSlices,
% for example a user can choose to grab only the 3:8 zSlices of an image
% >> grabim(pathName, indexOfChannel, numberOfChannels, zSlices, 
% stringCompare, 3:8);
% - Added debug flag to see images
% - text outputs displaying zslices selected and type of organization of
% the image
%
% Update: 2/11/2019
% - add the bfopen OMEmetadata check for the order of the images, and grab
% those images in the index directory
% - OMEmetadata gets the number of zslices and channels
%
% Update: 2/12/2019
% - Checks for bfmatlab in path, and adds
%
% To Do List:
% 1. NEED DOCUMENTATION AND EXAMPLES.
% 3. Main things neede are an option for choosing z-slice section, only
% need imagePath, indexOfChannel, numberOfChannels, zSlices, optional args: 
% Can I get the z-slices and number of Channels from the metadata? - check
% later
% 3. Add options for grabbing multiple series in a tiff image
%
% Optional Parameters: imageOrg, strCompare, zSliceIndex
% imageOrg is an option to organize images from two options: 'yodia intron
% rep4' from xyczt order, and 'linus 10k' from xyzct order
%
% strCompare is the string used to find the image, 'ome' is the default.
% Example: Image has a nmae Pos1, so use 'Pos1' as the strCompare option.
%
% zSliceIndex: is an option to get one specific zSlice in a stack.
%
% Outputs: matrix of tif images
%
% Author: Nico Pierson
% Date: November 9, 2018
% Modified: 2/11/2019

    %% Set up optional Parameters for z-slice index
    numvarargs = length(varargin);
    if numvarargs > 3
        error('myfun:grabim:TooManyInputs', ...
            'requires at most 3 optional inputs');
    end

    % Error for type of arguments: zslice index, default are all the
    % zslices, while inputing a vector only gets the zslices wanted
    if numvarargs >= 2
        if ischar(varargin{2})
            if ~strcmp(varargin{2}, 'all')
                error('myfun:grabim:WrongInput', ...
                    'z-slice index requires type string: ''all'' or an index of zslices, ex: 1 or 3:8');
            end
        elseif ~isnumeric(varargin{2}) && ~(mod(varargin{2}, 1) == 0)
            error('myfun:grabim:WrongInput', ...
                'z-slice index is not numeric or an integer: requires type int');
        end
    end

    %% Check if bfmatlab is in the path
    packagePath = fullfile(pwd, '..');
    try
        pathCell = regexp(path, pathsep, 'split');
        bfmatlabFolder = 'bfmatlab';
        onPath = false;
        for i = 1:size(pathCell, 2)
            pathCell2 = regexp(pathCell{i}, filesep, 'split');
            if strcmp(pathCell2{end}, bfmatlabFolder)
                onPath = true;
                fprintf('bfmatlab directory already in path\n');
                break;
            end
        end
        % if not on path, add to MATLAB path
        if ~onPath
            bfmatlabDirectory = getdirectory(bfmatlabFolder, [], packagePath);
            addpath(bfmatlabDirectory);
        end
    catch
        error(['bfmatlab package not found or unable to add to path' ...
            'Download package at https://downloads.openmicroscopy.org/bio-formats/4.4.9/']);
        % later add download function:
        % https://downloads.openmicroscopy.org/bio-formats/4.4.9/artifacts/bfmatlab.zip
        % or /loci_tools.jar  file
    end

    
    
    %% Get imagefile with bfopen and metadata
    imageFileName = getfile(imagePath, strCompare, 'match');
    
    % Use bfopen to get images with OMEmetadata
    data = bfopen(imageFileName);
    % get metadata for fileorder
    omeMeta = data{1, 4};
    dimensionOrder = convertCharsToStrings(omeMeta.getPixelsDimensionOrder(0).getValue().toCharArray); % maybe change to cellstr; doesn't work on 2016b
    % number of channels
    numChannels = omeMeta.getChannelCount(0);
    fprintf('Image has %.0f channels\n', numChannels);
    % number of z-slices
    zSlices = omeMeta.getPixelsSizeZ(0).getValue();
    fprintf('Image has %.0f zslices\n', zSlices);
    % number of series
    seriesCount = size(data, 1); % sometimes images are bound together with all hybs
    series1 = data{1, 1};  % ex. 8 field of views will have 8 datasets, pos0 = data{1}, pos1 = data{2} and so on
    metadataList = data{1, 2};
    % number of planes in series1
    series1_planeCount = size(series1, 1);
    
    
    
    %% Set Defaults for optional inputs
    optargs = {1:numChannels, 1:zSlices, false};
    
    % now put these defaults into the valuesToUse cell array, 
    % and overwrite the ones specified in varargin.
    optargs(1:numvarargs) = varargin;
    
    % Default Value of ref image is 1
    [indexOfChannel, zSliceIndices, viewImage] = optargs{:};

    
    
    %% Set flag for all channels or just 1
    if ~isnumeric(indexOfChannel) && ~(mod(indexOfChannel, 1) == 0) 
        error('myfun:grabim:WrongInput', ...
            'index of channel is not numeric or an integer: requires type int');
    elseif isscalar(indexOfChannel) && ~(mod(indexOfChannel, 1) == 0)
        % if single channel and integer
    end
    
    
    
    %% Find the directory to grab tif images
    %warning ('off','all');
    % the channel attribute gives the channels of the tiff stack to be
    % loaded; for 2 z-slice 4 channel image ex: index 1 = [1 5]; index 2 =
    % [2 6], index 3 = [3 7] and index 4 = [4 8]
    
    indicesOfDirectory = []; % initialize
    fprintf('Grabbing Indices for Channels');
    fprintf('% .0f', indexOfChannel);
    fprintf('\n');
    fprintf('Grabbing Indices for zSlices');
    fprintf('% .0f', zSliceIndices);
    fprintf('\n');
    switch dimensionOrder % Switch to find the Directory of the Tif images based on organization of images
        case 'XYCZT' % if order is channels then zslices, ex [4 8] are dapi in 4 channels and 2 zslices
            fprintf('Image order: XYCZT...\n');
            finalIndex = numChannels * zSlices;
            directoryRange = 1:numChannels:finalIndex;
            for channel = indexOfChannel % add indices to each channel
                channelIndices = directoryRange + (channel-1); % zslices skip per channel
                % grab only zSlices needed
                channelIndices = channelIndices(zSliceIndices);
                % add to main indices
                indicesOfDirectory = cat(2, indicesOfDirectory, channelIndices); 
            end

        case 'XYZCT' % if zslices then channels, ex [7 8] are dapi in 4 channels and 2 zslices
            fprintf('Image order: XYZCT...\n');
            for channel = indexOfChannel
                channelIndices = (1:zSlices) + (channel-1) * zSlices; % all zslices together
                % grab only zSlices needed
                channelIndices = channelIndices(zSliceIndices);
                % add to main indices
                indicesOfDirectory = cat(2, indicesOfDirectory, channelIndices); 
            end
        otherwise
             error 'Invalid dimension order for loaded image';
    end
   
    
    
    %% Grab the Images from the Tif Stack
    % Get all images in field of view range, otherwise get only images in
    % field of range.
    I = [];
    %for i = 1:seriesCount
    for index = indicesOfDirectory
        %fprintf('Grabbed index %.0f...\n', index); % selects the Position with the original field of view
        % Get images from tiff stack
        L = series1{index, 1};
        % position is not used if there is a string to match to
        if index > 1
            I = cat(3, I, L); % Catenate L to stack of I
        else
            I = L;
        end
    end
    fprintf('Successfully grabbed all image planes...\n\n');
    
    %% debug to view images
    if viewImage
        % get the max z-projection and view the image
        close all;
        addHigherPixelRange = 1500;
        figure;
        imshow(max(I, [], 3), 'DisplayRange', [min(min(max(I,[],3))) mean(mean(max(I,[],3))) + addHigherPixelRange], 'InitialMagnification', 'fit');
        pause;
        close all;
    end
    
    %warning ('on','all');
    
end