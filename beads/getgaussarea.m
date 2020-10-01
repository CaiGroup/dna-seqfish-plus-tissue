function Area = getgaussarea(x,sup,ydata)
% 2D Gaussian Function that calculates the area of the gaussian fitted
% curve and the original pixel values.
%
% Inputs: (x vector [background, amplitude, x0, y0, std_x, std_y, theta],
% dimensions of the matrix, and the original matrix)
%
% Outputs: three column vector for gauss fit intensity peak, raw intensity
% area and gauss fit intensity area
%
% Author: Nico Pierson
% Date: 2/8/2019
% Email: nicogpt@caltech.edu
% Adapted from: Mike Lawson gauss2dfrobenium.m

% A numberic function for calculating what the minimum
% using this as the starting point : x0  = [min max-min(range) 4 4 1 1 45] 
% sup is the size
% ydate are the pixel values

    back = x(1); % Set to background as minimum pixel value
    amp = x(2); % Height of the peak after subtracting background
    mx = x(3); % Initial x0 and y0 values. Why is it set to 4?
    my = x(4); % So (4,4) in the 7x7 matrix is the initial start value in the center
    sx = x(5); % the standard deviation of x and y is 1
    sy = x(6);
    th = x(7); % theta is 45 degrees

    a = ((cosd(th)^2) / (2*sx^2)) + ((sind(th)^2) / (2*sy^2));
    b = -((sind(2*th)) / (4*sx^2)) + ((sind(2*th)) / (4*sy^2));
    c = ((sind(th)^2) / (2*sx^2)) + ((cosd(th)^2) / (2*sy^2));
    for i = 1:sup(1) % sup is the size of the matrix: for each i and j
        for j = 1:sup(2)
            % Calculate a pixel value: minimum pixel value + the 2D gaussian
            % function of the 

            % Returns coordinates of gaussian 2D function
            % Add background of pixel value to all pixels
            q(i,j) = (back + ...
                amp*exp(-(a*(i-mx)^2 + 2*b*(i-mx)*(j-my) + c*(j-my)^2))  );
        end
    end
    
    % FIX LATER....when all values are mixed and no maximum
    % Set to the center, because there is no fit
    % Check the values of some functions and see if they match
    gaussX = round(mx);
    gaussY = round(my);
    gaussXCenter = round(size(ydata, 2) / 2);
    gaussYCenter = round(size(ydata, 1) / 2);
    if gaussX <= 0
        % get center point
        gaussX = gaussXCenter;
    elseif gaussX > size(ydata, 2)
        % get middle point
        gaussX = gaussXCenter;
    end
    if gaussY <= 0
        gaussY = gaussYCenter;
    elseif gaussY > size(ydata, 1)
        gaussY = gaussYCenter;
    end
    % get the raw intensity value for the gauss adjusted function
    gaussIntensityPeak = double(q(gaussX, gaussY));

    rawArea = sum(sum(ydata));
    gaussArea = sum(sum(q));
    Area = [gaussIntensityPeak rawArea gaussArea];
end