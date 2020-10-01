function numberOfPoints = imgetnumberpointsroi(roiPath, points)
% findnumpointsroi finds the number of points in each set of points
%
% Author: Nico Pierson
% Date: 4/18/2019

    % Declare Variables
    vertex = selfseg(roiPath);
    numberOfPoints = zeros(length(vertex), 1);
    
    for i = 1:length(vertex)
        found = [];
        include = inpolygon(points(:,1),points(:,2),vertex(i).x,vertex(i).y);
        found = find(include == 1);
        numberOfPoints(i) = length(found);
    end
    
end