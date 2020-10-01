function gaussFinalData = gauss2ddotadjust(coordinates, image, varargin)
% Adjust image using a 2D Gaussian Fit; Searches for each point in the
% image x,y range in the z-slice, and fits it using a gaussian curve.
%
% Inputs: (coordinates x and y, image, and optional pixel width for 2D
% gausssian fit)
% Default value for pixel width is 3.
%
% Outputs: gaussData adjusted through a 2D Gaussian Fit where there are 9
% rows of variables: 1. minimum intensity 2. maximum intensity
% value 3. x0 4. y0 5.standard deviation location of x peak 6. standard
% deviation location of y peak 7. theta 8. raw intensity peak 9. gaussian
% fit intensity peak 10. raw area of intensity 11. gaussian fit area
%
% Final data will have: 1. x 2. y 3.z 4.raw intensity peak 5. gaussian
% fit intensity peak 6. raw area of intensity 7. gaussian fit intensity
% area.
%
% Pixel raidus is the radius plus one pixel for the center: if pixelRadius
% = 3, a 7 x 7 matrix will be created as the search radius.
%
% Update: 2/8/2019
% - added 4 extra variable at the end of gaussCoordinates.
%
% Author: Nico Pierson
% Date: October 23, 2018
% Modified: 1/30/2019
% Code Adapted from Mike Lawson
% Date: May 2018

    %% Set up optional Parameters
    
    numvarargs = length(varargin);
    if numvarargs > 1
        error('myfuns:getallbeads:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end

    % set defaults for optional inputs
    optargs = {3}; % default of using 7 x 7 pixel grid for gaussian function
    
    % now put these defaults into the valuesToUse cell array, 
    % and overwrite the ones specified in varargin.
    optargs(1:numvarargs) = varargin;
    
    % Place optional args in memorable variable names
    [pixelRadius] = optargs{:};

    %% Adjust Bead Coordinates in Dots Image with 2D Gaussian Fit
    % Initialize Variables
    options = optimset('Display','off');
    numberOfCoordinates = size(coordinates,1);
    numberOfGaussianParameters = 7;
    gaussData = zeros(numberOfCoordinates, numberOfGaussianParameters);
    zSliceData = zeros(numberOfCoordinates, 1);
    % col 1 is the gauss intensity peak, col 2 is the raw intensity area,
    % and col 3 is the gauss adjusted intensity area
    gaussIntPeakRawGaussIntensityArea = zeros(numberOfCoordinates, 3);
    rawIntensityPeak = zeros(numberOfCoordinates, 1);
    
    for dotID = 1:numberOfCoordinates % For each dot location 
        zSlice = coordinates(dotID, 3);
        dataRangeX = round((-pixelRadius:pixelRadius) + coordinates(dotID,1)); % parenthesis are necessary
        dataRangeY = round((-pixelRadius:pixelRadius) + coordinates(dotID,2)); % Need to round before inserting into image
        data = double(image(dataRangeX, dataRangeY, zSlice)); % select region in a 3x3 pixel radius % error NOT IN the IMAGE
        x0 = [min(min(data)) max(max(data))-min(min(data)) pixelRadius+1 pixelRadius+1 1 1 45]; % x0  = [min max-min(range) 4 4 1 1 45] is the starting point
        dataSize = size(data); % 7 x 7 array
        f = @(x)gauss2dfrobenium(x,dataSize,data); % Cost function for 2D Gaussian image
        % find minimum frobenium norm of the 2d Gaussian adjusted pixels
        % and return the values for min max-min x0 y0 stdx stdy and theta
        [minCoords, fva] = fminsearch(f,x0,options); % I believe the minCoords will be set to 1,1 if there is no gaussian curve
        gaussData(dotID,:) = minCoords; % Assign value of gaussian fitted coordinates
        % Assign zSlice
        zSliceData(dotID) = zSlice;
        % Find the areas under the curve for both raw and gauss fitted
        % intensity values: does the background to be added or
        % subtracted? I don't believe so
        % use the found minimum from the frobenium function: minCoords
        gaussIntPeakRawGaussIntensityArea(dotID,:) = getgaussarea(minCoords, dataSize, data);
        % get raw Intensity Peak of point
        rawIntensityPeak(dotID,:) = double(image(coordinates(dotID, 1), coordinates(dotID, 2), zSlice));
    end
    
    % Take the 3rd and 4th columns 
    gaussFinalData = gaussData(:,3:4); 
    % Adjust the gaussian coordinates by adding to original coordinates and
    % subtracting pixel width
    gaussFinalData(:,1:2) = coordinates(:,1:2) + gaussData(:,[3 4]) - [pixelRadius, pixelRadius]-1; % keep gaussData(:,[3 4]) for x and y
    % Add zSlices to col 3
    gaussFinalData(:,3) = zSliceData;
    % Get all intensity peaks from raw image
    % Add raw intensity peak to col 4
    gaussFinalData(:,4) = rawIntensityPeak;
    % Add the gauss adjusted intensity peak to col 5, the raw intensity
    % area to col 6 and the gauss fit intensity area to col 7
    gaussFinalData(:,5:7) = gaussIntPeakRawGaussIntensityArea;
    
end