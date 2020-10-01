function [colocalizationData, points1, points2, threshold1, threshold2] = imerror(image1, image2, options)
% calculates the standard error and full half width maximum (FHWM) standard
% deviation error between the points in two images for localization and
% intensity values. FHWM = 2.355 * std
%
% Update: 2/5/2019
% - Fixed bug found by Lincoln: threshold not saved in preprocess dots
% - Automatically finds scripts folder, if not asks user
%
% Update: 2/8/2019
% - added gaussData to return raw intensity, gauss fit intensity, raw
% intensity area, and gauss fit intensity area
% - raw intensity is grabbed from the background subtracted image in the
% gauss2ddotadjust.m
%
% Update: 2/12/2019
% - added new area intensity graphs for Lincoln, updated gauss2dotadjust to
% calculate raw intensity peak and area values.
% - binned all peak and area intensities in one graph.
% -added R value to correlation graph, and updated labels on graphs.
% - cleaned and functionalized grabim.m: easier to use, can grab images
% based on order, zslice range, channel range by using the OMEtiff metadata
% package of bfmatlab.
% - added checks to determine if bfmatlab folder is in MATLAB path
% - added command window outputs for image1 and image2 data
% - moved output variables to console window to printimageoutputs.m
% - added LinkFigures, updated images shown to FindThreshold package
%
% Update: 2/26/2019
% - Added options for alignment, and returning the colocalized data
%
% Update: 3/14/2019
% - Added Fiji.app/scripts path check
%
% Update: 3/15/2018 - Shirin
% - Debugged Fiji directory for macs
%
% Update: 4/12/2019
% - Made options to suppress extra figures for area, and for suppressing
% print output
%
% Things To Do:
% 1. Add options for processing images, align by dapi (tform), threshold
% (two for each image or one for both or choose a threshold), and to save.
% 2. Move Figures so it can be seen in an organized manner
% 3. Make and adjust error graphs: add correlation graph of roi selected
% area between two images
% 4. Debug see if Gaussian fitting is necessary.
% 5. Able to select a region of interest in MATLAB????
% 6. Link figures for Yodai
% 7. Add ROI selection???
% 8. What is another useful graph?
% 9. Grabim to use only a specific set of zSlices
% 10. Save option
% 11. Have both raw intensites, area; and gaussian fitted ones - set
% function to look under different xy pixel range for Lincoln
% 12. What to do if the gaussian fit doesn't work because there is no
% maximum and the values are spread out?
% 13. After background subtraction, a lot of points have intenisity values
% between 1-5, better to revert back to raw image after finding points in a
% processed image? Check to see if image grabs same number of points with
% processed image - I believe for exons finding dots, yes but introns for
% finding dots would be different.
% 14. Add Dapi Alginment instead of aligning the images
%
% Note: processing images didn't change the number of dots much, very few
% less dots were found compared to the raw image: maybe useful for weeding
% out outliers; use the processing to find dots but don't push a processed
% image to calculate inensity values.
% - Possible to weed out points that have a low intensity value or no
% gaussian correlation at all??
%
% Dependencies: 
% - Fiji.app/scripts directory
% - mij.jar: function asks for location for ImageJ
% - FindThreshold package
%
% Example of setting up struct for options:
%    >> options.return = true; % return colocalizationData, points, and
%    threshold
%    >> options.dotdetect = 'exons';
%    >> options.savefigs = true;
%    >> options.threshold1 = 800; % set numeric threshold value image1
%    >> options.threshold2 = 'choose'; % default already: choose threshold
%    value for image 2
%    >> options.processimages = true;
%
% Author: Nico Pierson
% nicogpt@caltech.edu
% Date: 1/28/2019
% Modified: 2/26/2019
% Options, try and catch code adapted from 'loadtiff.m' by YoonOh Tak 2012

    % use errcode to output different types of errors
    errcode = -1;
    try
    %% Check options structure for extra data
        if isreal(image1) == false || isreal(image2) == false
            errcode = 1; assert(false);
        end
        if nargin < 3
            options.savefigs = false;
            options.processimages = true;
            options.debugimages = false;
            options.tform = [];
            options.threshold1 = 'choose';
            options.threshold2 = 'choose';
            options.typedetectdots = 'exons'; % options are 'exons' or 'introns'
            options.colocalizationradius = 1.73; % default 1; colocalize dots in this pixel radius
            options.intarearadius = 3; % default is 3; compare intensity areas in this pixel radius
            options.gaussian = false; % option to use gaussian curve to fit dot locations
            options.return = false; % option for returning colocalization data or not
            options.align = false; % align the images 
            options.foldername = 0; % name of figure in manualthreshold
            options.channelname = 0; % name of figure in manualthreshold
            options.savefig = false; % save figure in manualthreshold
            options.savefigpath = ''; % save figure path in manualthreshold
            options.gatefigs = false; % optional figures
            options.printoutput = true; % print to the command window
        end
        if isfield(options, 'savefigs') == 0
            options.savefigs = false;
        end
        if isfield(options, 'processimages') == 0
            options.processimages = true;
        end
        if isfield(options, 'debugimages') == 0
            options.debugimages = false;
        end
        if isfield(options, 'tform') == 0
            options.tform = [];
        end
        if isfield(options, 'threshold1') == 0
            options.threshold1 = 'choose';
        end
        if isfield(options, 'threshold2') == 0
            options.threshold2 = 'choose';
        end
        if isfield(options, 'typedetectdots') == 0
            options.typedetectdots = 'exons';
        end
        if isfield(options, 'colocalizationradius') == 0
            options.colocalizationradius = 1.73;
        end
        if isfield(options, 'intarearadius') == 0
            options.intarearadius = 3;
        end
        if isfield(options, 'gaussian') == 0
            options.gaussian = false;
        end
        if isfield(options, 'return') == 0
            options.return = false;
        end
        if isfield(options, 'align') == 0
            options.align = false;
        end
        if isfield(options, 'foldername') == 0
            options.foldername = 0;
        end
        if isfield(options, 'channelname') == 0
            options.channelname = 0;
        end
        if isfield(options, 'savefig') == 0
            options.savefig = false;
        end
        if isfield(options, 'savefigpath') == 0
            options.savefigpath = '';
        end
        if isfield(options, 'gatefigs') == 0
            options.gatefigs = false;
        end
        if isfield(options, 'printoutput') == 0
            options.printoutput = true; % print to the command window
        end

        
        %% Start finding the localization and intensity error
        % Get date to save files for unique string
        dateStart = datetime;
        formatDate = 'yyyy-mm-dd';
        dateSaveString = datestr(dateStart, formatDate);
        fprintf('Started imerror.m on %s\n', dateSaveString);

        
        %% Declare Variables
        findThresholdFolderName = 'FindThreshold';
        zSlices = size(image1, 3);

        
        %% Option to Process Images
        % Use ImageJ Background Selection
        if options.processimages
            foundFijiPath = false;
            pathCell = regexp(path, pathsep, 'split');
            for i = 1:size(pathCell, 2)
                pathCell2 = regexp(pathCell{i}, filesep, 'split');
                if strcmp(pathCell2{end}, 'scripts') && strcmp(pathCell2{end-1}, 'Fiji.app')
                    foundFijiPath = true;
                    fprintf('Fiji.app\\scripts directory already in path\n');
                    break;
                end
            end

            if ~foundFijiPath
                % Add path for Fiji scripts folder and mij.jar and ij.jar
                fprintf('Finding Fiji.app\\script folder, and mij.jar files\n\n');
                % add to MATLAB path
                if ispc    
                    fijiDirectory = getdirectory('Fiji.app', 'scripts');
                    addpath(fijiDirectory, '-end');
                else
                    fijiDirectory = getdirectory('Fiji.app', 'scripts', '/Applications');
                    addpath(fijiDirectory, '-end');
                end
                % add to java path
                % Don't need the ij.jar
                %ijDirectory = [getdirectory('ij.jar') filesep 'ij.jar']; 
                %mijDirectory = [getdirectory('mij.jar') filesep 'mij.jar'];
                %javaaddpath(ijDirectory, '-end');
                %javaaddpath(mijDirectory, '-end');
            end
            
            % Subtract the background
            image1Process = imagejbackgroundsubtraction(image1);
            image2Process = imagejbackgroundsubtraction(image2);
        end

        % Need to keep processed images for dot finding and original image
        % for intensities: no problems for intron finding dots, but it is a
        % problem for finding exons part

        %% Option to Find the threshold for each Set of Images
        threshold1Image = image1;
        threshold2Image = image2;
        if strcmp(options.threshold1, 'choose')
            disp('Choose a threshold for first Image');
            % add path to threshold
            addpath(['..' filesep findThresholdFolderName], '-end'); % change to finding the directory
            disp('Finding Threshold');
            % Process Image First with regional maxima and a lap filter for
            % 'exons' type of dot detection
            if options.processimages
                threshold1Image = image1Process;
            end
            [regMax, logFish] = preprocessdots(threshold1Image, options.typedetectdots);
            % Get first threshold
            threshold1 = manualthreshold(options.foldername, options.channelname, ... % set channel and folder to 0 for null
               threshold1Image, regMax, logFish, options.typedetectdots);
           disp('Completed Threshold for Image 1');
        else
            if isnumeric(options.threshold1)
                threshold1 = options.threshold1;
            else
                errcode = 3; assert(false);
            end
        end
        % Option to Find Second Threshold Value in the Image
        if strcmp(options.threshold2, 'choose')
            disp('Choose a threshold for the second Image');
            % add path to threshold
            addpath(['..' filesep findThresholdFolderName]);
            disp('Finding Threshold');
            % Process Image First with regional maxima and a lap filter for
            % 'exons' type of dot detection
            if options.processimages
                threshold2Image = image2Process;
            end
            [regMax, logFish] = preprocessdots(threshold2Image, options.typedetectdots);
            % Get second threshold
            threshold2 = manualthreshold(options.foldername, options.channelname, ...
                threshold2Image, regMax, logFish, options.typedetectdots);% set channel and folder to 0 for null
            disp('Completed Threshold for Image 2');
        else
            if isnumeric(options.threshold2)
                threshold2 = options.threshold2;
            else
                errcode = 3; assert(false);
            end
        end
        
        
        
        %% Find the Dots and Calculate the Error with the Mean
        % Images will either be the raw image or the process image
        disp('Preprocessing First Image');
        [dots1, dotsLogic1, lapImage1] = detectdots(threshold1Image, threshold1, ...
            options.typedetectdots, options.debugimages, options.savefig, options.savefigpath);
        disp('Preprocessing Second Image');
        options.savefigpath = [options.savefigpath '-2'];
        [dots2, dotsLogic2, lapImage2] = detectdots(threshold2Image, threshold2, ...
            options.typedetectdots, options.debugimages, options.savefig, options.savefigpath);
        
        
        
        %% Align the images using 3D affine object
        % Need 16 zSlices to get a 3D transformation otherwise use 2d
        % transformation
        % - points match better with laplacian filtered image
        % - Don't really need if images are in the same channel 
        % - Do we need to transform in the z axis?
        
        if options.align
            %**** Lap image is different for 'introns' detect dots
            tform = get2dtform(threshold1Image, threshold2Image, zSlices);

            % Apply 2d transformation to the dots2
            dots2Align = round(transformPointsForward(tform, dots2.location(:,1:2)));
            dots2Align(:,3) = dots2.location(:,3);
        else
            dots2Align = dots2.location;
        end
        
        
        
        %% Colocalize the dots
        % images only used for debugging purposes
        debug = 0;
        [points1, points2, ~, ~, ~] = colocalizedots(image1, ...
            image2, dots1.location, dots2Align, options.colocalizationradius, debug);
        
        %% Get the raw areas for the intensity
        rawIntData1 = getrawintensity(points1, image1, options.intarearadius);
        rawIntData2 = getrawintensity(points2, image2, options.intarearadius);
        rawData1 = [points1(:,2), points1(:,1), points1(:,3), rawIntData1];
        rawData2 = [points2(:,2), points2(:,1), points2(:,3), rawIntData2];

        
        
        %% Gaussian adjust the point locations and intensity
        if options.gaussian
            % Implement gaussian option later
            disp('Gaussian Fitting Each Point')
            % Add as an option: need to take out the raw area in the gauss
            % function

            % gaussData: 1. gauss fit x 2. gauss fit y 3.z 4.raw intensity peak
            % 5. gaussian fit intensity peak 6. raw area of intensity 7.
            % gaussian fit intensity area

            % use the raw images to calculate intensity and gauss fit points
            % Is it easier to make a table with this data, then print the
            % table?
            gaussData1 = gauss2ddotadjust(points1, image1, options.intarearadius);
            gaussData2 = gauss2ddotadjust(points2, image2, options.intarearadius);
        else
            gaussData1 = [];
            gaussData2 = [];
        end
        
        
        
        %% Print the Figures and get Error Values
        % Gaussian Fit points are used to calculate the location error
        [rIntPeak, rIntArea, fwhmLocation, fwhmIntPeak, fwhmIntArea] = printerrorfigures(rawData1, rawData2, zSlices, options.gatefigs);
        errorData = [rIntPeak, rIntArea, fwhmLocation, fwhmIntPeak, fwhmIntArea];
        
        
        if options.printoutput
            %% Print Output of all Variables
            numDots1 = size(dots1.location, 1);
            numDots2 = size(dots2.location, 1);
            numColDots = size(points1, 1);
            numberOfDots = [numDots1, numDots2, numColDots];
            thresholdData = [threshold1 threshold2];
            colocalizationData = printimageoutputs(rawData1, rawData2, numberOfDots, errorData, thresholdData);

            if ~options.return 
                % set to null if not using
                colocalizationData = [];
                points1 = [];
                points2 = [];
                threshold1 = [];
                threshold2 = [];
            end
        end

        disp('imerror.m function Complete');
        
    catch exception
        %% catch the exceptions in the function
        % Update the error messages for errors
        switch errcode
            case 0
                error 'Invalide path.';
            case 1
                error 'It does not support complex numbers.';
            case 2
                error '''data'' is empty.';
            case 3
                error 'Threshold option is invalid. Usage: enter numeric value or "choose" for options.threshold1 or 2';
            otherwise
                rethrow(exception);
        end
    end

end