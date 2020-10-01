function rawIntensityData = getrawintensity(coordinates, image, varargin)
% Get the raw intensity peaks and area from the points
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
% Update 2/12/2019
% - the dataRangeX and dataRangeY were switched.
%
%
% Author: Nico Pierson
% Date: February 12, 2019
% Modified:
% Code Adapted from Mike Lawson
% Date: May 2018

    %% Set up optional Parameters
    
    numvarargs = length(varargin);
    if numvarargs > 1
        error('myfuns:getrawintensityarea:TooManyInputs', ...
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
    optimset('Display','off');
    numberOfCoordinates = size(coordinates,1);
    % col 1 is the raw intensity peak, col 2 is the raw intensity area
    rawIntensityData = zeros(numberOfCoordinates, 2);
    
    
    for dotID = 1:numberOfCoordinates % For each dot location 
        zSlice = coordinates(dotID, 3);
        dataRangeX = round((-pixelRadius:pixelRadius) + coordinates(dotID,1)); % parenthesis are necessary
        dataRangeY = round((-pixelRadius:pixelRadius) + coordinates(dotID,2)); % Need to round before inserting into image
        data = double(image(dataRangeY, dataRangeX, zSlice)); % select region in a 3x3 pixel radius % error NOT IN the IMAGE

        % Assign the raw intensity peaks and area
        rawIntensityData(dotID,1) = double(image(coordinates(dotID,2),coordinates(dotID,1), zSlice));
        rawIntensityData(dotID,2) = sum(sum(data));
    end
    
end