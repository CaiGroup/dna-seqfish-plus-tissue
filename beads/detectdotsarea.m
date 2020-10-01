function [dots, dotsArea, regMax, logImage] = detectdotsarea(image, rawImage, threshold,varargin)
% Process the image and check the threshold. Find dots using a
% laplacian filter. Code is usually used for detecting dots for exons as
% they are not as bright as introns. For 'exons', threshold values are
% usually 3000 to 20,000, and the number of dots detected range from 5,000 to
% 20,000. For 'introns', threshold values are usually in the range of 200
% to 600, and there are usually 12,000 to 20,000 dots.
%
% inputs: processed image, threshold (integer), debug flag (set to 1
% for true and 0 for false).
%
% outputs: dots.location are the x y and z coordinates, dots.intensity
% are the intensity values, and dotsLogical is a logical matrix for
% each found dot.
%
% Update 1/29/2019: Add optional arguments for debug and choosing the type
% of method to detect dots. Default will be false for debug, and 'exons'
% for type of dot detection.
%
% Author: Sheel Shah
% Date: March 2018
% Modified By: Nico Pierson
% Email: nicogpt@caltech.edu
% Date: 1/28/2019


    %% Set up optional Parameters
    argsLimit = 4;
    numvarargs = length(varargin);
    if numvarargs > 4
        error('src:detectdots:TooManyInputs', ...
            'requires at most 4 optional inputs');
    end
    
    % Error for type of arguments
    if numvarargs >= 1 
        if ~ischar(varargin{1}) 
            error('src:detectdots:WrongInput', ...
                'detectdots var typedetectdots requires type string');
        elseif ~strcmp(varargin{1}, 'exons') && ~strcmp(varargin{1}, 'introns') && ~strcmp(varargin{1}, 'exons2d')
            error('src:detectdots:WrongInput', ...
                'detectdots var typedetectdots requires type string: "exons" or "introns" or "exons2d"');
        end
    end
    if numvarargs >= 2
        if varargin{2} ~= 0 && varargin{2} ~= 1 
            error('src:detectdots:WrongInput', ...
                'detectdots var debug requires type boolean');
        end
    end
    if numvarargs >= 3
        if varargin{3} ~= 0 && varargin{3} ~= 1
            error('myfun:detectdots:WrongInput', ...
                'saveImage is not true or false: requires type boolean');
        end
    end
    if numvarargs == argsLimit
        if ~ischar(varargin{argsLimit})
            error('myfun:detectdots:WrongInput', ...
                'saveFigPath is not a char: requires type string');
        end
    end

    
    % set defaults for optional inputs
    optargs = {'exons', false, false, 'fig'};
    
    % assign defaults
    optargs(1:numvarargs) = varargin;
    
    % Default Value of ref image is 1
    [typeDetectDots, debug, saveImage, saveFigPath] = optargs{:};

    
    
    
    %% Start detect dots function
    switch typeDetectDots
        case 'exons'
            %% Find Dots using Laplacian filter
            getImage = double(image);
            logImage = zeros(size(getImage)); % initialize logFish
            for i=1:size(getImage, 3) % for each z-slice, apply laplacian filter
                logImage(:,:,i) = logMask(getImage(:,:,i));
            end
            regMax = imregionalmax(logImage); % get regional maxima
            % create logical matrix of dots that are a regional maxima and above
            % the treshold value
            dotsArea = logImage > threshold;
            dotsLogical = regMax & logImage > threshold; 
        case 'introns'
            %% Find Dots using 3 x 3 x 3 logical mask
            getImage = double(image); % initialize maxFish
            % set mask to 3 by 3 by 3 logical matrix, and set middle to zero
            regMask = true(3,3,3);
            regMask(2,2,2) = false;
            % assign, to every voxel, the maximum of its neighbors
            belowThresh = getImage < threshold;
            logImage = getImage;
            logImage(belowThresh) = 0;
            dilate = imdilate(logImage,regMask);

            % create logical matrix of dotsLogical where 1 is the voxel's value is
            % greater than its neighbors
            dotsArea = logImage > dilate;
            dotsLogical = dotsArea; 
            
        case 'exons2d'
            %% Find Dots using Laplacian filter
            getImage = double(image);
            logImage = zeros(size(getImage)); % initialize logFish
            for i=1:size(getImage, 3) % for each z-slice, apply laplacian filter
                logImage(:,:,i) = logMask(getImage(:,:,i));
                
                regMax = imregionalmax(logImage(:,:,i)); % get regional maxima
                % create logical matrix of dots that are a regional maxima and above
                % the treshold value
                dotsArea(:,:,i) = logImage > threshold;
                dotsLogical(:,:,i) = regMax & logImage(:,:,i) > threshold; 
            end

        otherwise
            error 'detectdots var typedetectdots invalid argument';
    end
    
    %% Remove border dots
    bordSize = 5;
    bord = ones(size(dotsLogical));
    bord(1:bordSize,:,:) = 0;
    bord(end-bordSize:end,:,:) = 0;
    bord(:,end-bordSize:end,:) = 0;
    bord(:,1:bordSize,:) = 0;
    dotsArea = dotsArea.*logical(bord);
    dotsLogical = dotsLogical.*logical(bord);

    %% Debug flag to visualize image and dots
    if debug == 1
        h1 = figure;
        % View image with dots: can use logFish or fish image
        imshow(max(image, [], 3), [min(min(max(image,[],3))) 2000], 'InitialMagnification', 'fit');
        hold on;
        [v2,v1] = find(max(dotsLogical, [], 3) == 1);
        scatter(v1(:), v2(:), 75);
        hold off;
        if saveImage
            saveFigDotsPath = [saveFigPath '-Dots'];
            savefig(h1, saveFigDotsPath);
        end
                % View image with dots: can use logFish or fish image
        h2 = figure;
        imshow(max(image, [], 3), [min(min(max(image,[],3))) 2000], 'InitialMagnification', 'fit');
        hold on;
        [vA2,vA1] = find(max(dotsArea, [], 3) == 1);
        scatter(vA1(:), vA2(:), 75);
        hold off;
        if saveImage
            saveFigAreaPath = [saveFigPath '-Area'];
            savefig(h1, saveFigAreaPath);
        end
        close all;
    end

    %% Get x, y, z coordinates of dots
    [y,x,z] = ind2sub(size(dotsLogical), find(dotsLogical == 1));
    [yA,xA,zA] = ind2sub(size(dotsArea), find(dotsArea == 1));
    dots.location = [x y z];
    dots.area = [xA yA zA];
    
    %% Get max intensity of each dot
    %im = max(rawImage, [], 3); % max of all images
    for i = 1:length(y)
        dots.intensity(i,1) = double(rawImage(y(i), x(i), z(i)));
    end
    dots.intensityscaled = double(dots.intensity) / mean(dots.intensity); 
    for j = 1:length(yA)
        dots.intensityarea(j,1) = double(rawImage(yA(j), xA(j), zA(j)));
    end
    dots.intensityareascaled = double(dots.intensityarea) / mean(dots.intensityarea);
    
end


function lapFrame = logMask(im)   %laplacian filter 4x4 matrix

k = [-4 -1  0 -1 -4;...
     -1  2  3  2 -1;...
      0  3  4  3  0;...
     -1  2  3  2 -1;...
     -4 -1  0 -1 -4];

lapFrame = imfilter(im, k, 'repl');

end